#!/usr/bin/env zsh
CI_APK_PATH = "$FCI_BUILD_DIR/app/outputs/bundle/release/app-release-universal.apk"
if test -f "$CI_APK_PATH"; then
  flutter install --use-application-binary=$CI_APK_PATH
else
  flutter install
fi

adb shell pm grant com.voipgrid.vialer android.permission.CALL_PHONE
adb shell pm grant com.voipgrid.vialer android.permission.READ_CONTACTS
adb shell pm grant com.voipgrid.vialer android.permission.RECORD_AUDIO

function run_test {
  filename=$1
  echo "Starting test ${filename#"integration_test/tests/"}"
  flutter drive -t "$filename" --driver test_driver/integration_test.dart
}

setopt extended_glob

if [ -z "$1" ]; then
  for filename in integration_test/tests/**/*.dart; do
    run_test "$filename"
  done
else
  run_test "$1"
fi


