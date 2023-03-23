#!/usr/bin/env zsh

brew tap wix/brew
brew install applesimutils
xcrun simctl shutdown all
TEST_DEVICE=$(xcrun simctl create test-device com.apple.CoreSimulator.SimDeviceType.iPhone-14-Pro com.apple.CoreSimulator.SimRuntime.iOS-16-2)
xcrun simctl boot $TEST_DEVICE
applesimutils --booted --bundle com.voipgrid.vialer --setPermissions contacts=YES,microphone=YES,notifications=YES
flutter test integration_test -d $TEST_DEVICE