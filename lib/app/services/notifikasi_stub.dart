/// Notifikasi lokal hanya tersedia di Android. Di browser semua panggilan
/// diabaikan agar alur penyimpanan data tetap berjalan.
class NotifikasiService {
  NotifikasiService._();

  static Future<void> init() async {}

  static Future<void> kirim(String judul, String isi) async {}
}
