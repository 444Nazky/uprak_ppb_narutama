import 'dart:typed_data';

import 'package:data_siswa/app/models/siswa.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Membuat laporan PDF daftar siswa lalu membuka dialog cetak/bagikan.
class PdfService {
  static const _sekolah = 'SMK Plus Pelita Nusantara Bogor';
  static const _judul = 'Laporan Data Siswa';

  static Future<Uint8List> buatDokumen({
    required List<Siswa> siswa,
    required String dicetakOleh,
  }) async {
    final doc = pw.Document(title: _judul);
    final tanggal = DateFormat('d MMMM yyyy', 'id_ID').format(DateTime.now());
    final lebar = [28.0, 62.0, 120.0, 52.0, 156.0];

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 36, 36, 40),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              _sekolah,
              style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Tahun Ajaran 2026/2027',
              style: const pw.TextStyle(
                fontSize: 9.5,
                color: PdfColors.grey700,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Text(
              _judul,
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Dicetak $tanggal oleh $dicetakOleh',
              style: const pw.TextStyle(
                fontSize: 9.5,
                color: PdfColors.grey700,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Divider(thickness: 0.8, color: PdfColors.grey400),
          ],
        ),
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              '${siswa.length} siswa terdaftar',
              style: const pw.TextStyle(
                fontSize: 8.5,
                color: PdfColors.grey600,
              ),
            ),
            pw.Text(
              'Halaman ${context.pageNumber} dari ${context.pagesCount}',
              style: const pw.TextStyle(
                fontSize: 8.5,
                color: PdfColors.grey600,
              ),
            ),
          ],
        ),
        build: (context) => [
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            columnWidths: {
              0: pw.FixedColumnWidth(lebar[0]),
              1: pw.FixedColumnWidth(lebar[1]),
              2: pw.FixedColumnWidth(lebar[2]),
              3: pw.FixedColumnWidth(lebar[3]),
              4: pw.FixedColumnWidth(lebar[4]),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _sel('No'),
                  _sel('NIS'),
                  _sel('Nama Siswa'),
                  _sel('Kelas'),
                  _sel('Alamat'),
                ],
              ),
              for (var i = 0; i < siswa.length; i++)
                pw.TableRow(
                  children: [
                    _isi('${i + 1}'),
                    _isi(siswa[i].nis),
                    _isi(siswa[i].nama),
                    _isi(siswa[i].kelas),
                    _isi(siswa[i].alamat),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
    return doc.save();
  }

  static pw.Widget _sel(String teks) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 6),
    child: pw.Text(
      teks,
      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
    ),
  );

  static pw.Widget _isi(String teks) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 6),
    child: pw.Text(
      teks.isEmpty ? '-' : teks,
      style: const pw.TextStyle(fontSize: 9),
    ),
  );

  static Future<void> bagikan({
    required List<Siswa> siswa,
    required String dicetakOleh,
  }) async {
    final bytes = await buatDokumen(siswa: siswa, dicetakOleh: dicetakOleh);
    final namaFile =
        'data-siswa-${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
    await Printing.sharePdf(bytes: bytes, filename: namaFile);
  }
}
