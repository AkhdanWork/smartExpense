import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_expense/modules/transaction/models/transaction_model.dart';
import 'package:smart_expense/service/firebase_service.dart';

class HomeController extends GetxController {
  final _fb = FirebaseService();

  final currentIndex = 0.obs;
  void changePage(int index) => currentIndex.value = index;

  final loading = true.obs;
  final firestorePermissionDenied = false.obs;

  final name = ''.obs;

  final displayMonth = DateTime(DateTime.now().year, DateTime.now().month).obs;
  final hasNextMonth = false.obs;

  final transactions = <TransactionModel>[].obs;

  final currentMonthTransactions = <TransactionModel>[].obs;

  final currentMonthExpense = 0.obs;
  final prevMonthExpense = 0.obs;
  final showComparison = false.obs;
  final comparisonPercent = 0.obs;
  final isExpenseLower = true.obs;

  final balance = 0.obs;
  final weekExpense = 0.obs;
  final todayExpense = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadLocalName();
    loadData();
  }

  Future<void> _loadLocalName() async {
    final prefs = await SharedPreferences.getInstance();
    final storedName = prefs.getString('user_name') ?? '';
    if (storedName.trim().isNotEmpty) {
      name.value = storedName;
    } else {
      final user = _fb.auth.currentUser;
      if (user != null && user.email != null) {
        name.value = user.email!.split('@')[0];
      }
    }
  }

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 10) return 'Selamat pagi';
    if (hour >= 10 && hour < 15) return 'Selamat siang';
    if (hour >= 15 && hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  String monthLabel(DateTime month) {
    const months = [
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
    return '${months[month.month]} ${month.year}';
  }

  Future<void> loadData() async {
    loading.value = true;
    final user = _fb.auth.currentUser;
    if (user == null) {
      loading.value = false;
      return;
    }

    try {
      final doc = await _fb.db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        name.value = (doc.data()!['name'] ?? '').toString();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', name.value);
      }

      if (name.value.trim().isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final storedName = prefs.getString('user_name') ?? '';
        if (storedName.trim().isNotEmpty) {
          name.value = storedName;
        } else {
          name.value = user.displayName?.trim() ?? '';
          if (name.value.trim().isEmpty && user.email != null) {
            name.value = user.email!.split('@')[0];
          }
        }
      }

      await _fetchTransactionsForMonth(displayMonth.value, user.uid);

      final now = DateTime.now();
      final thisMonth = DateTime(now.year, now.month);
      if (displayMonth.value.year == now.year &&
          displayMonth.value.month == now.month) {
        currentMonthTransactions.value = List.from(transactions);
      } else {
        await _fetchCurrentMonthTransactions(thisMonth, user.uid);
      }

      _recalculate();
      await _fetchComparison(user.uid);
      await _checkNextMonth(user.uid);

      firestorePermissionDenied.value = false;
    } catch (e) {
      _handleError(e, user);
    } finally {
      loading.value = false;
    }
  }

  void _recalculate() {
    currentMonthExpense.value = transactions
        .where((t) => t.type == 'pengeluaran')
        .fold(0, (s, t) => s + t.nominal.toInt());

    final income = currentMonthTransactions
        .where((t) => t.type == 'pemasukan')
        .fold(0, (s, t) => s + t.nominal.toInt());
    final expense = currentMonthTransactions
        .where((t) => t.type == 'pengeluaran')
        .fold(0, (s, t) => s + t.nominal.toInt());
    balance.value = income - expense;

    final now = DateTime.now();
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day - (now.weekday - 1),
    );
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    weekExpense.value = currentMonthTransactions
        .where(
          (t) =>
              t.type == 'pengeluaran' &&
              !t.tanggal.isBefore(startOfWeek) &&
              t.tanggal.isBefore(endOfWeek),
        )
        .fold(0, (s, t) => s + t.nominal.toInt());

    final startDay = DateTime(now.year, now.month, now.day);
    final endDay = startDay.add(const Duration(days: 1));
    todayExpense.value = currentMonthTransactions
        .where(
          (t) =>
              t.type == 'pengeluaran' &&
              !t.tanggal.isBefore(startDay) &&
              t.tanggal.isBefore(endDay),
        )
        .fold(0, (s, t) => s + t.nominal.toInt());
  }

  Future<void> _fetchComparison(String uid) async {
    final prev = DateTime(
      displayMonth.value.year,
      displayMonth.value.month - 1,
    );
    prevMonthExpense.value = await _getMonthExpense(prev, uid);

    if (prevMonthExpense.value > 0) {
      showComparison.value = true;
      final diff = currentMonthExpense.value - prevMonthExpense.value;
      isExpenseLower.value = diff <= 0;
      comparisonPercent.value = prevMonthExpense.value != 0
          ? ((diff.abs() * 100) ~/ prevMonthExpense.value)
          : 0;
    } else {
      showComparison.value = false;
    }
  }

  Future<void> _checkNextMonth(String uid) async {
    final next = DateTime(
      displayMonth.value.year,
      displayMonth.value.month + 1,
    );
    hasNextMonth.value = await _monthHasTransactions(next, uid);
  }

  Future<void> goToPrevMonth() async {
    loading.value = true;
    displayMonth.value = DateTime(
      displayMonth.value.year,
      displayMonth.value.month - 1,
    );
    await _reloadDisplayMonth();
    loading.value = false;
  }

  Future<void> goToNextMonth() async {
    if (!hasNextMonth.value) return;
    loading.value = true;
    displayMonth.value = DateTime(
      displayMonth.value.year,
      displayMonth.value.month + 1,
    );
    await _reloadDisplayMonth();
    loading.value = false;
  }

  Future<void> _reloadDisplayMonth() async {
    final user = _fb.auth.currentUser;
    if (user == null) return;

    await _fetchTransactionsForMonth(displayMonth.value, user.uid);

    final now = DateTime.now();
    if (displayMonth.value.year == now.year &&
        displayMonth.value.month == now.month) {
      currentMonthTransactions.value = List.from(transactions);
    }

    _recalculate();
    await _fetchComparison(user.uid);
    await _checkNextMonth(user.uid);
  }

  Future<void> _fetchTransactionsForMonth(DateTime month, String uid) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    final q = await _fb.db
        .collection('transactions')
        .where('userId', isEqualTo: uid)
        .get();
    final list =
        q.docs
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
    transactions.value = list;
  }

  Future<void> _fetchCurrentMonthTransactions(
    DateTime month,
    String uid,
  ) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    final q = await _fb.db
        .collection('transactions')
        .where('userId', isEqualTo: uid)
        .get();
    currentMonthTransactions.value = q.docs
        .map((d) => TransactionModel.fromMap(d.data(), d.id))
        .where(
          (t) =>
              t.tanggal.isAfter(start.subtract(const Duration(seconds: 1))) &&
              t.tanggal.isBefore(end),
        )
        .toList();
  }

  Future<int> _getMonthExpense(DateTime month, String uid) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    try {
      final q = await _fb.db
          .collection('transactions')
          .where('userId', isEqualTo: uid)
          .get();
      return q.docs.fold<int>(0, (s, d) {
        final map = d.data();
        final nominal = (map['nominal'] is num)
            ? (map['nominal'] as num).toInt()
            : 0;
        final tanggal = (map['tanggal'] as Timestamp).toDate();
        if (tanggal.isAfter(start.subtract(const Duration(seconds: 1))) &&
            tanggal.isBefore(end) &&
            map['type'] == 'pengeluaran') {
          return s + nominal;
        }
        return s;
      });
    } catch (_) {
      return 0;
    }
  }

  Future<bool> _monthHasTransactions(DateTime month, String uid) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    final q = await _fb.db
        .collection('transactions')
        .where('userId', isEqualTo: uid)
        .get();
    return q.docs.any((d) {
      final tanggal = (d.data()['tanggal'] as Timestamp).toDate();
      return tanggal.isAfter(start.subtract(const Duration(seconds: 1))) &&
          tanggal.isBefore(end);
    });
  }

  void _handleError(Object e, dynamic user) {
    try {
      if (e is FirebaseException) {
        final code = e.code.toLowerCase();
        if (code.contains('permission') ||
            (e.message ?? '').toLowerCase().contains('permission')) {
          firestorePermissionDenied.value = true;
        }
      } else if (e.toString().toLowerCase().contains(
        'missing or insufficient permissions',
      )) {
        firestorePermissionDenied.value = true;
      }
    } catch (_) {}

    if (firestorePermissionDenied.value) {
      SharedPreferences.getInstance().then((prefs) {
        final storedName = prefs.getString('user_name') ?? '';
        if (storedName.trim().isNotEmpty) {
          name.value = storedName;
        } else {
          name.value = user?.displayName?.trim() ?? '';
          if (name.value.trim().isEmpty && user?.email != null) {
            name.value = user!.email!.split('@')[0];
          }
        }
      });
      balance.value = 0;
      transactions.value = [];
      currentMonthTransactions.value = [];
    }
  }
}
