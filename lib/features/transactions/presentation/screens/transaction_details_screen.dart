import 'package:flutter/material.dart';

import '../../../../core/i18n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
class TransactionDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const TransactionDetailsScreen({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final status = (data['status'] ?? s.unknown).toString();
    final isSuccess = status == 'ناجح' || status == 'Successful' || status == s.successful;

    return Scaffold(
      appBar: CustomAppBar(
        title: s.transactionDetails,
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
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
              Row(
                children: [
                  Icon(
                    isSuccess
                        ? Icons.check_circle_outline
                        : Icons.schedule_outlined,
                    color: isSuccess ? AppColors.primaryGreen : Colors.orange,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSuccess ? AppColors.primaryGreen : Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _DetailRow(
                label: s.transactionId,
                value: (data['id'] ?? '-').toString(),
              ),
              _DetailRow(
                label: s.type,
                value: (data['title'] ?? '-').toString(),
              ),
              _DetailRow(
                label: s.amount,
                value: (data['amount'] ?? '-').toString(),
              ),
              _DetailRow(
                label: s.customer,
                value: (data['customer'] ?? '-').toString(),
              ),
              _DetailRow(
                label: s.date,
                value: (data['date'] ?? '-').toString(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}