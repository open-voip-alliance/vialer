#!/bin/bash

if [[ $# -eq 0 && -z $PHRASE_ACCESS_TOKEN ]]; then
  echo "Error: PHRASE_ACCESS_TOKEN not provided."
  echo "Please set the PHRASE_ACCESS_TOKEN environment variable or provide it as a command line argument."
  echo "This should be a local environment variable, not one added to the .env file."
  echo "This token can be found in Keyhub under the name \"Phrase Strings Access Token\""
  echo "Alternatively, follow this link: https://keyhub.wearespindle.com/console/vaults/record-60000681-5d8d-4125-90f2-d3c66e4a4bf3-Phrase_Strings_Access_Token"
  echo "To set the environment variable, use: export PHRASE_ACCESS_TOKEN=your_token"
  return 1
fi

if [[ $# -eq 1 ]]; then
  PHRASE_ACCESS_TOKEN=$1
fi

if ! brew list -1 | grep -q "phrase-cli"; then
  brew install phrase-cli --quiet
fi
phrase pull -t "$PHRASE_ACCESS_TOKEN"
dart run build_runner build --delete-conflicting-outputs