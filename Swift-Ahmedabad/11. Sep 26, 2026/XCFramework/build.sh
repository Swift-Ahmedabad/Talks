#!/bin/sh

#  build.sh
#
#  Generic XCFramework build script.
#  Prompts for Project Path, Framework Name, Scheme Name, Bundle ID,
#  and which platforms to build (iOS, macOS, iPadOS).

set -e

echo "Enter Project Path:"
read -r PROJECT_PATH

if [ ! -d "${PROJECT_PATH}" ]; then
    echo "Error: Project path '${PROJECT_PATH}' does not exist."
    exit 1
fi

cd "${PROJECT_PATH}"

echo "Enter Framework Name:"
read -r FRAMEWORK_NAME

echo "Enter Scheme Name:"
read -r SCHEME_NAME

echo "Enter Product Name (framework binary name, usually same as Framework Name):"
read -r PRODUCT_NAME

echo "Enter Bundle ID:"
read -r BUNDLE_ID

echo "Enter Output Directory (where the .xcframework will be saved):"
read -r OUTPUT_DIR

if [ ! -d "${OUTPUT_DIR}" ]; then
    echo "Error: Output directory '${OUTPUT_DIR}' does not exist."
    exit 1
fi

echo "Build for iOS? (yes/no):"
read -r BUILD_IOS

echo "Build for macOS? (yes/no):"
read -r BUILD_MACOS

echo "Build for iPadOS? (yes/no):"
read -r BUILD_IPADOS

XCFRAMEWORK_NAME="${FRAMEWORK_NAME}.xcframework"
ARCHIVE_DIR=".archives"
DERIVED_DATA_DIR=".DerivedData"

if [ -d "${XCFRAMEWORK_NAME}" ]; then
    rm -rf "${XCFRAMEWORK_NAME}"
fi

if [ -d "${ARCHIVE_DIR}" ]; then
    rm -rf "${ARCHIVE_DIR}"
fi

if [ "${BUILD_IOS}" = "yes" ]; then
    xcodebuild archive \
      -scheme "${SCHEME_NAME}" \
      -destination "generic/platform=iOS" \
      -archivePath "${ARCHIVE_DIR}/${FRAMEWORK_NAME}-iOS" \
      SKIP_INSTALL=NO \
      -derivedDataPath "${DERIVED_DATA_DIR}"
fi

if [ "${BUILD_MACOS}" = "yes" ]; then
    xcodebuild archive \
      -scheme "${SCHEME_NAME}" \
      -destination "generic/platform=macOS" \
      -archivePath "${ARCHIVE_DIR}/${FRAMEWORK_NAME}-macOS" \
      SKIP_INSTALL=NO \
      -derivedDataPath "${DERIVED_DATA_DIR}"
fi

if [ "${BUILD_IPADOS}" = "yes" ]; then
    xcodebuild archive \
      -scheme "${SCHEME_NAME}" \
      -destination "generic/platform=iOS" \
      -archivePath "${ARCHIVE_DIR}/${FRAMEWORK_NAME}-iPadOS" \
      SKIP_INSTALL=NO \
      -derivedDataPath "${DERIVED_DATA_DIR}"
fi

XCFRAMEWORK_CMD="xcodebuild -create-xcframework -allow-internal-distribution"

if [ "${BUILD_IOS}" = "yes" ]; then
    IOS_FRAMEWORK=$(find "${ARCHIVE_DIR}/${FRAMEWORK_NAME}-iOS.xcarchive/Products" -name "${PRODUCT_NAME}.framework" -type d | head -1)
    XCFRAMEWORK_CMD="${XCFRAMEWORK_CMD} -framework ${IOS_FRAMEWORK}"
fi

if [ "${BUILD_MACOS}" = "yes" ]; then
    MACOS_FRAMEWORK=$(find "${ARCHIVE_DIR}/${FRAMEWORK_NAME}-macOS.xcarchive/Products" -name "${PRODUCT_NAME}.framework" -type d | head -1)
    XCFRAMEWORK_CMD="${XCFRAMEWORK_CMD} -framework ${MACOS_FRAMEWORK}"
fi

if [ "${BUILD_IPADOS}" = "yes" ]; then
    IPADOS_FRAMEWORK=$(find "${ARCHIVE_DIR}/${FRAMEWORK_NAME}-iPadOS.xcarchive/Products" -name "${PRODUCT_NAME}.framework" -type d | head -1)
    XCFRAMEWORK_CMD="${XCFRAMEWORK_CMD} -framework ${IPADOS_FRAMEWORK}"
fi

XCFRAMEWORK_CMD="${XCFRAMEWORK_CMD} -output ${OUTPUT_DIR}/${XCFRAMEWORK_NAME}"

eval "${XCFRAMEWORK_CMD}"
