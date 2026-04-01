import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_expense/helpers/category_style.dart';
import 'package:smart_expense/modules/transaction/models/transaction_model.dart';

class ExpenseDonutChart extends StatefulWidget {
  final List<TransactionModel> transactions;
  final DateTime displayMonth;
  final int totalPengeluaran;

  const ExpenseDonutChart({
    Key? key,
    required this.transactions,
    required this.displayMonth,
    required this.totalPengeluaran,
  }) : super(key: key);

  @override
  State<ExpenseDonutChart> createState() => _ExpenseDonutChartState();
}

class _ExpenseDonutChartState extends State<ExpenseDonutChart> {
  int touchedIndex = -1;

  String _monthLabel(DateTime month) {
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
    return '${months[month.month]}\n${month.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.totalPengeluaran == 0) {
      return const SizedBox.shrink();
    }

    final expenseTransactions = widget.transactions
        .where((t) => t.type == 'pengeluaran')
        .toList();

    final Map<String, _CategoryData> categoryData = {};
    for (var t in expenseTransactions) {
      if (!categoryData.containsKey(t.categoryName)) {
        categoryData[t.categoryName] = _CategoryData(
          t.categoryName,
          t.categoryIconPath,
        );
      }
      categoryData[t.categoryName]!.total += t.nominal.toDouble();
    }

    final categoryList = categoryData.values.toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rasio Kategori Pengeluaran',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: Stack(
              children: [
                Center(
                  child: Text(
                    _monthLabel(widget.displayMonth),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                PieChart(
                  key: ValueKey(categoryList.length),
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse
                              .touchedSection!
                              .touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 75,
                    startDegreeOffset: -90,
                    sections: List.generate(categoryList.length, (i) {
                      final isTouched = i == touchedIndex;
                      final radius = isTouched ? 40.0 : 30.0;
                      final data = categoryList[i];
                      final percent = (data.total / widget.totalPengeluaran) * 100;

                      return PieChartSectionData(
                        color: CategoryStyle.colorByName(data.name),
                        value: percent,
                        showTitle: false,
                        radius: radius,
                        badgeWidget: _Badge(
                          data.iconPath,
                          data.name,
                          '${percent.toStringAsFixed(0)}%',
                          size: isTouched ? 36.0 : 32.0,
                          borderColor: CategoryStyle.colorByName(data.name),
                        ),
                        badgePositionPercentageOffset: 2.3,
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _CategoryData {
  final String name;
  final String iconPath;
  double total = 0;

  _CategoryData(this.name, this.iconPath);
}

class _Badge extends StatelessWidget {
  final String iconPath;
  final String name;
  final String percentage;
  final double size;
  final Color borderColor;

  const _Badge(
    this.iconPath,
    this.name,
    this.percentage, {
    Key? key,
    required this.size,
    required this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: BorderRadius.circular(size * 0.28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.all(size * 0.22),
            child: iconPath.isNotEmpty
                ? Image.asset(
                    iconPath,
                    color: Colors.white,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.category,
                      size: size * 0.55,
                      color: Colors.white,
                    ),
                  )
                : Icon(Icons.category, size: size * 0.55, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            percentage,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
