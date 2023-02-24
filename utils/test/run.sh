#!/usr/bin/env zsh

# We're going to check if we're currently running on Codemagic, and if we are we will specify
# a specific apk to use for the tests.
CI_APK_PATH="build/app/outputs/bundle/release/app-release-universal.apk"
echo $CI_APK_PATH
if test -f "$CI_APK_PATH"; then
  flutter install --uninstall-only
  flutter install --use-application-binary=$CI_APK_PATH
  echo "Installed app"
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
  flutter drive -t "$filename" --driver test_driver/integration_test.dart --use-application-binary=$CI_APK_PATH
}

setopt extended_glob

if [ -z "$1" ]; then
  for filename in integration_test/tests/**/*.dart; do
    run_test "$filename"
  done
else
  run_test "$1"
fi


