DIRECTORY="$CM_EXPORT_DIR"
FLUTTER_FILE="$DIRECTORY/flutter.txt"
ANDROID_FILE="$DIRECTORY/android.txt"
COMBINED_FILE="$DIRECTORY/combined.txt"
mkdir -p "$DIRECTORY"
touch "$FLUTTER_FILE"
touch "$ANDROID_FILE"
touch "$COMBINED_FILE"

flutter pub deps > "$FLUTTER_FILE"
cd android || exit
./gradlew app:dependencies > "$ANDROID_FILE"
cd ../
cat "$FLUTTER_FILE" "$ANDROID_FILE" > "$COMBINED_FILE"