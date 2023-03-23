#!/usr/bin/env zsh

brew tap wix/brew
brew install applesimutils
xcrun simctl shutdown all
TEST_DEVICE=$(xcrun simctl create test-device com.apple.CoreSimulator.SimDeviceType.iPhone-14-Pro com.apple.CoreSimulator.SimRuntime.iOS-16-2)
xcrun simctl boot $TEST_DEVICE
applesimutils --booted --bundle com.voipgrid.vialer --setPermissions contacts=YES,microphone=YES,notifications=YES
for filename in integration_test/tests/**/*.dart; do
  flutter drive -t "$filename" --driver test_driver/integration_test.dart
done