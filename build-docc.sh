##!/bin/sh

swift package resolve

xcodebuild docbuild -scheme RevenueMore -derivedDataPath /tmp/docbuild -destination 'generic/platform=iOS'

xcrun xcodebuild docbuild \
    -scheme RevenueMore \
    -destination 'generic/platform=iOS Simulator' \
    -derivedDataPath "$PWD/.derivedData"

$(xcrun --find docc) process-archive \
    transform-for-static-hosting /tmp/docbuild/Build/Products/Debug-iphoneos/RevenueMore.doccarchive \
    --output-path docs \
    --hosting-base-path 'revenuemore-ios'

echo "<script>window.location.href += \"/documentation/revenuemore\"</script>" > docs/index.html