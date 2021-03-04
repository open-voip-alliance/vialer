# Vialer Lite

Lite version of Vialer.

## Development

To test Sentry, copy `.env.example` to `.env`, and fill in a value for `SENTRY_DSN`.

To test Segment, when running `flutter run` or `flutter build` pass
`--dart-define SEGMENT_ANDROID_KEY=XYZ --dart-define SEGMENT_IOS_KEY=UVW`
to set the keys for Android and iOS.
