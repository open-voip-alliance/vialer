# Vialer Lite

Lite version of Vialer.

## Development

To test Sentry, copy `.env.example` to `.env`, and fill in a value for `SENTRY_DSN`.

To test Segment, copy `.env.example` to `.env`, and fill in a value for `SEGMENT_ANDROID_WRITE_KEY`
and `SEGMENT_IOS_WRITE_KEY`, then run:

```shell script
./set_segment_write_key.sh
```

Which will set the correct values for the keys in `AndroidManifest.xml` and `Info.plist` for
Android and iOS respectively. Do **not** commit these changes that include the keys.
