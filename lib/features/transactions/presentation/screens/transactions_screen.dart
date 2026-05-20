import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/i18n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/services/transactions_service.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TransactionsService _transactionsService = TransactionsService();

  String selectedFilter = 'all';
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _transactionsService.getWalletTransactions();

      if (!mounted) return;

      if (result['success'] == true) {
        final rawData = result['data'];
        List<Map<String, dynamic>> transactionsList = [];

        if (rawData is List) {
          transactionsList = rawData
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        } else if (rawData is Map<String, dynamic> && rawData['data'] is List) {
          transactionsList = (rawData['data'] as List)
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }

        setState(() {
          _transactions = transactionsList;
          _isLoading = false;
        });
      } else {
        setState(() {
          _transactions = [];
          _errorMessage =
              result['message']?.toString() ?? 'Failed to load transactions';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _transactions = [];
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _normalizedStatus(dynamic value) {
    final status = (value ?? '').toString().toLowerCase();

    if (status == 'completed' || status == 'success') {
      return 'success';
    }

    if (status == 'pending' || status == 'processing') {
      return 'pending';
    }

    if (status == 'failed' || status == 'cancelled' || status == 'rejected') {
      return 'failed';
    }

    return 'other';
  }

  String _statusText(String normalizedStatus, AppStrings s) {
    switch (normalizedStatus) {
      case 'success':
        return s.successful;
      case 'pending':
        return s.pending;
      case 'failed':
        return s.isArabic ? 'فاشلة' : 'Failed';
      default:
        return s.isArabic ? 'أخرى' : 'Other';
    }
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

  String _formatAmount(Map<String, dynamic> tx) {
    final amount = tx['amount']?.toString() ?? '0';
    final currency = tx['currency_code']?.toString() ?? 'YER';
    return '$amount $currency';
  }

  String _titleFromTransaction(Map<String, dynamic> tx, AppStrings s) {
    final category = tx['category']?.toString().trim();
    final type = tx['type']?.toString().trim();

    if (category != null && category.isNotEmpty) {
      return category;
    }

    if (type != null && type.isNotEmpty) {
      return type;
    }

    return s.isArabic ? 'عملية' : 'Transaction';
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);

    final filteredTransactions = selectedFilter == 'all'
        ? _transactions
        : _transactions
        .where((tx) => _normalizedStatus(tx['status']) == selectedFilter)
        .toList();

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
              const SizedBox(width: 8),
              _FilterChip(
                label: s.isArabic ? 'فاشلة' : 'Failed',
                selected: selectedFilter == 'failed',
                onTap: () => setState(() => selectedFilter = 'failed'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _buildBody(s, filteredTransactions),
        ),
      ],
    );
  }

  Widget _buildBody(
      AppStrings s,
      List<Map<String, dynamic>> filteredTransactions,
      ) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return RefreshIndicator(
        onRefresh: _loadTransactions,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 120),
            const Icon(
              Icons.error_outline,
              color: Colors.orange,
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _loadTransactions,
                child: Text(
                  s.isArabic ? 'إعادة المحاولة' : 'Retry',
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (filteredTransactions.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadTransactions,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 140),
            Icon(
              Icons.receipt_long_outlined,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
              size: 46,
            ),
            const SizedBox(height: 12),
            Text(
              s.isArabic
                  ? 'لا توجد حركات متاحة'
                  : 'No transactions available',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: filteredTransactions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final tx = filteredTransactions[index];
          final normalizedStatus = _normalizedStatus(tx['status']);
          final statusColor = _statusColor(normalizedStatus);
          final statusLabel = _statusText(normalizedStatus, s);

          final title = _titleFromTransaction(tx, s);
          final date = (tx['created_at'] ?? '').toString();
          final txId = (tx['reference_no'] ?? tx['id'] ?? '').toString();
          final amount = _formatAmount(tx);

          final detailsData = {
            'id': txId,
            'title': title,
            'amount': amount,
            'status': statusLabel,
            'date': date,
            'customer': (tx['customer_name'] ?? '').toString(),
            'type': (tx['type'] ?? '').toString(),
            'category': (tx['category'] ?? '').toString(),
            'notes': (tx['notes'] ?? '').toString(),
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
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _statusIcon(normalizedStatus),
                          color: statusColor,
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
                              txId,
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
                          color: statusColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            color: statusColor,
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
                        amount,
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