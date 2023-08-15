flutter pub deps > $CM_EXPORT_DIR/dependency_trees/flutter.txt
cd android
./gradlew app:dependencies > $CM_EXPORT_DIR/dependency_trees/android.txt