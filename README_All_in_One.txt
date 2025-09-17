PlayLog All-in-One Package

內容：
- 完整 `lib/`：登入/註冊、底部 6 分頁（首頁、練習、錄音、調音、節拍、設定）、Firestore 練習紀錄 CRUD。
- 請保留你自己的 `lib/firebase_options.dart` 與 `android/app/google-services.json`。

相依（請加入 pubspec.yaml 後 `flutter pub get`）：
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.0
  cloud_firestore: ^5.4.4
  record: ^5.0.4
  path_provider: ^2.1.4
  share_plus: ^10.0.2
  flutter_fft: ^1.5.0
  vibration: ^1.8.4

Android 權限（AndroidManifest.xml）：
  <uses-permission android:name="android.permission.RECORD_AUDIO" />

iOS Info.plist：
  <key>NSMicrophoneUsageDescription</key>
  <string>App 需要使用麥克風用於錄音與調音。</string>

Firestore 規則（建議）：
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}

使用方法：
1. 解壓縮後覆蓋你的專案（只覆蓋 `lib/`）。
2. 保留既有 `firebase_options.dart` 與 `google-services.json`。
3. flutter pub get
4. flutter run
