#!/bin/bash

#
# RevenueMore iOS SDK - Quick Run Script
# Opens Xcode with the Sample Project and builds for the selected device.
#
# Usage:
#   ./scripts/quick-run.sh
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SAMPLE_PROJECT="${PROJECT_ROOT}/Examples/SampleProject"
XCODE_PROJECT="${SAMPLE_PROJECT}/SampleProject.xcodeproj"

echo "Opening RevenueMore Sample Project in Xcode..."
echo ""
echo "Next steps:"
echo "  1. Select your iOS device as the run destination"
echo "  2. Go to Signing & Capabilities"
echo "  3. Select your Development Team"
echo "  4. Press Cmd+R to build and run"
echo ""
echo "The SDK is linked as a local package, so any changes you make"
echo "to the SDK source files will be automatically included in the build."
echo ""

open "$XCODE_PROJECT"
