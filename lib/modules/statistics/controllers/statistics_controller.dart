import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../transaction/models/transaction_model.dart';

class StatisticsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxInt selectedPeriod = 1.obs;

  final Rx<DateTime> startDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  ).obs;

  final Rx<DateTime> endDate = DateTime(
    DateTime.now().year,
    DateTime.now().month + 1,
    0,
  ).obs;

  final RxInt selectedTab = 0.obs;

  final RxInt touchedCategoryIndex = (-1).obs;

  final RxList<TransactionModel> allTransactions = <TransactionModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchTransactions();
  }

  void togglePeriod(int index) {
    if (selectedPeriod.value == index) return;
    selectedPeriod.value = index;

    final now = DateTime.now();
    if (index == 0) {
      final currentWeekday = now.weekday;
      final monday = now.subtract(Duration(days: currentWeekday - 1));
      final sunday = monday.add(const Duration(days: 6));

      startDate.value = DateTime(monday.year, monday.month, monday.day);
      endDate.value = DateTime(sunday.year, sunday.month, sunday.day);
    } else {
      startDate.value = DateTime(now.year, now.month, 1);
      endDate.value = DateTime(now.year, now.month + 1, 0);
    }
    touchedCategoryIndex.value = -1;
    _fetchTransactions();
  }

  void previousPeriod() {
    if (selectedPeriod.value == 0) {
      startDate.value = startDate.value.subtract(const Duration(days: 7));
      endDate.value = endDate.value.subtract(const Duration(days: 7));
    } else {
      final m = startDate.value;
      final prevMonth = DateTime(m.year, m.month - 1, 1);
      startDate.value = prevMonth;
      endDate.value = DateTime(prevMonth.year, prevMonth.month + 1, 0);
    }
    touchedCategoryIndex.value = -1;
    _fetchTransactions();
  }

  void nextPeriod() {
    final now = DateTime.now();
    if (selectedPeriod.value == 0) {
      final nextStart = startDate.value.add(const Duration(days: 7));
      if (nextStart.isAfter(now)) return;
      startDate.value = nextStart;
      endDate.value = endDate.value.add(const Duration(days: 7));
    } else {
      final m = startDate.value;
      final nextMonth = DateTime(m.year, m.month + 1, 1);
      if (nextMonth.isAfter(now)) return;
      startDate.value = nextMonth;
      endDate.value = DateTime(nextMonth.year, nextMonth.month + 1, 0);
    }
    touchedCategoryIndex.value = -1;
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    final user = _auth.currentUser;
    if (user == null) return;

    isLoading.value = true;
    try {
      final start = startDate.value;

      final end = endDate.value.add(
        const Duration(hours: 23, minutes: 59, seconds: 59),
      );

      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: user.uid)
          .get();

      final docs =
          snapshot.docs
              .map((d) => TransactionModel.fromMap(d.data(), d.id))
              .where(
                (t) =>
                    t.tanggal.isAfter(
                      start.subtract(const Duration(seconds: 1)),
                    ) &&
                    t.tanggal.isBefore(end.add(const Duration(seconds: 1))),
              )
              .toList()
            ..sort((a, b) => b.tanggal.compareTo(a.tanggal));

      allTransactions.value = docs;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat statistik: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> refresh() => _fetchTransactions();

  String get activeType => selectedTab.value == 0 ? 'pemasukan' : 'pengeluaran';

  List<TransactionModel> get filteredTransactions =>
      allTransactions.where((t) => t.type == activeType).toList();

  double get totalPemasukan => allTransactions
      .where((t) => t.type == 'pemasukan')
      .fold(0, (s, t) => s + t.nominal);

  double get totalPengeluaran => allTransactions
      .where((t) => t.type == 'pengeluaran')
      .fold(0, (s, t) => s + t.nominal);

  double get totalActiveTab =>
      selectedTab.value == 0 ? totalPemasukan : totalPengeluaran;

  double get selisih => totalPemasukan - totalPengeluaran;

  Map<DateTime, double> get dailyChartData {
    final result = <DateTime, double>{};

    DateTime current = startDate.value;
    while (!current.isAfter(endDate.value)) {
      final dateKey = DateTime(current.year, current.month, current.day);
      result[dateKey] = 0;
      current = current.add(const Duration(days: 1));
    }

    for (final tx in filteredTransactions) {
      final dateKey = DateTime(
        tx.tanggal.year,
        tx.tanggal.month,
        tx.tanggal.day,
      );
      if (result.containsKey(dateKey)) {
        result[dateKey] = result[dateKey]! + tx.nominal;
      }
    }
    return result;
  }

  List<Map<String, dynamic>> get categoryBreakdown {
    final map = <String, Map<String, dynamic>>{};
    for (final tx in filteredTransactions) {
      if (map.containsKey(tx.categoryId)) {
        map[tx.categoryId]!['total'] =
            (map[tx.categoryId]!['total'] as double) + tx.nominal;
      } else {
        map[tx.categoryId] = {
          'name': tx.categoryName,
          'iconPath': tx.categoryIconPath,
          'total': tx.nominal,
        };
      }
    }
    final total = totalActiveTab;
    final list = map.values.toList()
      ..sort((a, b) => (b['total'] as double).compareTo(a['total'] as double));
    return list.map((e) {
      return {
        'name': e['name'],
        'iconPath': e['iconPath'],
        'total': e['total'] as double,
        'percent': total > 0 ? (e['total'] as double) / total * 100 : 0.0,
      };
    }).toList();
  }

  String formatRupiah(double value) {
    final f = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return f.format(value);
  }

  String get periodLabel {
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
    if (selectedPeriod.value == 0) {
      final startDay = startDate.value.day;
      final startMonth = months[startDate.value.month].substring(0, 3);
      final endDay = endDate.value.day;
      final endMonth = months[endDate.value.month].substring(0, 3);
      return '$startDay $startMonth - $endDay $endMonth';
    } else {
      return '${months[startDate.value.month]} ${startDate.value.year}';
    }
  }

  String get prevPeriodLabel {
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
    if (selectedPeriod.value == 0) {
      final prevStart = startDate.value.subtract(const Duration(days: 7));
      return '${prevStart.day} ${months[prevStart.month].substring(0, 3)}';
    } else {
      final m = startDate.value;
      final prev = DateTime(m.year, m.month - 1, 1);
      return months[prev.month];
    }
  }

  bool get canGoNext {
    final now = DateTime.now();
    if (selectedPeriod.value == 0) {
      final nextStart = startDate.value.add(const Duration(days: 7));
      return !nextStart.isAfter(now);
    } else {
      final m = startDate.value;
      final nextMonth = DateTime(m.year, m.month + 1, 1);
      return !(nextMonth.year > now.year ||
          (nextMonth.year == now.year && nextMonth.month > now.month));
    }
  }
}
