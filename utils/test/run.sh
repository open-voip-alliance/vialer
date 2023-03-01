#!/usr/bin/env zsh

if [[ "$CI" == "true" ]]; then
  echo "Building debug version of app for testing in CI mode"
  flutter build apk --debug --target=lib/app/main.dart
  flutter install --debug
else
  flutter install
fi

echo "Granting permissions"
adb shell pm grant com.voipgrid.vialer android.permission.CALL_PHONE
adb shell pm grant com.voipgrid.vialer android.permission.READ_CONTACTS
adb shell pm grant com.voipgrid.vialer android.permission.RECORD_AUDIO

function run_test {
  filename=$1
  echo "Starting test ${filename#"integration_test/tests/"}"
  if [[ "$CI" == "true" ]]; then
    flutter drive -t "$filename" --driver test_driver/integration_test.dart --debug
  else
    flutter drive -t "$filename" --driver test_driver/integration_test.dart
  fi
}

setopt extended_glob

if [ -z "$1" ]; then
  for filename in integration_test/tests/**/*.dart; do
    run_test "$filename"
  done
else
  run_test "$1"
fi


