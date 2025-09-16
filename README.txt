PlayLog Firebase Fix Pack
=========================
這個壓縮檔包含修正過的 Gradle 與 Firebase 設定檔。

套用步驟：
1. 備份你的專案。
2. 將壓縮檔內容複製到專案相對路徑。
   - android/build.gradle.kts
   - android/settings.gradle.kts
   - android/app/build.gradle.kts
   - lib/main.dart
   - lib/firebase_options.dart (暫時檔案，之後用 flutterfire configure 生成)
   - pubspec.yaml (合併 dependencies 部分，不要覆蓋你的 app 名稱與資產設定)
3. 放入從 Firebase Console 下載的 google-services.json 到 android/app/。
4. 執行 flutter clean → flutter pub get → flutter run。
