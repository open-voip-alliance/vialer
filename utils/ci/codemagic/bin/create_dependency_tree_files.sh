directory=$CM_EXPORT_DIR/dependency_trees
flutterFile = $directory/flutter.txt
androidFile = $directory/android.txt
mkdir -p $directory
touch $flutterFile
touch $androidFile

flutter pub deps > $$flutterFile
cd android
./gradlew app:dependencies > $$androidFile