import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/transaction_controller.dart';
import '../models/category_model.dart';
import 'category_picker_page.dart';
import 'widgets/success_modal.dart';
import 'dart:io';

class AddTransactionPage extends StatelessWidget {
  const AddTransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final String type = args['type'] ?? 'pengeluaran';
    final bool isPemasukan = type == 'pemasukan';

    final controller = Get.put(TransactionController(), tag: type);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                            ),
                            onPressed: () => Get.back(),
                          ),
                          Text(
                            isPemasukan
                                ? 'Transaksi Pemasukan'
                                : 'Transaksi Pengeluaran',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Divider(height: 1, color: Color(0xFFEEEEEE)),

                  Obx(() {
                    final cat = controller.selectedCategory.value;
                    return GestureDetector(
                      onTap: () async {
                        final result = await Get.to(
                          () => CategoryPickerPage(type: type),
                        );
                        if (result != null && result is CategoryModel) {
                          controller.selectCategory(result);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        color: Colors.white,
                        child: Row(
                          children: [
                            if (cat != null) ...[
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: isPemasukan
                                      ? const Color(0xFF26A65B)
                                      : const Color(0xFFE8472B),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.all(7),
                                child: Image.asset(
                                  cat.iconPath,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.category,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  cat.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ] else ...[
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.category,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Pilih Kategori',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                            const Icon(
                              Icons.chevron_right,
                              color: Colors.black45,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const Divider(height: 1, color: Color(0xFFEEEEEE)),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nominal',
                          style: TextStyle(fontSize: 12, color: Colors.black45),
                        ),
                        const SizedBox(height: 6),
                        Obx(
                          () => Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Rp',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                controller.nominalDisplay.value,
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.black,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(
                    height: 1,
                    color: Color(0xFFEEEEEE),
                    indent: 16,
                    endIndent: 16,
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.menu, color: Colors.black38, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            onChanged: (val) =>
                                controller.deskripsi.value = val,
                            decoration: const InputDecoration(
                              hintText: 'Tulis Deskripsi',
                              hintStyle: TextStyle(
                                color: Colors.black38,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1, color: Color(0xFFEEEEEE)),

                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: controller.tanggal.value,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        builder: (ctx, child) => Theme(
                          data: Theme.of(ctx).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFFF3506B),
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        controller.tanggal.value = picked;
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      color: Colors.white,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.black54,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Obx(
                              () => Text(
                                controller.formattedTanggal,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.black45,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Foto Struk',
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                        const SizedBox(height: 8),
                        Obx(() {
                          final imgs = controller.receiptImages;
                          return Column(
                            children: [
                              SizedBox(
                                height: 90,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: imgs.length + 1,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 12),
                                  itemBuilder: (ctx, idx) {
                                    if (idx == imgs.length) {
                                      return GestureDetector(
                                        onTap: () => controller.pickReceipts(context),
                                        child: Container(
                                          width: 90,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.add_a_photo,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                      );
                                    }

                                    final xfile = imgs[idx];
                                    return Stack(
                                      children: [
                                        Container(
                                          width: 90,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            image: DecorationImage(
                                              image: FileImage(
                                                File(xfile.path),
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: 4,
                                          top: 4,
                                          child: Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () => controller
                                                    .replaceReceipt(idx),
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black45,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.swap_horiz,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              GestureDetector(
                                                onTap: () => controller
                                                    .removeReceipt(idx),
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.redAccent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.delete_outline,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Anda dapat menambahkan beberapa foto struk. Maks 5 foto.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () async {
                                  final ok = await controller.saveTransaction(
                                    type,
                                  );
                                  if (ok) {
                                    SuccessModal.show();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Simpan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          _buildNumpad(controller),
        ],
      ),
    );
  }

  Widget _buildNumpad(TransactionController controller) {
    final keys = [
      ['C', '÷', 'C', '⌫'],
      ['7', '8', '9', '-'],
      ['4', '5', '6', '+'],
      ['1', '2', '3', '='],
      ['0', '00', '000', 'OK'],
    ];

    return Container(
      color: const Color(0xFFF5F5F5),
      child: Column(
        children: keys.map((row) {
          return Row(
            children: row.map((key) {
              final isBackspace = key == '⌫';
              final isOk = key == 'OK';
              final isOperator = ['÷', '-', '+', '='].contains(key);

              Color bgColor = Colors.white;
              Color textColor = Colors.black87;

              if (isBackspace) {
                bgColor = const Color(0xFFE74C3C);
                textColor = Colors.white;
              } else if (isOk) {
                bgColor = Colors.black;
                textColor = Colors.white;
              }

              return Expanded(
                child: GestureDetector(
                  onTap: () => controller.onNumpadTap(key),
                  child: Container(
                    height: 56,
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: bgColor,
                      border: Border.all(
                        color: const Color(0xFFEEEEEE),
                        width: 0.5,
                      ),
                    ),
                    child: Center(
                      child: isBackspace
                          ? const Icon(
                              Icons.backspace_outlined,
                              color: Colors.white,
                              size: 20,
                            )
                          : Text(
                              key,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isOperator
                                    ? FontWeight.w400
                                    : FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
