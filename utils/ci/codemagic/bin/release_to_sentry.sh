# Extract the Sentry version from file
set -e
sentry_version=$(cat SENTRY_VERSION)
if [ -z "$sentry_version" ]; then
  # Use Sentrys proposed version name as a fallback
  proposed_version=$(sentry-cli releases propose-version)
  sentry_version=$proposed_version
fi

# Report the new version to Sentry, include git commits and possibly finalize the release.
# By finalizing the release Sentry issues marked as 'Resolved in next release' mean this
# release.
sentry-cli releases new "$sentry_version"
sentry-cli releases set-commits "$sentry_version" --auto --ignore-missing
if [ "$FINALIZE_SENTRY_RELEASE" = true ] ; then
  sentry-cli releases finalize "$sentry_version"
fi