import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_app_bar.dart';

import '../../../../core/i18n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

class WalletTopupScreen extends StatelessWidget {
  const WalletTopupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);

    final walletMethods = [
      {
        'titleAr': 'جيب',
        'titleEn': 'Jeeb',
        'subtitleAr': 'تحويل فوري إلى رصيد التطبيق',
        'subtitleEn': 'Instant transfer to app balance',
        'icon': Icons.account_balance_wallet_outlined,
        'color': AppColors.primaryGreen,
      },
      {
        'titleAr': 'بنك اليمن الكويتي',
        'titleEn': 'Yemen Kuwait Bank',
        'subtitleAr': 'شحن عبر خدمة البنك',
        'subtitleEn': 'Top-up via bank service',
        'icon': Icons.account_balance_outlined,
        'color': AppColors.primaryBlue,
      },
    ];

    final walletHistory = [
      {
        'titleAr': 'شحن عبر جيب',
        'titleEn': 'Top-up via Jeeb',
        'amount': '100,000 YER',
        'dateAr': '2026-05-15 12:10 ص',
        'dateEn': '2026-05-15 12:10 AM',
        'status': 'success',
      },
      {
        'titleAr': 'شحن عبر بنك اليمن الكويتي',
        'titleEn': 'Top-up via Yemen Kuwait Bank',
        'amount': '50,000 YER',
        'dateAr': '2026-05-14 08:30 م',
        'dateEn': '2026-05-14 08:30 PM',
        'status': 'pending',
      },
    ];

    return Scaffold(
      appBar: CustomAppBar(
        title: s.wallet,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  const Text(
                    '450,000 YER',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
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
            ...walletMethods.map((method) {
              final title = s.isArabic
                  ? method['titleAr'] as String
                  : method['titleEn'] as String;

              final subtitle = s.isArabic
                  ? method['subtitleAr'] as String
                  : method['subtitleEn'] as String;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _WalletMethodCard(
                  title: title,
                  subtitle: subtitle,
                  icon: method['icon'] as IconData,
                  color: method['color'] as Color,
                  buttonText: s.topup,
                ),
              );
            }),
            const SizedBox(height: 10),
            Text(
              s.lastTopups,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...walletHistory.map((item) {
              final title = s.isArabic
                  ? item['titleAr'] as String
                  : item['titleEn'] as String;

              final date = s.isArabic
                  ? item['dateAr'] as String
                  : item['dateEn'] as String;

              final isSuccess = item['status'] == 'success';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _WalletHistoryCard(
                  title: title,
                  amount: item['amount'] as String,
                  date: date,
                  status: isSuccess ? s.successful : s.pending,
                ),
              );
            }),
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

  const _WalletMethodCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.buttonText,
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
                    onPressed: () {},
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

class _WalletHistoryCard extends StatelessWidget {
  final String title;
  final String amount;
  final String date;
  final String status;

  const _WalletHistoryCard({
    required this.title,
    required this.amount,
    required this.date,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final isSuccess = status == s.successful;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                amount,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  date,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: (isSuccess ? AppColors.primaryGreen : Colors.orange)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: isSuccess ? AppColors.primaryGreen : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}