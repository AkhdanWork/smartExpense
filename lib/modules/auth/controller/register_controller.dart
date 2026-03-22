import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_expense/service/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../routes/app_routes.dart';

class RegisterController extends GetxController {
  final _fb = FirebaseService();

  final name = ''.obs;
  final email = ''.obs;
  final password = ''.obs;
  final confirmPassword = ''.obs;

  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;

  final loading = false.obs;

  Future<void> register() async {
    if (name.value.trim().isEmpty ||
        email.value.trim().isEmpty ||
        password.value.isEmpty ||
        confirmPassword.value.isEmpty) {
      Get.snackbar('Error', 'Semua field wajib diisi');
      return;
    }

    if (password.value != confirmPassword.value) {
      Get.snackbar('Error', 'Kata sandi dan konfirmasi tidak cocok');
      return;
    }

    loading.value = true;
    try {
      final cred = await _fb.auth.createUserWithEmailAndPassword(
        email: email.value.trim(),
        password: password.value,
      );
      await _fb.db.collection('users').doc(cred.user!.uid).set({
        'name': name.value.trim(),
        'email': email.value.trim(),
        'role': 'customer',
        'createdAt': FieldValue.serverTimestamp(),
        'balance': 0,
        'transactions': [],
      });
      try {
        await cred.user!.updateDisplayName(name.value.trim());
        await cred.user!.reload();
      } catch (_) {}
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 60),
                const SizedBox(height: 16),
                const Text(
                  'Berhasil',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Akun telah berhasil dibuat',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Get.back();
                      Get.offAllNamed(Routes.home);
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
    } catch (e) {
      Get.snackbar('Register gagal', e.toString());
    } finally {
      loading.value = false;
    }
  }
}
