#!/bin/bash

# Function to decode base64-encoded string
function entry_decode() { echo "${*}" | base64 --decode; }

# Read the contents of DART_DEFINES into an array
IFS=',' read -r -a define_items <<< "$DART_DEFINES"

# Create an empty array to store the lines that should be printed
output_items=()

# Loop through the array and decode each item
for index in "${!define_items[@]}"
do
    # Decode the base64-encoded string
    decoded_value=$(entry_decode "${define_items[$index]}")
    
    # Exclude lines starting with specific prefixes
    if [[ "$decoded_value" != flutter.inspector.structuredErrors* && "$decoded_value" != FLUTTER_WEB_AUTO_DETECT* && "$decoded_value" != FLUTTER_WEB_CANVASKIT_URL=* ]]; then
        # Add the decoded value to the output array
        output_items+=("$decoded_value")
    fi
done

# Print the non-empty items to the Xcode configuration file
printf "%s\n" "${output_items[@]}" > "${SRCROOT}/Flutter/thanksFlutterTeamToBreakBestWayToManageEnvironmentVariableOnYourLatestRelease.xcconfig"
