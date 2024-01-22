set -e
eval $(ssh-agent -s)
echo "$FONT_AWESOME_KEY" | tr -d '\r' | ssh-add -
dart pub global activate onepub
onepub import
flutter packages pub get
. "$CM_BUILD_DIR"/utils/bin/strings.sh
dart run pigeon --input utils/pigeon/scheme.dart \
  --dart_out lib/app/util/pigeon.dart \
  --objc_header_out ios/Runner/pigeon.h \
  --objc_source_out ios/Runner/pigeon.m \
  --java_out android/app/src/main/java/com/voipgrid/vialer/Pigeon.java \
  --java_package com.voipgrid.vialer