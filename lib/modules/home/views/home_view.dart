import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/home_controller.dart';
import 'widgets/home_content.dart';
import '../../transaction/views/widgets/transaction_type_bottom_sheet.dart';
import '../../transaction/views/transaction_history_page.dart';
import '../../statistics/views/statistics_page.dart';
import '../../profile/views/akun_page.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    final args = Get.arguments;
    if (args != null && args is Map && args['tab'] != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.changePage(args['tab'] as int);
      });
    }

    final pages = [
      const HomeContent(),
      const TransactionHistoryPage(),
      const SizedBox(),
      const StatisticsPage(),
      const AkunPage(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() => pages[controller.currentIndex.value]),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const TransactionTypeBottomSheet(),
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: const CircleBorder(),
        child: Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF3506B), Color(0xFFFF8E90)],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x40F3506B),
                blurRadius: 10,
                spreadRadius: 2,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Image.asset(
            'assets/icons/add_transaksi_icon.png',
            fit: BoxFit.contain,
            errorBuilder: (ctx, err, stack) =>
                const Icon(Icons.add, color: Colors.white, size: 30),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: Obx(
        () => BottomAppBar(
          color: Colors.white,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context: context,
                  activeIcon: 'assets/icons/enable_home_icon.png',
                  inactiveIcon: 'assets/icons/disable_home_icon.png',
                  label: 'Home',
                  index: 0,
                  currentIndex: controller.currentIndex.value,
                  onTap: () => controller.changePage(0),
                ),
                _buildNavItem(
                  context: context,
                  activeIcon: 'assets/icons/enable_transaksi_icon.png',
                  inactiveIcon: 'assets/icons/disable_transaksi_icon.png',
                  label: 'Transaksi',
                  index: 1,
                  currentIndex: controller.currentIndex.value,
                  onTap: () => controller.changePage(1),
                ),
                const SizedBox(width: 60),
                _buildNavItem(
                  context: context,
                  activeIcon: 'assets/icons/enable_statistik_icon.png',
                  inactiveIcon: 'assets/icons/disable_statistik_icon.png',
                  label: 'Statistik',
                  index: 3,
                  currentIndex: controller.currentIndex.value,
                  onTap: () => controller.changePage(3),
                ),
                _buildNavItem(
                  context: context,
                  activeIcon: 'assets/icons/enable_profil_icon.png',
                  inactiveIcon: 'assets/icons/disable_profil_icon.png',
                  label: 'Akun',
                  index: 4,
                  currentIndex: controller.currentIndex.value,
                  onTap: () => controller.changePage(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required String activeIcon,
    required String inactiveIcon,
    required String label,
    required int index,
    required int currentIndex,
    required VoidCallback onTap,
  }) {
    final isActive = currentIndex == index;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              isActive ? activeIcon : inactiveIcon,
              width: 22,
              height: 22,
              errorBuilder: (ctx, err, stack) => Icon(
                Icons.circle,
                size: 22,
                color: isActive ? Colors.black : Colors.grey,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isActive ? Colors.black : Colors.grey,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
