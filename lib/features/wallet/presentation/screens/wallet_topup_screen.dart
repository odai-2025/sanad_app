import 'package:flutter/material.dart';

import '../../../../core/i18n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/services/wallet_service.dart';
import '../../../recharge/data/services/recharge_service.dart';

class WalletTopupScreen extends StatefulWidget {
  const WalletTopupScreen({super.key});

  @override
  State<WalletTopupScreen> createState() => _WalletTopupScreenState();
}

class _WalletTopupScreenState extends State<WalletTopupScreen> {
  final WalletService _walletService = WalletService();
  final RechargeService _rechargeService = RechargeService();

  bool _isLoading = true;
  String? _errorMessage;

  Map<String, dynamic> _wallet = {};
  List<Map<String, dynamic>> _topupMethods = [];

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final walletResult = await _walletService.getWallet();
      final methodsResult = await _rechargeService.getTopupMethods();

      if (!mounted) return;

      final hasWalletSuccess = walletResult['success'] == true;
      final hasMethodsSuccess = methodsResult['success'] == true;

      final walletData = walletResult['data'];
      final methodsData = methodsResult['data'];

      List<Map<String, dynamic>> parsedMethods = [];

      if (methodsData is List) {
        parsedMethods = methodsData
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }

      setState(() {
        _wallet = walletData is Map
            ? Map<String, dynamic>.from(walletData)
            : <String, dynamic>{};

        _topupMethods = parsedMethods;
        _isLoading = false;

        if (!hasWalletSuccess && !hasMethodsSuccess) {
          _errorMessage = walletResult['message']?.toString() ??
              methodsResult['message']?.toString() ??
              'Failed to load wallet data';
        } else if (!hasWalletSuccess) {
          _errorMessage = walletResult['message']?.toString();
        } else if (!hasMethodsSuccess) {
          _errorMessage = methodsResult['message']?.toString();
        } else {
          _errorMessage = null;
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _wallet = {};
        _topupMethods = [];
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  String _walletBalance() {
    final balance = _wallet['balance'];
    final currency = (_wallet['currency_code'] ?? 'YER').toString();

    if (balance == null) return '0.00 $currency';
    return '${balance.toString()} $currency';
  }

  String _methodTitle(Map<String, dynamic> method, AppStrings s) {
    final ar = method['name_ar']?.toString().trim();
    final en = method['name_en']?.toString().trim();
    final name = method['name']?.toString().trim();

    if (s.isArabic) {
      if (ar != null && ar.isNotEmpty) return ar;
      if (name != null && name.isNotEmpty) return name;
      return en ?? '';
    }

    if (en != null && en.isNotEmpty) return en;
    if (name != null && name.isNotEmpty) return name;
    return ar ?? '';
  }

  String _methodSubtitle(Map<String, dynamic> method, AppStrings s) {
    final instructions = method['instructions']?.toString().trim();
    final accountName = method['account_name']?.toString().trim();
    final accountNumber = method['account_number']?.toString().trim();

    if (instructions != null && instructions.isNotEmpty) {
      return instructions;
    }

    if (accountName != null && accountName.isNotEmpty) {
      if (accountNumber != null && accountNumber.isNotEmpty) {
        return '$accountName - $accountNumber';
      }
      return accountName;
    }

    return s.isArabic ? 'طريقة شحن متاحة' : 'Available top-up method';
  }

  IconData _resolveMethodIcon(Map<String, dynamic> method) {
    final code = (method['code'] ?? '').toString().toLowerCase();
    final type = (method['type'] ?? '').toString().toLowerCase();
    final nameAr = (method['name_ar'] ?? '').toString().toLowerCase();
    final nameEn = (method['name_en'] ?? '').toString().toLowerCase();

    final joined = '$code $type $nameAr $nameEn';

    if (joined.contains('jeeb')) return Icons.account_balance_wallet_outlined;
    if (joined.contains('wallet')) return Icons.account_balance_wallet_outlined;
    if (joined.contains('bank')) return Icons.account_balance_outlined;
    if (joined.contains('cash')) return Icons.storefront_outlined;

    return Icons.payments_outlined;
  }

  Color _resolveMethodColor(Map<String, dynamic> method) {
    final code = (method['code'] ?? '').toString().toLowerCase();
    final type = (method['type'] ?? '').toString().toLowerCase();
    final name = '${method['name_ar'] ?? ''} ${method['name_en'] ?? ''}'
        .toLowerCase();

    if (code.contains('jeeb') || name.contains('جيب')) {
      return AppColors.primaryGreen;
    }

    if (type.contains('bank') ||
        name.contains('bank') ||
        name.contains('بنك')) {
      return AppColors.primaryBlue;
    }

    return AppColors.primaryBlue;
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: s.wallet,
        showBackButton: false,
      ),
      body: RefreshIndicator(
        onRefresh: _loadWalletData,
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              s.wallet,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.availableBalance,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _walletBalance(),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.30),
                  ),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 22),
            Text(
              s.walletTopup,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            if (_topupMethods.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  s.isArabic
                      ? 'لا توجد وسائل شحن متاحة حالياً'
                      : 'No top-up methods available right now',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else
              ..._topupMethods.map((method) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _WalletMethodCard(
                    title: _methodTitle(method, s),
                    subtitle: _methodSubtitle(method, s),
                    icon: _resolveMethodIcon(method),
                    color: _resolveMethodColor(method),
                    buttonText: s.topup,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            s.isArabic
                                ? 'سيتم ربط إنشاء طلب الشحن الحقيقي في الخطوة التالية'
                                : 'Real top-up request creation will be connected in the next step',
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _WalletMethodCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String buttonText;
  final VoidCallback onTap;

  const _WalletMethodCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: ElevatedButton(
                    onPressed: onTap,
                    child: Text(buttonText),
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