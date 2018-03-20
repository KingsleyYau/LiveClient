# Source file
PROJECT_DIR="$1"

EXAMPLE_INFO_PLIST_SOURCE_DIR="${PROJECT_DIR}/AccountSDK.framework"
EXAMPLE_INFO_PLIST_DESTINATION_DIR="${PROJECT_DIR}/Config"

# Copy example file from sdk
if [ ! -d "${EXAMPLE_INFO_PLIST_DESTINATION_DIR}" ]; then
mkdir "${EXAMPLE_INFO_PLIST_DESTINATION_DIR}"
fi

# Copy example file from sdk
cp -n "${EXAMPLE_INFO_PLIST_SOURCE_DIR}/config_urlschemes_info.plist" "${EXAMPLE_INFO_PLIST_DESTINATION_DIR}"
cp -n "${EXAMPLE_INFO_PLIST_SOURCE_DIR}/config_facebook_info.plist" "${EXAMPLE_INFO_PLIST_DESTINATION_DIR}"
cp -n "${EXAMPLE_INFO_PLIST_SOURCE_DIR}/config_twitter_info.plist" "${EXAMPLE_INFO_PLIST_DESTINATION_DIR}"

# Destination file
TMP_PLIST="${SRCROOT}/${PRODUCT_NAME}/tmp.plist"
INFO_PLIST="${SRCROOT}/${PRODUCT_NAME}/Info.plist"
URLSCHEMES_PLIST="${EXAMPLE_INFO_PLIST_DESTINATION_DIR}/config_urlschemes_info.plist"
FACEBOOK_PLIST="${EXAMPLE_INFO_PLIST_DESTINATION_DIR}/config_facebook_info.plist"
TWITTER_PLIST="${EXAMPLE_INFO_PLIST_DESTINATION_DIR}/config_twitter_info.plist"

echo "URLSCHEMES_PLIST : ${URLSCHEMES_PLIST}"
# Merge AccountSDK info plist
/usr/libexec/PlistBuddy -c "Merge \"$URLSCHEMES_PLIST\"" "$TMP_PLIST"
/usr/libexec/PlistBuddy -c "Merge \"$FACEBOOK_PLIST\"" "$TMP_PLIST"
/usr/libexec/PlistBuddy -c "Merge \"$TWITTER_PLIST\"" "$TMP_PLIST"
/usr/libexec/PlistBuddy -c "Merge \"$INFO_PLIST\"" "$TMP_PLIST"

# Remove tmp file
mv "$TMP_PLIST" "$INFO_PLIST"
rm -f "$TMP_PLIST"
