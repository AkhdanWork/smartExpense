import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reset_password_controller.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ResetPasswordController());
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Kembali',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'assets/icons/reset_pass_icon.png',
                  width: 180,
                  height: 180,
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Atur Ulang Kata Sandi',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Masukkan kata sandi baru anda di bawah ini, kami hanya ingin memberikan keamanan ekstra.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 36),

              _buildField(
                label: 'Kata Sandi Lama',
                hint: 'Masukkan kata sandi lama',
                controller: oldPassCtrl,
                obscure: c.obscureOld,
                error: c.errorOld,
                onToggle: () => c.obscureOld.toggle(),
                onChanged: c.onOldChanged,
              ),
              const SizedBox(height: 20),

              _buildField(
                label: 'Kata Sandi Baru',
                hint: 'Masukkan kata sandi baru',
                controller: newPassCtrl,
                obscure: c.obscureNew,
                error: c.errorNew,
                onToggle: () => c.obscureNew.toggle(),
                onChanged: c.onNewChanged,
              ),
              const SizedBox(height: 20),

              _buildField(
                label: 'Konfirmasi Kata Sandi',
                hint: 'Ulangi kata sandi baru',
                controller: confirmPassCtrl,
                obscure: c.obscureConfirm,
                error: c.errorConfirm,
                onToggle: () => c.obscureConfirm.toggle(),
                onChanged: c.onConfirmChanged,
              ),
              const SizedBox(height: 40),

              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    onPressed: c.loading.value ? null : c.resetPassword,
                    child: c.loading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Simpan',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required RxBool obscure,
    required Rxn<String> error,
    required VoidCallback onToggle,
    required Function(String) onChanged,
  }) {
    return Obx(() {
      final hasError = error.value != null;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: hasError ? const Color(0xFFE74C3C) : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            decoration: BoxDecoration(
              color: hasError
                  ? const Color(0xFFFFF0F0)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: hasError ? const Color(0xFFE74C3C) : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: controller,
              obscureText: obscure.value,
              onChanged: onChanged,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: hasError ? const Color(0xFFE74C3C) : Colors.black54,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscure.value ? Icons.visibility_off : Icons.visibility,
                    color: hasError ? const Color(0xFFE74C3C) : Colors.grey,
                  ),
                  onPressed: onToggle,
                ),
                border: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 14,
                    color: Color(0xFFE74C3C),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    error.value!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFE74C3C),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }
}
