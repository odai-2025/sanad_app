import 'package:flutter/material.dart';

import '../../../../core/i18n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);

    final items = [
      {
        'titleAr': 'ببجي',
        'titleEn': 'PUBG',
        'subtitleAr': 'شحن شدات',
        'subtitleEn': 'UC Top-up',
        'icon': Icons.sports_esports,
      },
      {
        'titleAr': 'فري فاير',
        'titleEn': 'Free Fire',
        'subtitleAr': 'شحن جواهر',
        'subtitleEn': 'Diamonds Top-up',
        'icon': Icons.local_fire_department_outlined,
      },
      {
        'titleAr': 'آيتونز',
        'titleEn': 'iTunes',
        'subtitleAr': 'بطاقات رقمية',
        'subtitleEn': 'Digital Cards',
        'icon': Icons.card_giftcard,
      },
      {
        'titleAr': 'جوجل بلاي',
        'titleEn': 'Google Play',
        'subtitleAr': 'بطاقات متجر',
        'subtitleEn': 'Store Cards',
        'icon': Icons.play_circle_outline,
      },
      {
        'titleAr': 'يمن موبايل',
        'titleEn': 'Yemen Mobile',
        'subtitleAr': 'رصيد وباقات',
        'subtitleEn': 'Credit & Bundles',
        'icon': Icons.phone_android,
      },
      {
        'titleAr': 'يو',
        'titleEn': 'You',
        'subtitleAr': 'رصيد وباقات',
        'subtitleEn': 'Credit & Bundles',
        'icon': Icons.sim_card_outlined,
      },
      {
        'titleAr': 'سبأفون',
        'titleEn': 'Sabafon',
        'subtitleAr': 'رصيد وباقات',
        'subtitleEn': 'Credit & Bundles',
        'icon': Icons.network_cell,
      },
      {
        'titleAr': 'بطاقات أخرى',
        'titleEn': 'Other Cards',
        'subtitleAr': 'خدمات إضافية',
        'subtitleEn': 'Extra Services',
        'icon': Icons.apps_rounded,
      },
    ];

    return Scaffold(
      appBar: CustomAppBar(
        title: s.products,
        showBackButton: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              s.products,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: s.searchProduct,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.05,
              ),
              itemBuilder: (context, index) {
                final item = items[index];

                final title = s.isArabic
                    ? item['titleAr'] as String
                    : item['titleEn'] as String;

                final subtitle = s.isArabic
                    ? item['subtitleAr'] as String
                    : item['subtitleEn'] as String;

                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.14),                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: AppColors.primaryBlue,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}