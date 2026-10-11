#!/usr/bin/env python3
"""Read-only preview-save checks; this helper never operates a simulator or app.

Use --phase after-install for exact preference preservation, then --phase
 after-launch for full decoded game-state comparison. Reports contain only
 public QA facts; preferences, player identifiers and source paths are omitted.
"""
from __future__ import annotations

import argparse
import json
import math
import plistlib
import sys
from pathlib import Path
from typing import Any

BASELINE_KEYS = {
    "SKTransactionUpdatesLastChecked",
    "orbitBloom.charged.v1",
    "orbitBloom.progress.v1",
    "orbitBloom.purchaseReceipts",
    "orbitBloom.wallet.backup",
    "orbitBloom.wallet.v2",
}
JSON_KEYS = {
    "orbitBloom.progress.v1", "orbitBloom.session.v1",
    "orbitBloom.wallet.backup", "orbitBloom.wallet.v2",
}
WALLET_KEYS = {"orbitBloom.wallet.backup", "orbitBloom.wallet.v2"}
EMPTY_JOURNEY = {"levels": {}, "bestScores": {}, "events": {}, "claimedEvents": []}
ENUM_DICTIONARY_PATHS = {
    ("collected",), ("specials",),
    ("session", "collected"), ("session", "specials"),
    ("ecosystem", "tools"),
}


class InvalidInput(Exception):
    pass


