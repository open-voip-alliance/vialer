set -e
eval $(ssh-agent -s)
echo "$FONT_AWESOME_KEY" | tr -d '\r' | ssh-add -
dart pub global activate onepub
onepub import
flutter packages pub get
. "$CM_BUILD_DIR"/utils/bin/strings.sh
. "$CM_BUILD_DIR"/utils/bin/pigeon.sh