import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_expense/helpers/category_style.dart';
import 'package:smart_expense/modules/transaction/controllers/transaction_history_controller.dart';
import '../models/transaction_model.dart';
import 'transaction_detail_page.dart';

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TransactionHistoryController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(controller),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFF3506B)),
                  );
                }
                return RefreshIndicator(
                  color: const Color(0xFFF3506B),
                  onRefresh: controller.refresh,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: _buildMonthSelector(controller),
                      ),

                      SliverToBoxAdapter(child: _buildSummaryCard(controller)),

                      SliverToBoxAdapter(child: _buildTabs(controller)),

                      _buildTransactionList(controller),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(TransactionHistoryController c) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          const Text(
            'Transaksi',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: c.downloadPdfReport,
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(
                Icons.download_outlined,
                size: 26,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(TransactionHistoryController c) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! < -200) {
          c.nextMonth();
        } else if (details.primaryVelocity! > 200) {
          c.previousMonth();
        }
      },
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 28),
                onPressed: c.previousMonth,
                splashRadius: 20,
              ),
              Text(
                c.monthLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 28),
                onPressed: c.nextMonth,
                splashRadius: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(TransactionHistoryController c) {
    return Obx(
      () => Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Pengeluaran ${c.monthLabel}',
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              c.formatRupiah(c.totalPengeluaran),
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _summarySmall(
                  'Total Pemasukan',
                  c.formatRupiah(c.totalPemasukan),
                ),
                const SizedBox(width: 32),
                _summarySmall(
                  'Selisih',
                  c.formatRupiah(c.selisih.abs()),
                  valueColor: c.selisih >= 0
                      ? const Color(0xFF26A65B)
                      : Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summarySmall(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildTabs(TransactionHistoryController c) {
    return Obx(
      () => Container(
        color: Colors.white,
        margin: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            _buildTab('Pemasukan', 0, c),
            _buildTab('Pengeluaran', 1, c),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index, TransactionHistoryController c) {
    final isSelected = c.selectedTab.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => c.selectedTab.value = index,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? const Color(0xFFF3506B)
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? Colors.black : Colors.black45,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList(TransactionHistoryController c) {
    return Obx(() {
      final list = c.filteredTransactions;
      if (list.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 60,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 12),
                Text(
                  'Belum ada transaksi',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
        );
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final tx = list[index];
          return _TransactionTile(tx: tx, controller: c);
        }, childCount: list.length),
      );
    });
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel tx;
  final TransactionHistoryController controller;

  const _TransactionTile({required this.tx, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () => Get.to(
          () => const TransactionDetailPage(),
          arguments: tx,
          transition: Transition.rightToLeft,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                children: [
                  CategoryStyle.iconBoxByName(
                    tx.categoryIconPath,
                    tx.categoryName,
                    size: 42,
                  ),
                  const SizedBox(width: 13),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx.categoryName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          controller.formatTransactionDate(tx.tanggal),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    controller.formatRupiah(tx.nominal),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF0F0F0), indent: 71),
          ],
        ),
      ),
    );
  }
}
