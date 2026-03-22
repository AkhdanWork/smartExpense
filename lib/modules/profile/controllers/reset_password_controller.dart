import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPasswordController extends GetxController {
  final oldPassword = ''.obs;
  final newPassword = ''.obs;
  final confirmPassword = ''.obs;
  final loading = false.obs;

  final obscureOld = true.obs;
  final obscureNew = true.obs;
  final obscureConfirm = true.obs;

  final errorOld = Rxn<String>();
  final errorNew = Rxn<String>();
  final errorConfirm = Rxn<String>();

  void onOldChanged(String v) {
    oldPassword.value = v;
    if (errorOld.value != null) _validateOld();
  }

  void onNewChanged(String v) {
    newPassword.value = v;
    if (errorNew.value != null) _validateNew();
    if (errorConfirm.value != null) _validateConfirm();
  }

  void onConfirmChanged(String v) {
    confirmPassword.value = v;
    if (errorConfirm.value != null) _validateConfirm();
  }

  bool _validateOld() {
    if (oldPassword.value.isEmpty) {
      errorOld.value = 'Kata sandi lama tidak boleh kosong';
      return false;
    }
    errorOld.value = null;
    return true;
  }

  bool _validateNew() {
    if (newPassword.value.isEmpty) {
      errorNew.value = 'Kata sandi baru tidak boleh kosong';
      return false;
    }
    if (newPassword.value.length < 6) {
      errorNew.value = 'Kata sandi minimal 6 karakter';
      return false;
    }
    errorNew.value = null;
    return true;
  }

  bool _validateConfirm() {
    if (confirmPassword.value.isEmpty) {
      errorConfirm.value = 'Konfirmasi kata sandi tidak boleh kosong';
      return false;
    }
    if (confirmPassword.value != newPassword.value) {
      errorConfirm.value = 'Kata sandi tidak cocok';
      return false;
    }
    errorConfirm.value = null;
    return true;
  }

  Future<void> resetPassword() async {
    final valid = _validateOld() & _validateNew() & _validateConfirm();
    if (!valid) return;

    loading.value = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) throw Exception('User not found');

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword.value,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword.value);

      _showSuccessModal();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' ||
          e.code == 'invalid-credential' ||
          e.code == 'user-mismatch') {
        errorOld.value = 'Kata sandi lama salah';
      } else {
        Get.snackbar(
          'Gagal',
          'Gagal mengubah kata sandi: ${e.message}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFF3506B),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan, coba lagi',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFF3506B),
        colorText: Colors.white,
      );
    } finally {
      loading.value = false;
    }
  }

  void _showSuccessModal() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Image(
                  image: AssetImage(
                    'assets/icons/transaksi_tersimpan_icon.png',
                  ),
                  color: Color(0xFF2ECC71),
                  width: 28,
                  height: 28,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Kata Sandi Berhasil Diubah',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Kata sandi akun Anda telah berhasil diperbarui.',
                style: TextStyle(fontSize: 13, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Get.back();
                    Get.back();
                  },
                  child: const Text(
                    'Kembali ke Akun',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
