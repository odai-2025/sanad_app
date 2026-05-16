import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/i18n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String selectedFilter = 'all';

  final List<Map<String, dynamic>> transactions = [
    {
      'id': '#TX1001',
      'titleAr': 'شحن ببجي',
      'titleEn': 'PUBG Top-up',
      'amount': '4,500 YER',
      'status': 'success',
      'dateAr': '2026-05-15 12:20 ص',
      'dateEn': '2026-05-15 12:20 AM',
      'customerAr': 'أحمد',
      'customerEn': 'Ahmed',
    },
    {
      'id': '#TX1002',
      'titleAr': 'شحن يمن موبايل',
      'titleEn': 'Yemen Mobile Top-up',
      'amount': '2,000 YER',
      'status': 'pending',
      'dateAr': '2026-05-15 12:35 ص',
      'dateEn': '2026-05-15 12:35 AM',
      'customerAr': 'محمد',
      'customerEn': 'Mohammed',
    },
    {
      'id': '#TX1003',
      'titleAr': 'بطاقة جوجل بلاي',
      'titleEn': 'Google Play Card',
      'amount': '10 USD',
      'status': 'success',
      'dateAr': '2026-05-15 12:40 ص',
      'dateEn': '2026-05-15 12:40 AM',
      'customerAr': 'خالد',
      'customerEn': 'Khaled',
    },
    {
      'id': '#TX1004',
      'titleAr': 'شحن فري فاير',
      'titleEn': 'Free Fire Top-up',
      'amount': '3,000 YER',
      'status': 'pending',
      'dateAr': '2026-05-15 12:50 ص',
      'dateEn': '2026-05-15 12:50 AM',
      'customerAr': 'ناصر',
      'customerEn': 'Nasser',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);

    final filteredTransactions = selectedFilter == 'all'
        ? transactions
        : transactions.where((tx) => tx['status'] == selectedFilter).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            s.transactionHistory,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _FilterChip(
                label: s.all,
                selected: selectedFilter == 'all',
                onTap: () => setState(() => selectedFilter = 'all'),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: s.successful,
                selected: selectedFilter == 'success',
                onTap: () => setState(() => selectedFilter = 'success'),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: s.pending,
                selected: selectedFilter == 'pending',
                onTap: () => setState(() => selectedFilter = 'pending'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filteredTransactions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final tx = filteredTransactions[index];
              final isSuccess = tx['status'] == 'success';

              final title = s.isArabic
                  ? tx['titleAr'] as String
                  : tx['titleEn'] as String;

              final date = s.isArabic
                  ? tx['dateAr'] as String
                  : tx['dateEn'] as String;

              final customer = s.isArabic
                  ? tx['customerAr'] as String
                  : tx['customerEn'] as String;

              final detailsData = {
                'id': tx['id'],
                'title': title,
                'amount': tx['amount'],
                'status': isSuccess ? s.successful : s.pending,
                'date': date,
                'customer': customer,
              };

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  context.push('/transaction-details', extra: detailsData);
                },
                child: Container(
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
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: (isSuccess
                                  ? AppColors.primaryGreen
                                  : Colors.orange)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isSuccess
                                  ? Icons.check_circle_outline
                                  : Icons.schedule_outlined,
                              color: isSuccess
                                  ? AppColors.primaryGreen
                                  : Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                  tx['id'] as String,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: (isSuccess
                                  ? AppColors.primaryGreen
                                  : Colors.orange)
                                  .withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              isSuccess ? s.successful : s.pending,
                              style: TextStyle(
                                color: isSuccess
                                    ? AppColors.primaryGreen
                                    : Colors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
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
                          Text(
                            tx['amount'] as String,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primaryGreen,
      backgroundColor: AppColors.cardDark,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
      side: const BorderSide(color: AppColors.border),
    );
  }
}