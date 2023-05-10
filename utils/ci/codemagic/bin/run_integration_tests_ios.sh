set -e # Ensures the script exits if any commands fail to execute
if [ ! -f "build/ios/ipa/Vialer.ipa" ]; then
    echo "Error: You must run the build_ipa script before running iOS integration tests"
    exit 1
fi
brew tap wix/brew && brew install applesimutils
xcrun simctl shutdown all
latestRuntime="$(xcrun simctl list runtimes | grep -o -E 'iOS [0-9.]*' | sort -r | head -n1 | tr -d '[:space:]')"
testDevice=$(xcrun simctl create integration-test-simulator com.apple.CoreSimulator.SimDeviceType.iPhone-14-Pro "$latestRuntime")
xcrun simctl boot "$testDevice"
# shellcheck disable=SC2044
for filename in $(find "integration_test/tests" -name "*.dart"); do
  flutter install --use-application-binary=build/ios/ipa/Vialer.ipa -d "$testDevice"
  applesimutils --booted --bundle com.voipgrid.vialer --setPermissions contacts=YES,microphone=YES,notifications=YES
  flutter drive -t "$filename" --driver test_driver/integration_test.dart -d "$testDevice" --dart-define-from-file="brands/$BRAND.json"
done