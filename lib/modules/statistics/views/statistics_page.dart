import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_expense/helpers/category_style.dart';
import '../controllers/statistics_controller.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  static const _red = Color(0xFFF3506B);
  static const _redLight = Color(0x20F3506B);

  @override
  Widget build(BuildContext context) {
    final c = Get.put(StatisticsController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          if (c.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: _red));
          }
          return GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity == null) return;
              if (details.primaryVelocity! < -300) {
                c.nextPeriod();
              } else if (details.primaryVelocity! > 300) {
                c.previousPeriod();
              }
            },
            behavior: HitTestBehavior.opaque,
            child: RefreshIndicator(
              color: _red,
              onRefresh: c.refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(c),
                    _buildPeriodToggle(c),
                    _buildMonthRow(c),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFEEEEEE),
                    ),
                    _buildSummaryRows(c),
                    const Divider(
                      height: 1,
                      thickness: 8,
                      color: Color(0xFFF5F5F5),
                    ),
                    _buildTabs(c),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFEEEEEE),
                    ),
                    _buildChartSection(c),
                    const SizedBox(height: 8),
                    _buildCategorySection(c),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader(StatisticsController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: const Text(
        'Statistik',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPeriodToggle(StatisticsController c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.all(3),
        child: Obx(
          () => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => c.togglePeriod(0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: c.selectedPeriod.value == 0
                        ? Colors.black
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Text(
                    'Mingguan',
                    style: TextStyle(
                      fontSize: 14,
                      color: c.selectedPeriod.value == 0
                          ? Colors.white
                          : Colors.black54,
                      fontWeight: c.selectedPeriod.value == 0
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),

              GestureDetector(
                onTap: () => c.togglePeriod(1),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: c.selectedPeriod.value == 1
                        ? Colors.black
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Text(
                    'Bulanan',
                    style: TextStyle(
                      fontSize: 14,
                      color: c.selectedPeriod.value == 1
                          ? Colors.white
                          : Colors.black54,
                      fontWeight: c.selectedPeriod.value == 1
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthRow(StatisticsController c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Obx(
        () => Row(
          children: [
            GestureDetector(
              onTap: c.previousPeriod,
              child: Text(
                c.prevPeriodLabel,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black38,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Text(
                c.periodLabel,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            GestureDetector(
              onTap: () async {
                final now = DateTime.now();

                final pickedRange = await showDateRangePicker(
                  context: Get.context!,
                  initialDateRange: DateTimeRange(
                    start: c.startDate.value,
                    end: c.endDate.value,
                  ),
                  firstDate: DateTime(2020),
                  lastDate: now,
                  builder: (ctx, child) => Theme(
                    data: ThemeData(
                      colorScheme: const ColorScheme.light(
                        primary: _red,
                        surface: Colors.white,
                      ),
                    ),
                    child: child!,
                  ),
                );

                if (pickedRange != null) {
                  final diff = pickedRange.end
                      .difference(pickedRange.start)
                      .inDays;
                  if (diff > 31) {
                    Get.snackbar(
                      'Peringatan',
                      'Rentang waktu maksimal 31 hari',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.orange.shade100,
                      colorText: Colors.orange.shade800,
                    );
                    return;
                  }
                  c.startDate.value = pickedRange.start;
                  c.endDate.value = pickedRange.end;
                  c.refresh();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFDDDDDD)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_month_outlined,
                  size: 20,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRows(StatisticsController c) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            _summaryRow('Total Pemasukan', c.formatRupiah(c.totalPemasukan)),
            const SizedBox(height: 10),
            _summaryRow(
              'Total Pengeluaran',
              c.formatRupiah(c.totalPengeluaran),
            ),
            const SizedBox(height: 10),
            _summaryRow('Selisih', c.formatRupiah(c.selisih.abs()), bold: true),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildTabs(StatisticsController c) {
    return Obx(
      () => Row(children: [_tab('Pemasukan', 0, c), _tab('Pengeluaran', 1, c)]),
    );
  }

  Widget _tab(String label, int idx, StatisticsController c) {
    final isActive = c.selectedTab.value == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          c.selectedTab.value = idx;
          c.touchedCategoryIndex.value = -1;
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? _red : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
              color: isActive ? Colors.black : Colors.black45,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartSection(StatisticsController c) {
    return Obx(() {
      final tabLabel = c.selectedTab.value == 0 ? 'Pemasukan' : 'Pengeluaran';
      final dailyData = c.dailyChartData;
      final spots =
          dailyData.entries
              .map(
                (e) => FlSpot(
                  e.key.millisecondsSinceEpoch.toDouble(),
                  e.value / 1000,
                ),
              )
              .toList()
            ..sort((a, b) => a.x.compareTo(b.x));
      final maxY = spots.map((s) => s.y).fold(0.0, (p, v) => v > p ? v : p);
      final double chartMax = maxY > 0 ? maxY * 1.3 : 1.0;

      final diffDays = c.endDate.value.difference(c.startDate.value).inDays;

      final double intervalX = (diffDays > 14 ? 7 : 2) * 24 * 60 * 60 * 1000.0;

      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total $tabLabel',
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              c.formatRupiah(c.totalActiveTab),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    drawHorizontalLine: true,
                    horizontalInterval: chartMax / 4,

                    getDrawingHorizontalLine: (_) =>
                        FlLine(color: const Color(0xFFEEEEEE), strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: intervalX,
                        reservedSize: 22,
                        getTitlesWidget: (value, _) {
                          final date = DateTime.fromMillisecondsSinceEpoch(
                            value.toInt(),
                          );

                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              '${date.day}/${date.month}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black38,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  minX: c.startDate.value.millisecondsSinceEpoch.toDouble(),
                  maxX: c.endDate.value.millisecondsSinceEpoch.toDouble(),
                  minY: 0,
                  maxY: chartMax,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (spots) => spots.map((s) {
                        final date = DateTime.fromMillisecondsSinceEpoch(
                          s.x.toInt(),
                        );
                        final dateStr =
                            '${date.day} ${_monthShort(date.month)}';
                        final valStr = 'Rp${(s.y * 1000).toStringAsFixed(0)}';
                        return LineTooltipItem(
                          '$dateStr\n$valStr',
                          const TextStyle(color: Colors.white, fontSize: 11),
                        );
                      }).toList(),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots.isEmpty
                          ? [
                              FlSpot(
                                c.startDate.value.millisecondsSinceEpoch
                                    .toDouble(),
                                0,
                              ),
                            ]
                          : spots,
                      isCurved: true,
                      curveSmoothness: 0.35,
                      color: _red,
                      barWidth: 2.5,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, color: _redLight),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  String _monthShort(int month) {
    const list = [
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
    return list[month];
  }

  Widget _buildCategorySection(StatisticsController c) {
    return Obx(() {
      final breakdown = c.categoryBreakdown;
      final tabLabel = c.selectedTab.value == 0 ? 'Pemasukan' : 'Pengeluaran';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Text(
              'Kategori $tabLabel',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),

          if (breakdown.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Belum ada data $tabLabel',
                  style: const TextStyle(color: Colors.black38, fontSize: 14),
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 300,
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      c.periodLabel.replaceFirst(' ', '\n'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  PieChart(
                    key: ValueKey(breakdown.length),
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            c.touchedCategoryIndex.value = -1;
                            return;
                          }
                          c.touchedCategoryIndex.value = pieTouchResponse
                              .touchedSection!
                              .touchedSectionIndex;
                        },
                      ),
                      sectionsSpace: 2,
                      centerSpaceRadius: 75,
                      startDegreeOffset: -90,
                      sections: List.generate(breakdown.length, (i) {
                        final item = breakdown[i];
                        final isTouched = i == c.touchedCategoryIndex.value;
                        final radius = isTouched ? 40.0 : 30.0;
                        final color = CategoryStyle.colorByName(
                          item['name'] as String,
                        );
                        final pct = (item['percent'] as double).toStringAsFixed(
                          0,
                        );

                        return PieChartSectionData(
                          value: item['total'] as double,
                          color: color,
                          radius: radius,
                          showTitle: false,
                          badgeWidget: _Badge(
                            item['iconPath'] as String,
                            item['name'] as String,
                            '$pct%',
                            size: isTouched ? 36.0 : 32.0,
                            borderColor: color,
                          ),
                          badgePositionPercentageOffset: 2.3,
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (breakdown.isNotEmpty) const SizedBox(height: 32),
        ],
      );
    });
  }
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
    required this.size,
    required this.borderColor,
  });

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
                    errorBuilder: (ctx, err, stack) => Icon(
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
