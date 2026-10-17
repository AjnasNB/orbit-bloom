"""Exercise the runner's device boundary without booting or changing a simulator."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]
RUNNER = ROOT / "scripts/test-ios.sh"
STORE = "6D8263A8-F049-48C0-AC3D-5FCBCFD3A3C7"
PREVIEW = "64173F47-C4DC-46B4-82EC-0027675F7780"
RUNTIME = "com.apple.CoreSimulator.SimRuntime.iOS-26-1"


class RunnerSafetyTests(unittest.TestCase):
    def run_runner(self, inventory=None, device=None, inventory_status=0, boot_status=0):
        if inventory is None:
            inventory = {"devices": {RUNTIME: [{
                "udid": STORE, "state": "Shutdown", "isAvailable": True,
            }]}}
        with tempfile.TemporaryDirectory(prefix="orbit-runner-test-") as folder:
            path = Path(folder)
            payload = inventory if isinstance(inventory, str) else json.dumps(inventory)
            (path / "inventory.json").write_text(payload)
            (path / "calls.jsonl").touch()
            # All commands capable of compiling, booting or running tests are stubs.
            stub = '''#!/usr/bin/python3
import json, os, pathlib, sys
folder = pathlib.Path(os.environ["ORBIT_RUNNER_FIXTURE"])
command = pathlib.Path(sys.argv[0]).name
args = sys.argv[1:]
with (folder / "calls.jsonl").open("a") as handle:
    handle.write(json.dumps([command] + args) + "\\n")
if command == "xcrun" and args[:3] == ["simctl", "list", "devices"]:
    sys.stdout.write((folder / "inventory.json").read_text())
    sys.exit(int(os.environ["ORBIT_INVENTORY_STATUS"]))
if command == "xcrun" and args[:2] == ["simctl", "boot"]:
    sys.exit(int(os.environ["ORBIT_BOOT_STATUS"]))
'''
            for command in ("xcrun", "swift", "xcodebuild"):
                executable = path / command
                executable.write_text(stub)
                executable.chmod(0o755)
            environment = dict(os.environ, PATH=str(path) + os.pathsep + os.environ["PATH"],
                ORBIT_RUNNER_FIXTURE=str(path), ORBIT_INVENTORY_STATUS=str(inventory_status),
                ORBIT_BOOT_STATUS=str(boot_status))
            args = ["/bin/zsh", str(RUNNER)] + ([] if device is None else [device])
            result = subprocess.run(args, env=environment, capture_output=True, text=True,
                                    timeout=15)
            calls = [json.loads(line) for line in (path / "calls.jsonl").read_text().splitlines()]
            return result, calls

    def assert_preflight_stops(self, inventory, message):
        result, calls = self.run_runner(inventory)
        self.assertEqual(result.returncode, 2, result.stderr)
        self.assertIn(message, result.stderr)
        self.assertEqual(calls, [["xcrun", "simctl", "list", "devices", "available", "--json"]])

    def test_missing_runtime_does_not_compile_boot_or_fall_back_to_preview(self):
        self.assert_preflight_stops({"devices": {
            "com.apple.CoreSimulator.SimRuntime.iOS-26-5": [{
                "udid": PREVIEW, "isAvailable": True, "state": "Shutdown",
            }]}}, "iOS 26.1")

    def test_store_uuid_on_another_runtime_is_rejected(self):
        self.assert_preflight_stops({"devices": {
            "com.apple.CoreSimulator.SimRuntime.iOS-26-5": [{
                "udid": STORE, "isAvailable": True, "state": "Shutdown",
            }]}}, "iOS 26.1")

    def test_unavailable_store_device_is_rejected(self):
        self.assert_preflight_stops({"devices": {RUNTIME: [{
            "udid": STORE, "isAvailable": False, "state": "Shutdown",
        }]}}, "iOS 26.1")

    def test_malformed_inventory_is_rejected(self):
        self.assert_preflight_stops("not JSON", "Could not read")

    def test_unexpected_inventory_shape_is_rejected(self):
        self.assert_preflight_stops({"devices": []}, "Could not read")

    def test_busy_store_device_stops_without_compiling_or_booting(self):
        self.assert_preflight_stops({"devices": {RUNTIME: [{
            "udid": STORE, "isAvailable": True, "state": "Shutting Down",
        }]}}, "not ready")

    def test_preview_argument_is_rejected_before_inventory(self):
        result, calls = self.run_runner(device=PREVIEW)
        self.assertEqual(result.returncode, 2, result.stderr)
        self.assertIn("only on Orbit Bloom Store QA", result.stderr)
        self.assertEqual(calls, [])

    def test_inventory_command_failure_cannot_reach_compilation(self):
        result, calls = self.run_runner(inventory_status=1)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(len(calls), 1)
        self.assertEqual(calls[0][:4], ["xcrun", "simctl", "list", "devices"])

    def test_ready_store_device_keeps_native_and_ui_runs_on_store_only(self):
        result, calls = self.run_runner()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls[0], ["xcrun", "simctl", "list", "devices", "available", "--json"])
        self.assertIn(["swift", "test"], calls)
        self.assertIn(["xcrun", "simctl", "boot", STORE], calls)
        self.assertIn(["xcrun", "simctl", "bootstatus", STORE, "-b"], calls)
        builds = [call for call in calls if call[0] == "xcodebuild"]
        self.assertEqual(len(builds), 2)
        for call in builds:
            self.assertIn("platform=iOS Simulator,id=" + STORE, call)
            self.assertNotIn(PREVIEW, " ".join(call))
        self.assertIn("-only-testing:OrbitBloomTests", builds[0])
        self.assertIn("-only-testing:OrbitBloomUITests/SevenRoomsUITests", builds[1])

    def test_already_booted_device_is_not_booted_twice(self):
        result, calls = self.run_runner({"devices": {RUNTIME: [{
            "udid": STORE, "isAvailable": True, "state": "Booted",
        }]}})
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn(["xcrun", "simctl", "boot", STORE], calls)
        self.assertIn(["xcrun", "simctl", "bootstatus", STORE, "-b"], calls)

    def test_failed_boot_stops_before_native_or_ui_tests(self):
        result, calls = self.run_runner(boot_status=1)
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(any(call[0] == "xcodebuild" for call in calls))
        self.assertNotIn(["xcrun", "simctl", "bootstatus", STORE, "-b"], calls)


if __name__ == "__main__":
    unittest.main(verbosity=2)
