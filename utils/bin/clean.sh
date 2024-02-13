################################################################################
# Script: cleanup.sh
# Description:
#   This Bash script is used to clean up the Vialer project of all generated files, and any
#   empty directories they may leave behind when deleted.
#
# Usage:
#   1. Run this script from the project's root directory using `. utils/bin/clean.sh`
#   2. Optionally, use the flag '-n' or '--dry-run' for a dry run. This will
#      print the files that will be deleted without actually deleting them.
#
# Note: Make sure to review and test the script before using it on important
#       directories.
################################################################################

# Function to recursively delete files with specified suffixes
delete_files() {
    local dir="$1"
    local suffixes=(".g.dart" ".freezed.dart" ".chopper.dart" ".mocks.dart" ".i18n.dart" ".vialer.dart" ".config.dart" ".i18n.yaml")

    for suffix in "${suffixes[@]}"; do
        if [[ "$dry_run" == true ]]; then
            find "$dir" -type f -name "*$suffix" -exec echo "File to delete: {}" \;
        else
            find "$dir" -type f -name "*$suffix" -print -exec rm -f {} \;
        fi
    done
}

# Function to recursively delete empty directories
delete_empty_directories() {
    local dir="$1"

    if [[ "$dry_run" == true ]]; then
        find "$dir" -depth -type d -empty -exec echo "Directory to delete: {}" \;
    else
        find "$dir" -depth -type d -empty -print -exec rmdir {} \;
    fi
}

# Main function
main() {
    local current_dir=$(pwd)
    local dry_run=false

    # Check if script is run with dry-run option
    if [[ "$1" == "-n" || "$1" == "--dry-run" ]]; then
        dry_run=true
        echo "Running in dry run mode. No files or directories will be deleted."
    fi

    echo "Deleting files with specified suffixes in directory: $current_dir"
    # Recursively delete files with specified suffixes
    delete_files "$current_dir"

    echo "Deleting empty directories in directory: $current_dir"
    # Recursively delete empty directories
    delete_empty_directories "$current_dir"

    # Run the specified dart command
    if [[ "$dry_run" == false ]]; then
        echo "Running generators again"
        flutter clean
        flutter pub get
        utils/bin/pigeon.sh
        utils/bin/strings.sh
        dart run build_runner build --delete-conflicting-outputs
        dart run build_runner build --delete-conflicting-outputs
        echo "It is complete!"
    fi
}

# Call the main function with arguments
main "$@"