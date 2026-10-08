#!/bin/zsh
set -euo pipefail
cd "${0:A:h:h}"
# Keep automated test resets separate from the user's Orbit Bloom QA preview save.
ORBIT_TEST_DEVICE="${1:-6D8263A8-F049-48C0-AC3D-5FCBCFD3A3C7}"
ORBIT_TEST_RUN="$(date +%Y%m%d-%H%M%S)"
mkdir -p evidence
swift test
xcrun simctl boot "$ORBIT_TEST_DEVICE" 2>/dev/null || true
xcrun simctl bootstatus "$ORBIT_TEST_DEVICE" -b
xcodebuild -project OrbitBloom.xcodeproj -scheme OrbitBloom \
  -destination "platform=iOS Simulator,id=$ORBIT_TEST_DEVICE" \
  -derivedDataPath build/Verification -parallel-testing-enabled NO \
  -collect-test-diagnostics never \
  -resultBundlePath "evidence/Native-$ORBIT_TEST_RUN.xcresult" \
  test CODE_SIGNING_ALLOWED=NO
