# How to Build APK for Mobile Marketplace App

## Prerequisites

### 1. Install Java Development Kit (JDK)

Your system needs JDK 11 or higher to build the APK.

**Download and Install:**
1. Go to: https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html
2. Download "Windows x64 Installer" (jdk-17_windows-x64_bin.exe)
3. Run the installer
4. Note the installation path (usually: `C:\Program Files\Java\jdk-17`)

**Set JAVA_HOME Environment Variable:**
1. Press `Win + X` → Select "System"
2. Click "Advanced system settings"
3. Click "Environment Variables"
4. Under "System variables", click "New"
5. Variable name: `JAVA_HOME`
6. Variable value: `C:\Program Files\Java\jdk-17` (or your JDK path)
7. Click OK
8. Find "Path" in System variables, click "Edit"
9. Click "New" and add: `%JAVA_HOME%\bin`
10. Click OK on all windows
11. **Restart PowerShell/Terminal**

**Verify Installation:**
```powershell
java -version
```
Should show: `java version "17.x.x"`

---

## Building the APK

Once Java is installed and configured, follow these steps:

### Option 1: Build Split APKs (Recommended - Smaller file sizes)

```powershell
cd e:\Marketplace\flutter_application_1\MobileDev
flutter build apk --split-per-abi
```

This creates 3 APK files (one for each CPU architecture):
- `app-armeabi-v7a-release.apk` (for older 32-bit devices)
- `app-arm64-v8a-release.apk` (for most modern Android devices) ⭐ **Use this one**
- `app-x86_64-release.apk` (for Android emulators)

**Location:** `e:\Marketplace\flutter_application_1\MobileDev\build\app\outputs\flutter-apk\`

### Option 2: Build Single Universal APK (Larger but works on all devices)

```powershell
cd e:\Marketplace\flutter_application_1\MobileDev
flutter build apk
```

This creates one APK that works on all devices (but is larger):
- `app-release.apk`

**Location:** `e:\Marketplace\flutter_application_1\MobileDev\build\app\outputs\flutter-apk\`

---

## Installing the APK on Your Phone

### Method 1: Direct Transfer (USB Cable)

1. Connect your phone to computer via USB
2. Enable "File Transfer" mode on your phone
3. Copy the APK file to your phone (e.g., to Downloads folder)
4. On your phone:
   - Open the APK file using a file manager
   - Tap "Install"
   - If prompted, enable "Install from unknown sources"

### Method 2: Google Drive / Cloud Storage

1. Upload the APK to Google Drive or any cloud storage
2. On your phone:
   - Open Google Drive app
   - Download the APK
   - Open and install

### Method 3: Email

1. Email the APK to yourself
2. Open email on your phone
3. Download and install the APK

---

## Important Notes

### ⚠️ Before Building for Production

1. **Create a Signing Key** (for Google Play Store):
   ```powershell
   keytool -genkey -v -keystore c:\Users\YourName\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. **Create `key.properties`** in `android` folder:
   ```properties
   storePassword=YOUR_PASSWORD
   keyPassword=YOUR_PASSWORD
   keyAlias=upload
   storeFile=c:\\Users\\YourName\\upload-keystore.jks
   ```

3. **Update `build.gradle.kts`** to use the signing key

### 📱 Current App Configuration

- **App Name:** Mobile Marketplace
- **Package Name:** com.marketplace.mobiledev
- **Version:** 1.0.0 (Build 1)
- **Minimum Android:** 5.0 (API 21)
- **Target Android:** 14 (API 34)

### 🔧 Troubleshooting

**Error: "JAVA_HOME is set to an invalid directory"**
- Solution: Follow the Java installation steps above and restart your terminal

**Error: "SDK location not found"**
- Solution: Make sure Android SDK is installed via Android Studio

**Error: "Execution failed for task ':app:processReleaseResources'"**
- Solution: Run `flutter clean` then try building again

**APK won't install on phone**
- Enable "Install from unknown sources" in phone settings
- Make sure you downloaded the correct architecture APK

---

## Build Command Reference

```powershell
# Clean project
flutter clean

# Get dependencies
flutter pub get

# Build split APKs (recommended)
flutter build apk --split-per-abi

# Build universal APK
flutter build apk

# Build App Bundle (for Google Play Store)
flutter build appbundle

# Build debug APK
flutter build apk --debug

# Check APK size
flutter build apk --analyze-size
```

---

## Testing Your APK

1. Install the APK on your Android device
2. Open the "Mobile Marketplace" app
3. Test all features:
   - Sign up with email verification
   - Login
   - Post an item
   - Browse items
   - Save items (heart icon)
   - View My Listings
   - Send messages
   - Update profile

---

## Next Steps: Publishing to Google Play Store

1. Create a Google Play Developer account ($25 one-time fee)
2. Generate a signed App Bundle:
   ```powershell
   flutter build appbundle
   ```
3. Upload to Google Play Console
4. Fill in store listing details
5. Submit for review

---

**Need Help?** 
- Flutter documentation: https://docs.flutter.dev/deployment/android
- Google Play Console: https://play.google.com/console

**Built with Flutter 💙**
