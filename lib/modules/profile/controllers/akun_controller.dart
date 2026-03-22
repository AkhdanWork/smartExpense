import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/controller/auth_controller.dart';

class AkunController extends GetxController {
  final name = ''.obs;
  final email = ''.obs;
  final username = ''.obs;
  final loading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadLocalProfile();
    _loadProfile();
  }

  Future<void> _loadLocalProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final storedName = prefs.getString('user_name') ?? '';
    final storedEmail = prefs.getString('user_email') ?? '';

    if (storedName.trim().isNotEmpty) {
      name.value = storedName;
    } else {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        name.value = user.email!.split('@')[0];
      }
    }

    if (storedEmail.trim().isNotEmpty) {
      email.value = storedEmail;
    } else {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        email.value = user.email!;
      }
    }

    if (name.value.isNotEmpty || email.value.isNotEmpty) {
      username.value = _generateUsername(name.value, email.value);
      loading.value = false;
    }
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      email.value = user.email ?? '';

      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          final data = doc.data()!;
          name.value = (data['name'] ?? '').toString().trim();

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_name', name.value);
        }
      } catch (_) {}

      if (name.value.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final storedName = prefs.getString('user_name') ?? '';
        if (storedName.trim().isNotEmpty) {
          name.value = storedName;
        } else {
          name.value = user.displayName?.trim() ?? '';
          if (name.value.isEmpty && email.value.isNotEmpty) {
            name.value = email.value.split('@')[0];
          }
        }
      }

      username.value = _generateUsername(name.value, email.value);
    }
    loading.value = false;
  }

  String _generateUsername(String fullName, String email) {
    if (fullName.isNotEmpty && fullName != 'Pengguna') {
      return '@${fullName.split(' ').first.toLowerCase()}';
    }
    if (email.isNotEmpty) {
      return '@${email.split('@').first.toLowerCase()}';
    }
    return '@user';
  }

  void logout() {
    Get.find<AuthController>().logout();
  }

  void resetPassword() async {
    final userEmail = email.value;
    if (userEmail.isNotEmpty) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: userEmail);
        Get.snackbar(
          'Berhasil',
          'Tautan reset sandi telah dikirim ke $userEmail',
          snackPosition: SnackPosition.TOP,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Gagal mengirim email reset sandi',
          snackPosition: SnackPosition.TOP,
        );
      }
    }
  }
}
