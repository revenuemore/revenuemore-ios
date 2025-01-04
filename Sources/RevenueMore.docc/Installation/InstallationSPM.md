# Swift Package Manager (SPM)

Swift Package Manager (SPM) is a powerful tool for managing Swift project dependencies. This guide will walk you through the steps to integrate the **RevenueMore SDK** into your project using SPM.

## Prerequisites

- **Xcode 14.0** or later
- **Swift 5.9** or later
- An existing Xcode project targeting one or more of the following platforms:
  - **iOS:** 9.0 or later
  - **macOS:** 10.10 or later
  - **visionOS:** 1.0 or later
  - **tvOS:** 9.0 or later
  - **watchOS:** 9.0 or later

## Step-by-Step Integration

### Step 1: Open Your Project in Xcode

1. Launch **Xcode**.

2. Open your existing project or create a new one.

### Step 2: Add **RevenueMore** as a Swift Package

1. In Xcode, navigate to **File > Add Packages**.

    ![Add Packages](spm.png)

2. In the search bar, enter the **RevenueMore** repository URL:

```bash
https://github.com/revenuemore/revenuemore-ios
```

3. Press **Enter**. Xcode will fetch the package information.

4. Select the desired version from the version picker. It is recommended to use the latest stable release.

    ![Select Version](spm_version.png)

5. Click **Add Package** to integrate **RevenueMore** into your project.

@Metadata {
    @PageColor(purple)
}
