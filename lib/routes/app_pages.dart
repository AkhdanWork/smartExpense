import 'package:get/get.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/home/views/home_view.dart';
import '../modules/transaction/views/add_transaction_page.dart';
import '../modules/transaction/views/category_picker_page.dart';
import '../modules/transaction/views/transaction_history_page.dart';
import '../modules/transaction/views/transaction_detail_page.dart';
import '../modules/profile/views/reset_password_page.dart';
import '../modules/auth/views/forgot_password_view.dart';
import '../modules/auth/views/check_email_view.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(name: Routes.login, page: () => const LoginView()),
    GetPage(name: Routes.register, page: () => const RegisterView()),
    GetPage(name: Routes.home, page: () => const HomeView()),
    GetPage(
      name: Routes.addTransaction,
      page: () => const AddTransactionPage(),
    ),
    GetPage(
      name: Routes.categoryPicker,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        return CategoryPickerPage(type: args['type'] ?? 'pengeluaran');
      },
    ),
    GetPage(
      name: Routes.transactionHistory,
      page: () => const TransactionHistoryPage(),
    ),
    GetPage(
      name: Routes.transactionDetail,
      page: () => const TransactionDetailPage(),
    ),
    GetPage(name: Routes.resetPassword, page: () => const ResetPasswordPage()),
    GetPage(
      name: Routes.forgotPassword,
      page: () => const ForgotPasswordView(),
    ),
    GetPage(name: Routes.checkEmail, page: () => const CheckEmailView()),
  ];
}
