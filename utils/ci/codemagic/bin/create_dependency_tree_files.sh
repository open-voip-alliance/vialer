DIRECTORY="$CM_EXPORT_DIR/dependency_trees"
FLUTTER_FILE="$DIRECTORY/flutter.txt"
ANDROID_FILE="$DIRECTORY/android.txt"
mkdir -p "$DIRECTORY"
touch "$FLUTTER_FILE"
touch "$ANDROID_FILE"

flutter pub deps > "$FLUTTER_FILE"
pwd
cd android || exit
pwd
./gradlew app:dependencies > "$ANDROID_FILE"