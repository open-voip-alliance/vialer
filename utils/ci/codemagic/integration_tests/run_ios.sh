#!/usr/bin/env zsh

brew tap wix/brew
brew install applesimutils
xcrun simctl shutdown all
TEST_DEVICE=$(xcrun simctl create test-device com.apple.CoreSimulator.SimDeviceType.iPhone-14-Pro com.apple.CoreSimulator.SimRuntime.iOS-16-2)
xcrun simctl boot $TEST_DEVICE
flutter pub get
pod repo update
export PATH="$PATH:/Users/builder/programs/flutter/bin/cache/dart-sdk/bin"
cd ios/ && pod install && cd ..
keychain initialize
app-store-connect fetch-signing-files $BUNDLE_ID \
--type $IOS_SIGNING_TYPE \
--create
keychain add-certificates
xcode-project use-profiles
flutter build ipa --debug \
--target=lib/app/main.dart \
--export-options-plist=/Users/builder/export_options.plist \
--build-number=$BUILD_NR \
--dart-define BRAND=$BRAND \
--dart-define SEGMENT_IOS_KEY=$SEGMENT_IOS_WRITE_KEY
for filename in integration_test/tests/**/*.dart; do
  flutter -d $TEST_DEVICE install --debug --verbose
  applesimutils --booted --bundle com.voipgrid.vialer --setPermissions contacts=YES,microphone=YES,notifications=YES
  flutter drive -t "$filename" --driver test_driver/integration_test.dart --debug
done