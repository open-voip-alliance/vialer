#!/usr/bin/env zsh

if [[ "$CI" == "true" ]]; then
  echo "Building debug version of app for testing in CI mode"
  flutter build apk --debug --target=lib/app/main.dart --dart-define-from-file=brands/vialer.json
  flutter install --debug
else
  flutter install
fi

echo "Granting permissions"
adb shell pm grant com.voipgrid.vialer android.permission.CALL_PHONE
adb shell pm grant com.voipgrid.vialer android.permission.READ_CONTACTS
adb shell pm grant com.voipgrid.vialer android.permission.RECORD_AUDIO
adb shell pm grant com.voipgrid.vialer android.permission.BLUETOOTH_CONNECT
adb shell pm grant com.voipgrid.vialer android.permission.POST_NOTIFICATIONS

# With IN_TEST=true, the permission screens are shown but not requested during onboarding. Otherwise
# onboarding would not progress.
sed -i '' -e "s/^IN_TEST\=.*/IN_TEST\=true/g" .env

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
  echo "\nRunning integration tests"
  for filename in integration_test/tests/**/*.dart; do
    run_test "$filename"
  done

  echo "\nRunning unit tests"
  if [[ "$CI" != "true" ]]; then
    flutter test
  fi
else
  run_test "$1"
fi

# Revert back, so when debugging the app, you will get the permission requests.
sed -i '' -e "s/^IN_TEST\=.*/IN_TEST\=false/g" .env
