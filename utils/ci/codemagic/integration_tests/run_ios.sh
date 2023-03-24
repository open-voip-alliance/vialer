#!/usr/bin/env zsh

if [ ! -f "build/ios/ipa/Vialer.ipa" ]; then
    echo "Error: You must run the build_ipa script before running iOS integration tests"
    exit 1
fi
brew tap wix/brew
brew install applesimutils
xcrun simctl shutdown all
TEST_DEVICE=$(xcrun simctl create test-device com.apple.CoreSimulator.SimDeviceType.iPhone-14-Pro com.apple.CoreSimulator.SimRuntime.iOS-16-2)
xcrun simctl boot $TEST_DEVICE
for filename in integration_test/tests/**/*.dart; do
  flutter install --verbose --use-application-binary=build/ios/ipa/Vialer.ipa -d $TEST_DEVICE
  applesimutils --booted --bundle com.voipgrid.vialer --setPermissions contacts=YES,microphone=YES,notifications=YES
  flutter drive -t "$filename" --driver test_driver/integration_test.dart -d $TEST_DEVICE
done