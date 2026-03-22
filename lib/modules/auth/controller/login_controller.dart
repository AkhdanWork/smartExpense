import 'package:get/get.dart';
import 'package:smart_expense/service/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes/app_routes.dart';

class LoginController extends GetxController {
  final _fb = FirebaseService();

  final email = ''.obs;
  final password = ''.obs;
  final obscurePassword = true.obs;
  final loading = false.obs;

  Future<void> login() async {
    loading.value = true;
    try {
      await _fb.auth.signInWithEmailAndPassword(
        email: email.value.trim(),
        password: password.value,
      );

      final user = _fb.auth.currentUser;
      if (user != null) {
        try {
          final doc = await _fb.db.collection('users').doc(user.uid).get();
          if (doc.exists) {
            final data = doc.data()!;
            final name = (data['name'] ?? '').toString();
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('user_name', name);
            await prefs.setString('user_email', user.email ?? '');
          }
        } catch (_) {}
      }

      Get.offAllNamed(Routes.home);
    } catch (e) {
      Get.snackbar('Login gagal', e.toString());
    } finally {
      loading.value = false;
    }
  }
}
