import 'dart:async';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_expense/service/firebase_service.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final _fb = FirebaseService();
  final Rxn<User> firebaseUser = Rxn<User>();
  StreamSubscription<User?>? _sub;

  @override
  void onInit() {
    super.onInit();
    _sub = _fb.auth.authStateChanges().listen((user) {
      firebaseUser.value = user;

      final route = Get.currentRoute;
      if (user == null) {
        if (route != Routes.login &&
            route != Routes.register &&
            route != Routes.forgotPassword) {
          Get.offAllNamed(Routes.login);
        }
      } else {
        if (route != Routes.home && route != Routes.register) {
          Get.offAllNamed(Routes.home);
        }
      }
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _fb.auth.signOut();
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
