set -e
flutter pub get
pod repo update
export PATH="$PATH:/Users/builder/programs/flutter/bin/cache/dart-sdk/bin"
cd ios/ && pod install && cd ..
keychain initialize
app-store-connect fetch-signing-files "$BUNDLE_ID" \
--type "$IOS_SIGNING_TYPE" \
--create
keychain add-certificates
xcode-project use-profiles
flutter build ipa --release \
--target=lib/presentation/main.dart \
--export-options-plist=/Users/builder/export_options.plist \
--build-number="$BUILD_NR" \
--dart-define-from-file="brands/$BRAND.json" \
--dart-define SEGMENT_IOS_KEY="$SEGMENT_IOS_WRITE_KEY"