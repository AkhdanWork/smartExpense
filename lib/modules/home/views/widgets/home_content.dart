import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quickly/quickly.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smart_expense/helpers/category_style.dart';
import 'package:smart_expense/modules/home/controller/home_controller.dart';
import '../../../transaction/models/transaction_model.dart';
import '../../../transaction/views/transaction_detail_page.dart';
import 'expense_donut_chart.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  String _fmt(num value) {
    final f = NumberFormat('#,###', 'id_ID');
    return 'Rp' + f.format(value.toInt().abs()).replaceAll(',', '.');
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Obx(
          () => c.loading.value
              ? _buildShimmerLoading()
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTopSection(c),
                      _buildTransactionCard(c),
                      const SizedBox(height: 20),
                      Obx(
                        () => ExpenseDonutChart(
                          transactions: c.transactions,
                          displayMonth: c.displayMonth.value,
                          totalPengeluaran: c.currentMonthExpense.value,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: 100,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 200,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection(HomeController c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Row(
            children: const [
              Text(
                'Smart',
                style: TextStyle(fontSize: 26, color: Colors.black),
              ),
              Text(
                'Expense',
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            c.greeting,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Obx(
            () => Text(
              (c.name.value.isEmpty ? 'Pengguna' : c.name.value).toCapitalCase,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),

          Obx(
            () => c.firestorePermissionDenied.value
                ? Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(255, 82, 82, 0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.error_outline,
                            color: Colors.redAccent,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tidak dapat memuat data: izin tidak mencukupi',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 20),

          Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 130),
                child: _buildBottomCards(c),
              ),
              _buildHeroCard(c),
            ],
          ),

          const SizedBox(height: 28),
          _buildBalanceCard(c),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _buildHeroCard(HomeController c) {
    return Obx(
      () => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: const DecorationImage(
            image: AssetImage('assets/icons/background_card_icon.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                children: [
                  const TextSpan(text: 'Total Pengeluaran '),
                  TextSpan(
                    text: c.monthLabel(c.displayMonth.value),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _fmt(c.currentMonthExpense.value),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _navArrow(
                  Icons.arrow_downward_rounded,
                  Colors.black.withOpacity(0.28),
                  c.goToPrevMonth,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: c.prevMonthExpense.value == 0
                      ? const Text(
                    'Bulan sebelumnya tidak ada pengeluaran',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  )
                      : RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      children: [
                        TextSpan(
                          text: c.isExpenseLower.value ? 'Lebih kecil ' : 'Lebih besar ',
                        ),
                        TextSpan(
                          text: '${c.comparisonPercent.value}%',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: ' dibanding\nPengeluaran '),
                        TextSpan(
                          text: c.monthLabel(
                            DateTime(
                              c.displayMonth.value.year,
                              c.displayMonth.value.month - 1,
                            ),
                          ),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                if (c.hasNextMonth.value) ...[
                  const SizedBox(width: 10),
                  _navArrow(
                    Icons.arrow_upward_rounded,
                    Colors.white.withOpacity(0.25),
                    c.goToNextMonth,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _navArrow(IconData icon, Color bg, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      );

  Widget _buildBottomCards(HomeController c) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 50, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: _smallCard(
                icon: Icons.calendar_today,
                iconColor: const Color(0xFFFF8C00),
                bgColor: const Color(0xFF2C2C2E),
                label: 'Minggu ini',
                value: _fmt(c.weekExpense.value),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _smallCard(
                icon: Icons.calendar_month,
                iconColor: const Color(0xFFE8334A),
                bgColor: const Color(0xFF1C1C1E),
                label: 'Hari ini',
                value: _fmt(c.todayExpense.value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengeluaran',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.55),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(HomeController c) {
    return Obx(() {
      final isNeg = c.balance.value < 0;
      return SizedBox(
        height: 60,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(50),
                ),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Sisa Saldo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                    BoxShadow(
                      color:
                          (isNeg
                                  ? const Color(0xFFE74C3C)
                                  : const Color(0xFFEF4B6C))
                              .withOpacity(0.25),
                      blurRadius: 28,
                      spreadRadius: 3,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  (isNeg ? '-' : '') + _fmt(c.balance.value),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isNeg ? const Color(0xFFE74C3C) : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTransactionCard(HomeController c) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        color: const Color(0xFFF5F5F5),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transaksi Terkini',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                if (c.transactions.isNotEmpty)
                  GestureDetector(
                    onTap: () => c.changePage(1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Lihat Semua',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (c.transactions.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.receipt_long,
                        size: 40,
                        color: Colors.black26,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Belum ada transaksi',
                      style: TextStyle(fontSize: 14, color: Colors.black45),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Anda belum menambahkan transaksi untuk bulan ini.',
                      style: TextStyle(fontSize: 12, color: Colors.black38),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: c.transactions.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => Get.to(
                    () => const TransactionDetailPage(),
                    arguments: c.transactions[i],
                  ),
                  child: _txItem(c.transactions[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _txItem(TransactionModel t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          CategoryStyle.iconBoxByName(
            t.categoryIconPath,
            t.categoryName,
            size: 48,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.categoryName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${DateFormat('d MMM').format(t.tanggal)}  •  ${DateFormat('HH:mm').format(t.tanggal)}',
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ],
            ),
          ),
          Text(
            (t.type == 'pemasukan' ? '+' : '-') + _fmt(t.nominal),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: t.type == 'pemasukan'
                  ? const Color(0xFF27AE60)
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
