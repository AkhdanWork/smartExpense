import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'modules/auth/controller/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SmartExpenseApp());
}

class SmartExpenseApp extends StatelessWidget {
  const SmartExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AuthController(), permanent: true);

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartExpense',
      initialRoute: FirebaseAuth.instance.currentUser != null
          ? Routes.home
          : Routes.login,
      getPages: AppPages.pages,
    );
  }
}
