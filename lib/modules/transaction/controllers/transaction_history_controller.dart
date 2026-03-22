import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/transaction_model.dart';

class TransactionHistoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Rx<DateTime> selectedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  ).obs;

  final RxInt selectedTab = 1.obs;

  final RxList<TransactionModel> allTransactions = <TransactionModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchTransactions();
  }

  void previousMonth() {
    final m = selectedMonth.value;
    selectedMonth.value = DateTime(
      m.month == 1 ? m.year - 1 : m.year,
      m.month == 1 ? 12 : m.month - 1,
    );
    _fetchTransactions();
  }

  void nextMonth() {
    final now = DateTime.now();
    final m = selectedMonth.value;
    final next = DateTime(
      m.month == 12 ? m.year + 1 : m.year,
      m.month == 12 ? 1 : m.month + 1,
    );
    if (next.year > now.year ||
        (next.year == now.year && next.month > now.month))
      return;
    selectedMonth.value = next;
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    final user = _auth.currentUser;
    if (user == null) return;

    isLoading.value = true;
    try {
      final m = selectedMonth.value;

      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: user.uid)
          .get();

      final start = DateTime(m.year, m.month, 1);
      final end = DateTime(m.year, m.month + 1, 1);

      final docs =
          snapshot.docs
              .map((d) => TransactionModel.fromMap(d.data(), d.id))
              .where(
                (t) =>
                    t.tanggal.isAfter(
                      start.subtract(const Duration(seconds: 1)),
                    ) &&
                    t.tanggal.isBefore(end),
              )
              .toList()
            ..sort((a, b) => b.tanggal.compareTo(a.tanggal));

      allTransactions.value = docs;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat transaksi: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() => _fetchTransactions();

  List<TransactionModel> get filteredTransactions {
    final type = selectedTab.value == 0 ? 'pemasukan' : 'pengeluaran';
    return allTransactions.where((t) => t.type == type).toList();
  }

  double get totalPemasukan => allTransactions
      .where((t) => t.type == 'pemasukan')
      .fold(0, (s, t) => s + t.nominal);

  double get totalPengeluaran => allTransactions
      .where((t) => t.type == 'pengeluaran')
      .fold(0, (s, t) => s + t.nominal);

  double get selisih => totalPemasukan - totalPengeluaran;

  String formatRupiah(double value) {
    final f = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return f.format(value);
  }

  String get monthLabel {
    final months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${months[selectedMonth.value.month]} ${selectedMonth.value.year}';
  }

  String formatTransactionDate(DateTime dt) {
    final months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final time = DateFormat('HH:mm').format(dt);
    return '${dt.day} ${months[dt.month]}  ·  $time';
  }

  Future<void> downloadPdfReport() async {
    try {
      final pdf = pw.Document();
      final m = selectedMonth.value;
      final months = [
        '',
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];
      final monthName = '${months[m.month]} ${m.year}';

      final pemasukan = totalPemasukan;
      final pengeluaran = totalPengeluaran;
      final saldo = selisih;

      final transactions = List<TransactionModel>.from(allTransactions)
        ..sort((a, b) => a.tanggal.compareTo(b.tanggal));

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) => [
            pw.Text(
              'Laporan Transaksi',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              monthName,
              style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 16),

            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Total Pemasukan',
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.Text(
                        formatRupiah(pemasukan),
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.green700,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Total Pengeluaran',
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.Text(
                        formatRupiah(pengeluaran),
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.red700,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Selisih',
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.Text(
                        formatRupiah(saldo),
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: saldo >= 0
                              ? PdfColors.green700
                              : PdfColors.red700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            pw.Container(
              color: PdfColors.grey200,
              padding: const pw.EdgeInsets.symmetric(
                vertical: 6,
                horizontal: 8,
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      'Tanggal',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 4,
                    child: pw.Text(
                      'Kategori',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 4,
                    child: pw.Text(
                      'Deskripsi',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      'Tipe',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      'Nominal',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),

            ...transactions.asMap().entries.map((entry) {
              final i = entry.key;
              final t = entry.value;
              final bg = i.isEven ? PdfColors.white : PdfColors.grey50;
              final isIn = t.type == 'pemasukan';
              return pw.Container(
                color: bg,
                padding: const pw.EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 8,
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        DateFormat('dd MMM yyyy').format(t.tanggal),
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ),
                    pw.Expanded(
                      flex: 4,
                      child: pw.Text(
                        t.categoryName,
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ),
                    pw.Expanded(
                      flex: 4,
                      child: pw.Text(
                        t.deskripsi.isEmpty ? '-' : t.deskripsi,
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        isIn ? 'Pemasukan' : 'Pengeluaran',
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: isIn ? PdfColors.green700 : PdfColors.red700,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        formatRupiah(t.nominal),
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: isIn ? PdfColors.green700 : PdfColors.red700,
                        ),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            pw.Divider(),
            pw.SizedBox(height: 8),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Dibuat pada ${DateFormat('dd MMMM yyyy HH:mm').format(DateTime.now())}',
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey600,
                ),
              ),
            ),
          ],
        ),
      );

      final pdfBytes = await pdf.save();
      final fileName = 'Laporan_smartExpense_${months[m.month]}_${m.year}.pdf';

      final outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Simpan Laporan PDF',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        bytes: pdfBytes,
      );

      if (outputPath != null) {
        final file = File(outputPath);
        if (!await file.exists()) {
          await file.writeAsBytes(pdfBytes);
        }
        Get.snackbar(
          'Berhasil',
          'Laporan PDF disimpan di:\n$outputPath',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal membuat PDF: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }
}
