
# App Setup (Flutter)

## Dependencies (pubspec.yaml excerpts)

- firebase_core, firebase_auth, cloud_firestore
- google_sign_in, sign_in_with_apple
- in_app_purchase
- google_mobile_ads
- provider
- shared_preferences
- flutter_local_notifications
- intl
- just_audio (for metronome ticks)
- permission_handler
- flutter_localizations

## Steps

1. `flutter create .` (inside app/ to generate platform projects)
2. Replace/merge `pubspec.yaml` with this project’s file
3. Add Firebase config files:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
4. Initialize Firebase in `main.dart` (already stubbed)
5. AdMob: create ad units, set IDs in `services/ads_service.dart`
6. IAP: configure products, set IDs in `services/iap_service.dart`
7. Localizations: add more ARB files under `assets/l10n/` and run `flutter gen-l10n`
\n
## Firebase Init & Anonymous Auth (already wired)
- `main.dart` calls `Firebase.initializeApp()` and signs in anonymously via `AuthService`.
- Practice page writes a session to Firestore when you press **Stop & Save**.
- Make sure you added `google-services.json` / `GoogleService-Info.plist` and followed Firebase Flutter setup.
\n
## Stats & Leaderboards (v3)
- Writing aggregates to: `users/{uid}/aggregates/{daily|weekly|monthly}/items/{key}`
- Public leaderboards at: `leaderboards/{daily|weekly|monthly}/items/{key}/users/{uid}`
- Screens `Stats` & `Leaderboard` read these collections live.

## Ads (Test IDs)
- Banner shown in Practice screen footer.
- Interstitial will show after a session is saved.
- Replace test IDs with your real AdMob units before production.

## In-App Purchases (IAP) — Premium & Remove Ads
- Service: `lib/services/iap_service.dart` (scaffold using `in_app_purchase`)
- Products (replace with store product IDs):
  - `remove_ads` (non-consumable)
  - `premium_monthly` (subscription)
  - `premium_yearly` (subscription)
- UI:
  - `AiAdviceScreen` shows gated content; open `PaywallScreen` via toolbar or button
  - `PaywallScreen` lists products and triggers purchase
- Ads respect IAP:
  - If `removeAds` or `isPremium` → banners/interstitials are hidden

## Settings & Sign-In (v5)
- `SettingsScreen`：Google / Apple 登入、暱稱、語言、通知開關、恢復購買
- `AuthService`：支援 Google 與 Apple 登入、登出與匿名登入
- `FirestoreService`：新增 `upsertUserProfile()` 與 `fetchUserProfile()`
- 註：Google/Apple 登入需完成各平台設定（URL scheme / entitlement / App Store Connect 服務）

## v6 — Auto-Detect + Profile + Leaderboard Nickname
- Auto-detect practice using microphone RMS + silence timeout per instrument (`PracticeDetector` via `record` plugin)
- Practice page now has **Start/Stop Listening**; sessions auto-close & save after silence gap
- Settings adds **Country**; profile (`users/{uid}`) stores `nickname`, `countryCode`, `languageCode`
- Leaderboard entries now include `nickname` and `countryCode` (snapshotted at write time)
- Restore Purchases now with basic error handling
- **Permissions**: add mic permissions (Android `RECORD_AUDIO`, iOS `NSMicrophoneUsageDescription`)

## v7 — i18n + Adjustable Thresholds
- Added ARB files under `assets/l10n/` (en, zh_TW, ja) and wired `AppLocalizations`
- `LocaleProvider` reads `lang` from SharedPreferences and updates `MaterialApp.locale`
- `Settings` now includes **RMS threshold** and **per-instrument gap seconds** sliders; values persisted locally
- `PracticeDetector` uses your custom thresholds at start
- To regenerate localization (if you add ARB keys): run `flutter gen-l10n`

## v8 — Settings Export/Import/Reset & Teacher Dashboard
- **Settings**：新增「匯出設定 / 匯入設定 / 重設預設值」
  - 使用 `share_plus` 匯出為 JSON 文字（可分享/備份）
  - 使用 `file_picker` 匯入 JSON
- **Teacher Dashboard（原型）**
  - Firestore 結構：`teachers/{teacherUid}/students/{doc: { uid, nickname }}`
  - 顯示學生清單與「本週總練習分鐘」（讀取學生 `users/{uid}/aggregates/weekly/items/{YYYY-Www}`）
  - 從首頁右上角「⋮」選單進入「老師」
- **i18n**：補齊常用文案（確定/取消、錯誤、成功、匯出/匯入/重設等）

## v9 — Teacher Exports (CSV/PDF) + Assignments & Auto-apply Language on Import
- **Teacher Dashboard**
  - Export **weekly report** for all students as **CSV/PDF** (share via OS sheet)
  - New **Assignments** tab: create/list assignments under `teachers/{uid}/assignments/{aid}`
- **Settings Import**
  - Importing JSON now **auto-applies language** immediately
- **Dependencies**
  - Added: `path_provider`, `pdf`, `printing`

## v11 — Aggregates (Longest/AvgActive), Leaderboard Filters, Task Comments
- **Aggregates**：每日/每週/每月文件加入 `longestSessionSec` 與 `sumActiveRatioSec`（可據此算平均活躍比）
- **Leaderboards**：快照 `school/classId`，並在排行榜提供 Country/School/Class 篩選
- **Teacher Export**：CSV/PDF 內含每樂器分鐘、最長單次（分）、平均活躍比（%）
- **Tasks**：學生可對作業留言（存至 `assignees/{uid}.comment`）
