##!/bin/sh

xcrun xcodebuild docbuild \
	-scheme RevenueMore \
	-destination 'generic/platform=iOS Simulator' \
	-derivedDataPath "$PWD/.derivedData"
	
xcrun docc process-archive transform-for-static-hosting \
	"$PWD/.derivedData/Build/Products/Debug-iphonesimulator/RevenueMore.doccarchive" \
	--output-path ".docs" \
	--hosting-base-path "https://revenuemore.github.io"
	
echo '<script>window.location.href += "/documentation/revenuemore"</script>' > .docs/index.html
