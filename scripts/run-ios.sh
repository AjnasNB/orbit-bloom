#!/bin/zsh
set -euo pipefail
cd "${0:A:h:h}"
ORBIT_DEVICE="${1:-64173F47-C4DC-46B4-82EC-0027675F7780}"
xcodebuild -project OrbitBloom.xcodeproj -scheme OrbitBloom -destination "platform=iOS Simulator,id=$ORBIT_DEVICE" -derivedDataPath build/DerivedData build CODE_SIGNING_ALLOWED=NO
xcrun simctl install "$ORBIT_DEVICE" build/DerivedData/Build/Products/Debug-iphonesimulator/OrbitBloom.app
xcrun simctl launch "$ORBIT_DEVICE" com.orbitbloom.game
