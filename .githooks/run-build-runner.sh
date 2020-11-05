#!/usr/bin/env bash
LC_ALL=C

printf "Running build runner to generate translation, chopper and moor files.\n"
flutter pub run build_runner build

exit 0