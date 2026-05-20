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

  String _normalizeStatus(String status) {
    final value = status.toLowerCase().trim();

    if (value == 'ناجح' ||
        value == 'successful' ||
        value == 'success' ||
        value == 'completed') {
      return 'success';
    }

    if (value == 'معلق' ||
        value == 'pending' ||
        value == 'processing') {
      return 'pending';
    }

    if (value == 'فاشلة' ||
        value == 'failed' ||
        value == 'cancelled' ||
        value == 'rejected') {
      return 'failed';
    }

    return 'other';
  }

  Color _statusColor(String normalizedStatus) {
    switch (normalizedStatus) {
      case 'success':
        return AppColors.primaryGreen;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String normalizedStatus) {
    switch (normalizedStatus) {
      case 'success':
        return Icons.check_circle_outline;
      case 'pending':
        return Icons.schedule_outlined;
      case 'failed':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final rawStatus = (data['status'] ?? s.unknown).toString();
    final normalizedStatus = _normalizeStatus(rawStatus);
    final statusColor = _statusColor(normalizedStatus);

    return Scaffold(
      appBar: CustomAppBar(
        title: s.transactionDetails,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
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
                    _statusIcon(normalizedStatus),
                    color: statusColor,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    rawStatus,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
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
                value: (data['title'] ?? data['type'] ?? '-').toString(),
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
              _DetailRow(
                label: s.isArabic ? 'التصنيف' : 'Category',
                value: (data['category'] ?? '-').toString(),
              ),
              _DetailRow(
                label: s.isArabic ? 'ملاحظات' : 'Notes',
                value: (data['notes'] ?? '-').toString(),
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
              value.isEmpty ? '-' : value,
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