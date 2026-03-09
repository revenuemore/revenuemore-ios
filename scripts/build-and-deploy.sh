#!/bin/bash

#
# RevenueMore iOS SDK - Build and Deploy Script
# This script builds the SDK and Sample App, then deploys to a connected iOS device.
#
# Usage:
#   ./scripts/build-and-deploy.sh [options]
#
# Options:
#   --release       Build in Release configuration (default: Debug)
#   --simulator     Build for simulator instead of device
#   --clean         Clean build folder before building
#   --watch         Watch for changes and auto-rebuild
#   --help          Show this help message
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SAMPLE_PROJECT="${PROJECT_ROOT}/Examples/SampleProject"
XCODE_PROJECT="${SAMPLE_PROJECT}/SampleProject.xcodeproj"
SCHEME="SampleProject-iOS"
BUILD_DIR="${PROJECT_ROOT}/build"
CONFIGURATION="Debug"
DESTINATION="generic/platform=iOS"
BUILD_FOR_DEVICE=true

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --release)
            CONFIGURATION="Release"
            shift
            ;;
        --simulator)
            BUILD_FOR_DEVICE=false
            DESTINATION="platform=iOS Simulator,name=iPhone 15 Pro"
            shift
            ;;
        --clean)
            CLEAN_BUILD=true
            shift
            ;;
        --watch)
            WATCH_MODE=true
            shift
            ;;
        --help)
            head -20 "$0" | tail -16
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Functions
print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}$1${NC}"
}

print_warning() {
    echo -e "${YELLOW}$1${NC}"
}

print_error() {
    echo -e "${RED}$1${NC}"
}

# Check for connected device
check_device() {
    if [ "$BUILD_FOR_DEVICE" = true ]; then
        print_header "Checking for connected iOS device..."

        # List connected devices
        DEVICES=$(xcrun xctrace list devices 2>&1 | grep -E "iPhone|iPad" | grep -v "Simulator" || true)

        if [ -z "$DEVICES" ]; then
            print_warning "No iOS device connected. Available simulators:"
            xcrun simctl list devices available | grep -E "iPhone|iPad" | head -10
            echo ""
            print_warning "Run with --simulator flag to build for simulator."
            exit 1
        fi

        echo "Connected devices:"
        echo "$DEVICES"
        echo ""

        # Get first connected device UDID
        DEVICE_UDID=$(xcrun xctrace list devices 2>&1 | grep -E "iPhone|iPad" | grep -v "Simulator" | head -1 | grep -oE "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}|[0-9a-f]{40}" || true)

        if [ -n "$DEVICE_UDID" ]; then
            DESTINATION="id=${DEVICE_UDID}"
            print_success "Will deploy to device: $DEVICE_UDID"
        fi
    fi
}

# Clean build folder
clean_build() {
    if [ "$CLEAN_BUILD" = true ]; then
        print_header "Cleaning build folder..."
        rm -rf "$BUILD_DIR"
        xcodebuild clean \
            -project "$XCODE_PROJECT" \
            -scheme "$SCHEME" \
            -configuration "$CONFIGURATION" \
            2>/dev/null || true
        print_success "Build folder cleaned."
    fi
}

# Build the project
build_project() {
    print_header "Building $SCHEME ($CONFIGURATION)..."

    mkdir -p "$BUILD_DIR"

    # Build command
    xcodebuild build \
        -project "$XCODE_PROJECT" \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        -destination "$DESTINATION" \
        -derivedDataPath "$BUILD_DIR" \
        CODE_SIGN_IDENTITY="-" \
        CODE_SIGNING_ALLOWED=NO \
        2>&1 | xcpretty || xcodebuild build \
        -project "$XCODE_PROJECT" \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        -destination "$DESTINATION" \
        -derivedDataPath "$BUILD_DIR" \
        CODE_SIGN_IDENTITY="-" \
        CODE_SIGNING_ALLOWED=NO

    print_success "Build completed successfully!"
}

# Build and run on device (signed)
build_and_run_on_device() {
    print_header "Building and running on device..."

    # This requires proper code signing setup in Xcode
    xcodebuild build \
        -project "$XCODE_PROJECT" \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        -destination "$DESTINATION" \
        -derivedDataPath "$BUILD_DIR" \
        2>&1 | xcpretty || xcodebuild build \
        -project "$XCODE_PROJECT" \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        -destination "$DESTINATION" \
        -derivedDataPath "$BUILD_DIR"

    print_success "Build completed! The app should be installed on your device."
}

# Watch for changes
watch_and_rebuild() {
    print_header "Watching for changes..."
    print_warning "Press Ctrl+C to stop watching."

    # Watch Sources directory for changes
    fswatch -o "${PROJECT_ROOT}/Sources" "${SAMPLE_PROJECT}" | while read; do
        echo ""
        print_warning "Changes detected, rebuilding..."
        build_project
    done
}

# Install on device using ios-deploy (if available)
install_on_device() {
    if command -v ios-deploy &> /dev/null; then
        print_header "Installing on device with ios-deploy..."

        APP_PATH=$(find "$BUILD_DIR" -name "*.app" -path "*/Debug-iphoneos/*" | head -1)

        if [ -n "$APP_PATH" ]; then
            ios-deploy --bundle "$APP_PATH" --debug
        else
            print_warning "Could not find built app. Make sure code signing is configured."
        fi
    else
        print_warning "ios-deploy not found. Install with: brew install ios-deploy"
        print_warning "Or use Xcode directly: Product > Run"
    fi
}

# Main execution
main() {
    print_header "RevenueMore iOS SDK - Build & Deploy"

    echo "Configuration:"
    echo "  Project: $XCODE_PROJECT"
    echo "  Scheme: $SCHEME"
    echo "  Configuration: $CONFIGURATION"
    echo "  Build for device: $BUILD_FOR_DEVICE"
    echo ""

    check_device
    clean_build

    if [ "$WATCH_MODE" = true ]; then
        build_project
        watch_and_rebuild
    else
        if [ "$BUILD_FOR_DEVICE" = true ]; then
            build_and_run_on_device
        else
            build_project
        fi
    fi

    print_header "Done!"
    echo "Next steps:"
    echo "  1. Open Xcode: open '${XCODE_PROJECT}'"
    echo "  2. Select your device as destination"
    echo "  3. Set your Development Team in Signing & Capabilities"
    echo "  4. Press Cmd+R to build and run"
    echo ""
}

main
