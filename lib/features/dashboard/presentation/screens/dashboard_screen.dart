import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/i18n/app_strings.dart';
import '../../../../core/i18n/locale_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../products/presentation/screens/products_screen.dart';
import '../../../recharge/presentation/widgets/quick_recharge_sheet.dart';
import '../../../transactions/presentation/screens/transactions_screen.dart';
import '../../../wallet/presentation/screens/wallet_topup_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int currentIndex = 0;
  DateTime? _lastBackPressedAt;

  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  Future<void> _openQuickRechargeSheet({
    required BuildContext context,
    required int serviceId,
    required String serviceName,
  }) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuickRechargeSheet(
        serviceId: serviceId,
        serviceName: serviceName,
        onSuccess: (result) async {
          if (!mounted) return;
          setState(() {});
        },
      ),
    );

    if (!mounted) return;

    if (result != null && result['success'] == true) {
      final message = result['message']?.toString() ??
          'تم إرسال طلب $serviceName بنجاح';

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ),
        );
    }
  }

  Future<void> _handleBackPressed() async {
    if (navigatorKey.currentState?.canPop() == true) {
      navigatorKey.currentState!.pop();
      return;
    }

    if (currentIndex != 0) {
      setState(() {
        currentIndex = 0;
      });
      return;
    }

    final now = DateTime.now();

    if (_lastBackPressedAt == null ||
        now.difference(_lastBackPressedAt!) > const Duration(seconds: 2)) {
      _lastBackPressedAt = now;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('اضغط مرة أخرى للخروج'),
            duration: Duration(seconds: 2),
          ),
        );

      return;
    }

    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final authProvider = context.watch<AuthProvider>();
    final userName =
        authProvider.user?.firstName ?? authProvider.user?.phone ?? '';

    final pages = [
      _HomeTab(
        strings: s,
        userName: userName,
        onQuickRechargeTap: ({
          required int serviceId,
          required String serviceName,
        }) {
          _openQuickRechargeSheet(
            context: context,
            serviceId: serviceId,
            serviceName: serviceName,
          );
        },
      ),
      const ProductsScreen(),
      const TransactionsScreen(),
      const WalletTopupScreen(),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackPressed();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.appName),
          actions: [
            Consumer<LocaleController>(
              builder: (context, localeController, _) {
                return TextButton(
                  onPressed: localeController.toggleLocale,
                  child: Text(
                    localeController.isArabic ? 'EN' : 'AR',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.account_circle_outlined),
              color: AppColors.cardDark,
              onSelected: (value) async {
                if (value == 'logout') {
                  await context.read<AuthProvider>().logout();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('تسجيل الخروج'),
                ),
              ],
            ),
          ],
        ),
        body: IndexedStack(
          index: currentIndex,
          children: pages,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: const Color(0xFF25D366),
          child: const Icon(Icons.support_agent, color: Colors.white),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => setState(() => currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surfaceDark,
          selectedItemColor: AppColors.primaryGreen,
          unselectedItemColor: AppColors.textSecondary,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_outlined),
              label: s.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.grid_view_rounded),
              label: s.products,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.receipt_long_outlined),
              label: s.transactions,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.account_balance_wallet_outlined),
              label: s.wallet,
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final AppStrings strings;
  final String userName;
  final void Function({
  required int serviceId,
  required String serviceName,
  }) onQuickRechargeTap;

  const _HomeTab({
    required this.strings,
    required this.userName,
    required this.onQuickRechargeTap,
  });

  @override
  Widget build(BuildContext context) {
    final welcomeText = userName.isNotEmpty
        ? '${strings.welcome}، $userName'
        : strings.welcome;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            welcomeText,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            strings.dashboardSubtitle,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          _SectionTitle(title: strings.balances),
          const SizedBox(height: 12),
          _BalanceCard(
            title: strings.yerBalance,
            amount: '450,000 YER',
            color: AppColors.primaryGreen,
            icon: Icons.account_balance_wallet_outlined,
          ),
          const SizedBox(height: 12),
          _BalanceCard(
            title: strings.usdBalance,
            amount: '1,250 USD',
            color: AppColors.primaryBlue,
            icon: Icons.attach_money,
          ),
          const SizedBox(height: 22),
          _SectionTitle(title: strings.todayStats),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: strings.todayOrders,
                  value: '58',
                  icon: Icons.shopping_bag_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: strings.successful,
                  value: '49',
                  icon: Icons.check_circle_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: strings.pending,
                  value: '9',
                  icon: Icons.schedule_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: strings.todaySales,
                  value: '82,000',
                  icon: Icons.bar_chart_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _SectionTitle(title: strings.quickRecharge),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: [
              _QuickActionCard(
                title: 'PUBG',
                icon: Icons.sports_esports,
                onTap: () => onQuickRechargeTap(
                  serviceId: 1,
                  serviceName: 'PUBG',
                ),
              ),
              _QuickActionCard(
                title: 'Free Fire',
                icon: Icons.local_fire_department_outlined,
                onTap: () => onQuickRechargeTap(
                  serviceId: 2,
                  serviceName: 'Free Fire',
                ),
              ),
              _QuickActionCard(
                title: 'iTunes',
                icon: Icons.card_giftcard,
                onTap: () => onQuickRechargeTap(
                  serviceId: 3,
                  serviceName: 'iTunes',
                ),
              ),
              _QuickActionCard(
                title: 'Google Play',
                icon: Icons.play_circle_outline,
                onTap: () => onQuickRechargeTap(
                  serviceId: 4,
                  serviceName: 'Google Play',
                ),
              ),
              _QuickActionCard(
                title: 'يمن موبايل',
                icon: Icons.phone_android,
                onTap: () => onQuickRechargeTap(
                  serviceId: 5,
                  serviceName: 'يمن موبايل',
                ),
              ),
              _QuickActionCard(
                title: 'You / Sabafon',
                icon: Icons.sim_card_outlined,
                onTap: () => onQuickRechargeTap(
                  serviceId: 6,
                  serviceName: 'You / Sabafon',
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _SectionTitle(title: strings.walletTopup),
          const SizedBox(height: 12),
          _WalletButton(
            title: strings.topupViaJeeb,
            icon: Icons.account_balance_wallet,
          ),
          const SizedBox(height: 12),
          _WalletButton(
            title: strings.topupViaKYB,
            icon: Icons.account_balance,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;
  final IconData icon;

  const _BalanceCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  amount,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryBlue),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryGreen, size: 28),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletButton extends StatelessWidget {
  final String title;
  final IconData icon;

  const _WalletButton({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, color: AppColors.primaryBlue),
        label: Text(title),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}