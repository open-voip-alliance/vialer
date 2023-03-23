#!/usr/bin/env zsh

brew tap wix/brew
brew install applesimutils
xcrun simctl shutdown all
TEST_DEVICE=$(xcrun simctl create test-device com.apple.CoreSimulator.SimDeviceType.iPhone-14-Pro com.apple.CoreSimulator.SimRuntime.iOS-16-2)
xcrun simctl boot $TEST_DEVICE
sleep 1
for filename in integration_test/tests/**/*.dart; do
  flutter -d $TEST_DEVICE install --debug
  applesimutils --booted --bundle com.voipgrid.vialer --setPermissions contacts=YES,microphone=YES,notifications=YES
  flutter test $filename -d $TEST_DEVICE
done