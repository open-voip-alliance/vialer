#!/usr/bin/env sh

get_env() {
  grep "$1" .env | cut -d '=' -f2
}

SEGMENT_ANDROID_WRITE_KEY=$(get_env "SEGMENT_ANDROID_WRITE_KEY")
SEGMENT_IOS_WRITE_KEY=$(get_env "SEGMENT_IOS_WRITE_KEY")

perl -i -pe's/<meta-data android:name="com.claimsforce.segment.WRITE_KEY" android:value="SEGMENT_WRITE_KEY" \/>/<meta-data android:name="com.claimsforce.segment.WRITE_KEY" android:value="'"$SEGMENT_ANDROID_WRITE_KEY"'" \/>/g' \
  android/app/src/main/AndroidManifest.xml

perl -i -pe's/<string>SEGMENT_WRITE_KEY<\/string>/<string>'"$SEGMENT_IOS_WRITE_KEY"'<\/string>/g' \
  ios/Runner/Info.plist