#!/usr/bin/env zsh
flutter install --debug

adb shell pm grant com.voipgrid.vialer android.permission.CALL_PHONE
adb shell pm grant com.voipgrid.vialer android.permission.READ_CONTACTS
adb shell pm grant com.voipgrid.vialer android.permission.RECORD_AUDIO

# With IN_TEST=true, the permission screens are shown but not requested during onboarding. Otherwise
# onboarding would not progress.
sed -i '' -e "s/^IN_TEST\=.*/IN_TEST\=true/g" .env

function run_test {
  filename=$1
  echo "Starting test ${filename#"integration_test/tests/"}"
  flutter drive -t "$filename" --driver test_driver/integration_test.dart
}

setopt extended_glob

if [ -z "$1" ]; then
  echo "\nRunning integration tests"
  for filename in integration_test/tests/**/*.dart; do
    run_test "$filename"
  done

  echo "\nRunning unit tests"
  flutter test
else
  run_test "$1"
fi

# Revert back, so when debugging the app, you will get the permission requests.
sed -i '' -e "s/^IN_TEST\=.*/IN_TEST\=false/g" .env