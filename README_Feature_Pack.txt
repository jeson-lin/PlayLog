PlayLog Feature Pack — 錄音 / 調音器 / 節拍器

這包會新增 3 個分頁，並更新底部導覽為 5+1 分頁（首頁、練習、錄音、調音、節拍、設定）。
請覆蓋下列檔案（或加入新檔）：
- lib/src/home_shell.dart  ← 已擴充為 6 個分頁
- lib/src/pages/recorder_page.dart
- lib/src/pages/tuner_page.dart
- lib/src/pages/metronome_page.dart

其他既有檔案（如 main.dart、auth_gate.dart、practice_page.dart 等）不用動。

pubspec.yaml 需加入相依：
dependencies:
  record: ^5.0.4
  path_provider: ^2.1.4
  share_plus: ^10.0.2
  flutter_fft: ^1.5.0
  vibration: ^1.8.4

安裝：
  flutter pub get

Android 權限（建議檢查 AndroidManifest.xml）：
- 錄音：<uses-permission android:name="android.permission.RECORD_AUDIO"/>
- 調音器同樣依賴麥克風權限（flutter_fft）。
（通常 record/flutter_fft 會自動請求權限，但 Manifest 需有宣告）

iOS Info.plist 需加入描述：
  <key>NSMicrophoneUsageDescription</key>
  <string>App 需要使用麥克風用於錄音與調音。</string>

注意：
- 錄音檔保存在 App 文件目錄（可透過分享匯出）。
- 節拍器目前為視覺 + 震動提示（無音效），避免額外素材與複雜設定。

