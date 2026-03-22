import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../views/check_email_view.dart';

class ForgotPasswordController extends GetxController {
  final email = ''.obs;
  final loading = false.obs;
  final resendLoading = false.obs;

  void sendResetEmail() async {
    final emailText = email.value.trim();
    if (emailText.isEmpty) {
      Get.snackbar(
        'Error',
        'Silakan masukkan email Anda',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    loading.value = true;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailText);

      Get.to(() => const CheckEmailView());
    } on FirebaseAuthException catch (e) {
      String message = 'Terjadi kesalahan';
      if (e.code == 'user-not-found') {
        message = 'Email tidak terdaftar';
      } else if (e.code == 'invalid-email') {
        message = 'Format email tidak valid';
      }
      Get.snackbar('Error', message, snackPosition: SnackPosition.TOP);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengirim email reset sandi',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      loading.value = false;
    }
  }

  void resendResetEmail() async {
    final emailText = email.value.trim();
    if (emailText.isEmpty) {
      Get.snackbar(
        'Error',
        'Email tidak ditemukan, kembali dan coba lagi',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    resendLoading.value = true;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailText);
      Get.snackbar(
        'Berhasil',
        'Email reset sandi telah dikirim ulang ke $emailText',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Terjadi kesalahan';
      if (e.code == 'user-not-found') {
        message = 'Email tidak terdaftar';
      } else if (e.code == 'invalid-email') {
        message = 'Format email tidak valid';
      } else if (e.code == 'too-many-requests') {
        message = 'Terlalu banyak permintaan, coba lagi nanti';
      }
      Get.snackbar('Error', message, snackPosition: SnackPosition.TOP);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengirim ulang email reset sandi',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      resendLoading.value = false;
    }
  }
}
