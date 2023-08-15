touch $CM_EXPORT_DIR/dependency_trees/flutter.txt
flutter pub deps > $CM_EXPORT_DIR/dependency_trees/flutter.txt
cd android
touch $CM_EXPORT_DIR/dependency_trees/android.txt
./gradlew app:dependencies > $CM_EXPORT_DIR/dependency_trees/android.txt