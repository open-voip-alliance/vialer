#!/bin/bash
# Imports all variables from the READ_FILE (supplied as a command line argument) into the
# OUTPUT_FILE which is hard-coded to ".env".

set -e
READ_FILE=$1
OUTPUT_FILE=".env"

# Check if .env.example file exists
if [ -e "$READ_FILE" ]; then
  # Read each line in .env.example
  while IFS= read -r line || [ -n "$line" ]; do
    # Check if the line is in the correct format
    if [[ "$line" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]]; then
      # Extract the key and value from the line
      key="${line%%=*}"
      # shellcheck disable=SC1083
      value=$(eval echo \${"$key"})
      # Append the line to the .env file
      echo "$key=$value" >> "$OUTPUT_FILE"
    fi
  done < "$READ_FILE"

  echo "Imported all variables from $READ_FILE to $OUTPUT_FILE."
else
  echo "Error: $READ_FILE file not found."
fi
