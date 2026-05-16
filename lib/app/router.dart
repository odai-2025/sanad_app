import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/transactions/presentation/screens/transaction_details_screen.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/transaction-details',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return TransactionDetailsScreen(data: extra ?? {});
      },
    ),
  ],
);