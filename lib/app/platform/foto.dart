// Helper foto yang menyesuaikan platform: berkas lokal di Android,
// data URL di browser.
export 'foto_io.dart' if (dart.library.js_interop) 'foto_web.dart';
