#!/bin/zsh
set -euo pipefail
cd "${0:A:h:h}"
# Keep automated test resets separate from the user's Orbit Bloom QA preview save.
ORBIT_TEST_DEVICE="${1:-6D8263A8-F049-48C0-AC3D-5FCBCFD3A3C7}"
if [[ "$ORBIT_TEST_DEVICE" != "6D8263A8-F049-48C0-AC3D-5FCBCFD3A3C7" ]]; then
  print -u2 "Resetting tests run only on Orbit Bloom Store QA. Run the iPad keep-progress tour separately."
  exit 2
fi
# Check the pinned runtime before compiling, and never substitute a personal device.
ORBIT_TEST_DEVICES="$(xcrun simctl list devices available --json)"
ORBIT_TEST_STATE="$(print -r -- "$ORBIT_TEST_DEVICES" | /usr/bin/python3 -c '
import json, sys
try:
    devices = json.load(sys.stdin)["devices"]
    if not isinstance(devices, dict):
        raise ValueError("devices must be an object")
    candidates = devices.get("com.apple.CoreSimulator.SimRuntime.iOS-26-1", [])
    if not isinstance(candidates, list) or any(not isinstance(d, dict) for d in candidates):
        raise ValueError("device list must contain objects")
except (ValueError, KeyError, TypeError):
    print("Could not read the simulator inventory. Tests stopped before compilation or boot.", file=sys.stderr)
    sys.exit(2)
matches = [d for d in candidates if d.get("udid") == sys.argv[1] and d.get("isAvailable") is True]
if len(matches) != 1:
    print("Orbit Bloom Store QA requires its available iOS 26.1 runtime and pinned device. "
          "Restore that runtime in Xcode and retry. The personal preview is not a test fallback.",
          file=sys.stderr)
    sys.exit(2)
if matches[0].get("state") not in ("Booted", "Shutdown"):
    print("Orbit Bloom Store QA is not ready. Wait for its current simulator operation and retry.", file=sys.stderr)
    sys.exit(2)
print(matches[0]["state"])
' "$ORBIT_TEST_DEVICE")"
ORBIT_TEST_RUN="$(date +%Y%m%d-%H%M%S)"
mkdir -p evidence
swift test
if [[ "$ORBIT_TEST_STATE" != "Booted" ]]; then
  xcrun simctl boot "$ORBIT_TEST_DEVICE"
fi
xcrun simctl bootstatus "$ORBIT_TEST_DEVICE" -b
xcodebuild -project OrbitBloom.xcodeproj -scheme OrbitBloom \
  -destination "platform=iOS Simulator,id=$ORBIT_TEST_DEVICE" \
  -derivedDataPath build/Verification12 -parallel-testing-enabled NO \
  -collect-test-diagnostics never \
  -only-testing:OrbitBloomTests \
  -resultBundlePath "evidence/Native-$ORBIT_TEST_RUN.xcresult" \
  test CODE_SIGNING_ALLOWED=NO
# Separate unit/UI runs retain readable reports and screenshots in current Xcode.
xcodebuild -project OrbitBloom.xcodeproj -scheme OrbitBloom \
  -destination "platform=iOS Simulator,id=$ORBIT_TEST_DEVICE" \
  -derivedDataPath build/Verification12 -parallel-testing-enabled NO \
  -collect-test-diagnostics never \
  -only-testing:OrbitBloomUITests/GameplayUITests \
  -only-testing:OrbitBloomUITests/SevenRoomsUITests \
  -resultBundlePath "evidence/Gameplay-$ORBIT_TEST_RUN.xcresult" \
  test CODE_SIGNING_ALLOWED=NO
