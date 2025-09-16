// 這是一個暫時檔案，僅用於編譯通過。
// 請之後執行 flutterfire configure 生成正式檔案。
class DefaultFirebaseOptions {
  static const web = FirebaseOptionsPlaceholder();
}

class FirebaseOptionsPlaceholder {
  const FirebaseOptionsPlaceholder();
}

// ---- AUTO-GENERATED STUB FOR WEB (temporary) ----
import 'package:firebase_core/firebase_core.dart';
class _PatchedDefaultFirebaseOptionsWeb {
  static FirebaseOptions get web => const FirebaseOptions(
    apiKey: 'DUMMY',
    appId: 'DUMMY',
    messagingSenderId: 'DUMMY',
    projectId: 'DUMMY',
  );
}
// Expose as DefaultFirebaseOptions.web if not present
extension _WebGetter on DefaultFirebaseOptions {
  static FirebaseOptions get web => _PatchedDefaultFirebaseOptionsWeb.web;
}
