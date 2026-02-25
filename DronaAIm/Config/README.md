# Config Folder

This folder contains sensitive configuration files that should NOT be committed to git.

## Contents

- **Amplify/**: Amplify configuration JSON files
  - `amplifyconfiguration.json`
  - `amplifyconfiguration-development.json`
  - `amplifyconfiguration-qa.json`
  - `amplifyconfiguration-preprod.json`

- **Firebase/**: Firebase/Google service configuration files
  - `GoogleService-Info.plist`
  - `GoogleService-Info-development.plist`
  - `GoogleService-Info-qa.plist`
  - `GoogleService-Info-preprod.plist`

- **SecureKeys.plist**: Secure API keys and sensitive credentials
  - `GMSApiKey`: Google Maps SDK API Key (production)
  - `GMSApiKey_Development`: Google Maps SDK API Key (development)
  - `GMSApiKey_QA`: Google Maps SDK API Key (QA)
  - `GMSApiKey_PreProd`: Google Maps SDK API Key (pre-production)
  - **Note**: This file contains sensitive keys and should NEVER be committed to git

- **Certificates & Provisioning Profiles**: 
  - `AppStore_com.dronaaim.dronaaim.mobileprovision`

## Setup Instructions for Team Members

### Option 1: Add files to Xcode project (Recommended)

1. Download the Config folder from OneDrive
2. Copy the `Config` folder to your project root (same level as DronaAIm.xcodeproj)
3. In Xcode, right-click on the project and select "Add Files to [ProjectName]"
4. Select the `Config` folder (or specific subfolders like `Config/Amplify`, `Config/Firebase`)
5. **Important**: Make sure "Copy items if needed" is checked
6. Ensure the files are added to the target's "Copy Bundle Resources" build phase
7. Files will be automatically bundled with the app and loaded at runtime
8. **For SecureKeys.plist**: Add `Config/SecureKeys.plist` to the project and ensure it's in "Copy Bundle Resources"

### Option 2: Copy to Documents directory (Advanced)

If you prefer to keep files outside the bundle:

1. After downloading Config folder from OneDrive, place files in the app's Documents directory
2. Files should be located at: `Documents/Config/Resources/[filename].json`
3. You can copy files programmatically or via iTunes File Sharing

## How It Works

The app will attempt to load configuration files in this order:

1. **App Bundle** (if files were added to Xcode project and bundled)
2. **Documents/Config/** (if files exist there - for external file management)

This allows flexibility in how team members manage these sensitive files.

### SecureKeys.plist Loading

The `SecureKeys.plist` file is loaded in this priority order:
1. `Bundle.main/Config/SecureKeys.plist` (if added to Xcode project)
2. `Documents/Config/SecureKeys.plist` (for external file management)
3. `Info.plist` (fallback for backward compatibility - not recommended)

**Important**: The app will crash on launch if `GMSApiKey` is not found in any of these locations.

## Note

These files are excluded from git via `.gitignore`. Always obtain them from the secure OneDrive location, never commit them to the repository.