def unique_object(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
    result: dict[str, Any] = {}
    for key, value in pairs:
        if key in result:
            raise InvalidInput("Duplicate JSON key")
        result[key] = value
    return result


def reject_constant(_: str) -> None:
    raise InvalidInput("Nonfinite JSON number")


def decode_json(value: Any) -> dict[str, Any]:
    if not isinstance(value, bytes):
        raise InvalidInput("Expected JSON preference data")
    decoded = json.loads(value, object_pairs_hook=unique_object, parse_constant=reject_constant)
    if not isinstance(decoded, dict):
        raise InvalidInput("Expected JSON object")
    return decoded


def canonical_json(value: Any, path: tuple[str, ...] = ()) -> Any:
    """Ignore only object-key order and three known Swift enum-map encodings.

    Grid, plot, frost, restored, claim, receipt and all other array ordering is
    preserved. Dates, counts and every gameplay value remain part of comparison.
    """
    if isinstance(value, dict):
        return ("object", tuple((key, canonical_json(value[key], path + (key,))) for key in sorted(value)))
    if isinstance(value, list):
        if path in ENUM_DICTIONARY_PATHS:
            if len(value) % 2:
                raise InvalidInput("Malformed Swift dictionary array")
            pairs = []
            seen: set[str] = set()
            for index in range(0, len(value), 2):
                key = canonical_json(value[index])
                encoded_key = json.dumps(key, ensure_ascii=True, separators=(",", ":"))
                if encoded_key in seen:
                    raise InvalidInput("Duplicate Swift dictionary key")
                seen.add(encoded_key)
                pairs.append((encoded_key, canonical_json(value[index + 1], path + ("value",))))
            return ("enumDictionary", tuple(sorted(pairs, key=lambda pair: pair[0])))
        return ("array", tuple(canonical_json(item, path + ("item",)) for item in value))
    if isinstance(value, float) and not math.isfinite(value):
        raise InvalidInput("Nonfinite JSON number")
    # Include the JSON primitive type: bool true must not compare equal to int 1.
    return (type(value).__name__, value)


def plist_value_bytes(value: Any) -> bytes:
    """Data preferences retain their actual bytes; other plist types stay strict."""
    if isinstance(value, bytes):
        return value
    return plistlib.dumps({"value": value}, fmt=plistlib.FMT_BINARY, sort_keys=True)


def strict_preference_equal(left: Any, right: Any) -> bool:
    return type(left) is type(right) and plist_value_bytes(left) == plist_value_bytes(right)


def read_preferences(path: Path) -> tuple[dict[str, Any], bytes]:
    data = path.read_bytes()
    value = plistlib.loads(data)
    if not isinstance(value, dict):
        raise InvalidInput("Expected preference dictionary")
    return value, data


def public_save_summary(preferences: dict[str, Any]) -> dict[str, int | None]:
    wallet = decode_json(preferences["orbitBloom.wallet.v2"])
    progress = wallet["progress"]
    ecosystem = wallet["ecosystem"]
    session = wallet.get("session")
    lives = ecosystem["lives"]
    summary = {
        "coins": progress["coins"],
        "completed": len(progress["completed"]),
        "activeLevel": session.get("levelID") if session else None,
        "rulesVersion": session.get("rulesVersion", 1) if session else None,
        "moves": session.get("moves") if session else None,
        "freeHints": wallet["assistance"]["freeHints"],
        "lives": lives["hearts"] + lives.get("reserve", 0),
    }
    # The report may contain QA counts only, even for corrupt comparison input.
    # Never allow an arbitrary string from a preference to reach public output.
    if any(value is not None and (type(value) is not int or not 0 <= value <= 2**63 - 1)
           for value in summary.values()):
        raise InvalidInput("Invalid public QA count")
    return summary


def verify(before: dict[str, Any], after: dict[str, Any], phase: str,
           before_bytes: bytes, after_bytes: bytes) -> dict[str, Any]:
    if set(before) != BASELINE_KEYS:
        raise InvalidInput("Unexpected baseline preferences")
    report: dict[str, Any] = {
        "phase": phase,
        "baselinePreferenceCount": len(before),
        "observedPreferenceCount": len(after),
        "beforePublicSave": public_save_summary(before),
        "afterPublicSave": public_save_summary(after),
    }
    if phase == "after-install":
        matching_keys = set(before) == set(after)
        exact = matching_keys and all(strict_preference_equal(value, after[key]) for key, value in before.items())
        report.update({
            "passed": exact,
            "allPreferencesByteForByte": exact,
            "preferenceKeysUnchanged": matching_keys,
            "plistFileBytesIdentical": before_bytes == after_bytes,
            "note": "Data preference bytes and all baseline typed values are checked; plist container encoding is separately reported.",
        })
        return report

    game_keys_before = {key for key in before if key.startswith("orbitBloom.")}
    game_keys_after = {key for key in after if key.startswith("orbitBloom.")}
    matching_keys = game_keys_before == game_keys_after
    changed_count = 0
    empty_journey_count = 0
    backup_rotation_count = 0
    for key in game_keys_before & game_keys_after:
        if key in JSON_KEYS:
            old = decode_json(before[key])
            new = decode_json(after[key])
            if key in WALLET_KEYS and "journey" not in old and "journey" in new:
                if canonical_json(new["journey"]) == canonical_json(EMPTY_JOURNEY):
                    old = dict(old, journey=EMPTY_JOURNEY)
                    empty_journey_count += 1
            same = canonical_json(old) == canonical_json(new)
            if key == "orbitBloom.wallet.backup" and not same:
                # save() advances the recovery slot to exactly the preceding primary.
                # Every field of that preceding wallet is compared; no count/timer change is ignored.
                same = canonical_json(new) == canonical_json(decode_json(before["orbitBloom.wallet.v2"]))
                if same:
                    backup_rotation_count += 1
        else:
            same = strict_preference_equal(before[key], after[key])
        changed_count += not same
    system_keys = (set(before) | set(after)) - (game_keys_before | game_keys_after)
    system_changes = sum(key not in before or key not in after or
                         not strict_preference_equal(before[key], after[key]) for key in system_keys)
    preserved = matching_keys and changed_count == 0
    report.update({
        "passed": preserved,
        "savedGamePreferenceKeysUnchanged": matching_keys,
        "fullDecodedWalletPuzzleFarmInventoryReceiptsSettingsPreserved": preserved,
        "changedSavedGamePreferenceCount": changed_count,
        "newEmptyJourneyDefaultsAccepted": empty_journey_count,
        "recoveryBackupAdvancedToExactPreviousPrimary": backup_rotation_count == 1,
        "allowedSerializationNormalization": ["JSON dictionary key order", "Swift enum-key dictionary array order: collected, specials, tools"],
        "timersAndEveryGameplayFieldCompared": True,
        "otherArraysKeptInExactOrder": True,
        "nonGameplaySystemPreferenceChangeCount": system_changes,
        "note": "Primary playable state is compared in full. A normal recovery-slot rotation must match the preceding primary wallet exactly; a newly added empty journey may be accepted. StoreKit check time is system metadata.",
    })
    return report


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--before", type=Path, required=True)
    parser.add_argument("--after", type=Path, required=True)
    parser.add_argument("--phase", choices=["after-install", "after-launch"], required=True)
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()
    try:
        before, before_bytes = read_preferences(args.before)
        after, after_bytes = read_preferences(args.after)
        report = verify(before, after, args.phase, before_bytes, after_bytes)
    except Exception:
        # Never expose saved JSON, receipts, identity keys or paths in a failure.
        report = {"phase": args.phase, "passed": False, "failure": "Save comparison input could not be safely validated; inspect the private files locally."}
    text = json.dumps(report, indent=2, allow_nan=False)
    print(text)
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(text + "\n")
    return 0 if report["passed"] else 1


if __name__ == "__main__":
    sys.exit(main())
