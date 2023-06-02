set -e
echo "flutter.sdk=$HOME/programs/flutter" > "$FCI_BUILD_DIR/android/local.properties"
echo "$ANDROID_FIREBASE_SECRET" | base64 --decode > "$FCI_BUILD_DIR"/android/app/google-services.json
echo "$FCI_KEYSTORE" | base64 --decode > "$FCI_KEYSTORE_PATH"
flutter build appbundle -v --release \
 --target=lib/app/main.dart \
 --build-number="$BUILD_NR"  \
 --dart-define-from-file="brands/$BRAND.json" \
 --dart-define SEGMENT_ANDROID_KEY="$SEGMENT_ANDROID_WRITE_KEY"
android-app-bundle build-universal-apk \
  --ks "$FCI_KEYSTORE_PATH" \
  --ks-pass "$FCI_KEYSTORE_PASSWORD" \
  --ks-key-alias "$FCI_KEY_ALIAS" \
  --key-pass "$FCI_KEY_PASSWORD"