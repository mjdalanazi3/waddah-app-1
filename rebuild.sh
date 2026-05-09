#!/bin/bash
echo "🔨 Building Unity framework..."
cd /Users/jumana/waddah-app-1/ios_xcode/UnityLibrary
pod install --silent
xcodebuild -workspace Unity-iPhone.xcworkspace \
  -scheme UnityFramework \
  -configuration Release \
  -sdk iphoneos \
  -arch arm64 \
  BUILD_DIR=/Users/jumana/waddah-app-1/ios_xcode/build \
  CODE_SIGNING_ALLOWED=NO 2>&1 | tail -3

echo "📦 Copying framework..."
rm -rf /Users/jumana/waddah-app-1/ios/Frameworks/UnityFramework.framework
cp -Rf /Users/jumana/waddah-app-1/ios_xcode/build/Release-iphoneos/UnityFramework.framework \
       /Users/jumana/waddah-app-1/ios/Frameworks/UnityFramework.framework

echo "🔗 Fixing UnityExport symlink..."
rm -rf /Users/jumana/waddah-app-1/ios/UnityExport
ln -s /Users/jumana/waddah-app-1/ios_xcode/UnityLibrary \
      /Users/jumana/waddah-app-1/ios/UnityExport

echo "🚀 Running Flutter..."
cd /Users/jumana/waddah-app-1
flutter clean
flutter pub get
cd ios && pod install --silent && cd ..
flutter run
