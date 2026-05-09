#!/bin/bash
echo "🔗 Fixing UnityExport symlink..."
rm -rf /Users/jumana/waddah-app-1/ios/UnityExport
ln -s /Users/jumana/waddah-app-1/ios_xcode/UnityLibrary \
      /Users/jumana/waddah-app-1/ios/UnityExport

echo "🚀 Running Flutter in profile mode..."
cd /Users/jumana/waddah-app-1
flutter clean
flutter pub get
cd ios && pod install --silent && cd ..
flutter run --profile
