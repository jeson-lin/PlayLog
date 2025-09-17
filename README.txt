# PlayLog Patched Package

你可以直接覆蓋到你的專案目錄（或用這份作為新專案骨架）。

## 內容
- pubspec.yaml（已包含 firebase_core、flutter_riverpod）
- lib/main.dart（Firebase 初始化 + 錯誤處理 + Riverpod + UI）
- lib/providers.dart（計時器 + 練習紀錄狀態）
- lib/firebase_options.dart（使用你上傳的正式檔案）

## 放置方式
1. 備份你原始專案
2. 解壓本壓縮檔，將內容覆蓋到你的專案根目錄
3. 確認 `android/app/google-services.json` 已存在（從 Firebase Console 下載）

## 建置指令
flutter pub get
flutter clean
flutter pub get
flutter run -d <你的Android裝置ID>

## 常見問題
- 若遇到 NDK/License：
  "C:\Android\cmdline-tools\latest\bin\sdkmanager.bat" --licenses

- 若遇到 flutter_fft 的 AndroidManifest 錯誤：
  刪除該套件 android/src/main/AndroidManifest.xml 裡的 package="com.slins.flutterfft"
