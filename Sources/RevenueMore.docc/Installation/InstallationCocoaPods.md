# CocoaPods

CocoaPods is a dependency manager for Swift and Objective-C Cocoa projects. This guide provides detailed instructions on how to integrate the **RevenueMore SDK** into your project using CocoaPods.

## Prerequisites

- **Xcode 15.0** or later
- **CocoaPods 1.10.0** or later
- An existing Xcode project targeting one or more of the following platforms:
  - **iOS:** 9.0 or later
  - **macOS:** 10.10 or later
  - **visionOS:** 1.0 or later
  - **tvOS:** 9.0 or later
  - **watchOS:** 9.0 or later

## Step-by-Step Integration

### Step 1: Install CocoaPods (If Not Already Installed)

If you haven't installed CocoaPods yet, open your terminal and run:

```bash
sudo gem install cocoapods
```

### Step 2: Navigate to Your Project Directory

Open your terminal and navigate to the root directory of your Xcode project:

```bash
cd /path/to/YourProject
```

### Step 3: Initialize CocoaPods in Your Project

Navigate to your project directory and run:

```bash
pod init
```
### Step 4: Edit the Podfile

Open the generated Podfile in your preferred text editor and configure it to include **RevenueMore** for the supported platforms.

**Example Podfile**
```ruby
# Podfile

# Specify the minimum platform versions for each target
platform :ios, '9.0'
platform :osx, '10.10'
platform :visionos, '1.0'
platform :tvos, '9.0'
platform :watchos, '9.0'

# Enable framework usage
use_frameworks!

# iOS Target
target 'YourApp_iOS' do
  platform :ios, '9.0'
  
  # RevenueMore SDK
  pod 'RevenueMore', '~> 1.0'
end

# macOS Target
target 'YourApp_macOS' do
  platform :osx, '10.10'
  
  # RevenueMore SDK
  pod 'RevenueMore', '~> 1.0'
end

# visionOS Target
target 'YourApp_visionOS' do
  platform :visionos, '1.0'
  
  # RevenueMore SDK
  pod 'RevenueMore', '~> 1.0'
end

# tvOS Target
target 'YourApp_tvOS' do
  platform :tvos, '9.0'
  
  # RevenueMore SDK
  pod 'RevenueMore', '~> 1.0'
end

# watchOS Target
target 'YourApp_watchOS' do
  platform :watchos, '9.0'
  
  # RevenueMore SDK
  pod 'RevenueMore', '~> 1.0'
end
```

### Step 5: Install the Pods

After configuring the Podfile, run the following command in your terminal to install the **RevenueMore** pod:

```bash
pod install
```



**Step 5: Open the .xcworkspace File**

After installation, open the .xcworkspace file to work with your project:
```bash
open YourProject.xcworkspace
```
@Metadata {
    @PageColor(purple)
}
