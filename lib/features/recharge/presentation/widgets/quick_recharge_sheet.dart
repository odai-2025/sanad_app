import 'package:flutter/material.dart';
import 'package:sanad_app/core/i18n/app_strings.dart';
import 'package:sanad_app/core/theme/app_colors.dart';
import 'package:sanad_app/features/order/data/services/orders_service.dart';

class QuickRechargeSheet extends StatefulWidget {
  final int serviceId;
  final String serviceName;
  final Future<void> Function(Map<String, dynamic> result)? onSuccess;

  const QuickRechargeSheet({
    super.key,
    required this.serviceId,
    required this.serviceName,
    this.onSuccess,
  });

  @override
  State<QuickRechargeSheet> createState() => _QuickRechargeSheetState();
}

class _QuickRechargeSheetState extends State<QuickRechargeSheet> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  final OrdersService _ordersService = OrdersService();

  final List<int> _quickAmounts = [500, 1000, 2000, 5000, 10000];

  int? _selectedAmount;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _selectAmount(int amount) {
    if (_isSubmitting) return;

    setState(() {
      _selectedAmount = amount;
      _amountController.text = amount.toString();
    });
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    final s = AppStrings.of(context);
    final amount = num.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            s.isArabic ? 'أدخل مبلغًا صحيحًا' : 'Enter a valid amount',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSubmitting = true;
    });

    final result = await _ordersService.createOrder(
      serviceId: widget.serviceId,
      targetAccount: _phoneController.text.trim(),
      amount: amount,
    );

    if (!mounted) return;

    final message = result['message']?.toString() ??
        (s.isArabic ? 'نتيجة غير متوقعة' : 'Unexpected result');

    if (result['success'] == true) {
      final successResult = <String, dynamic>{
        'success': true,
        'message': message,
        'data': result['data'],
        'serviceId': widget.serviceId,
        'serviceName': widget.serviceName,
        'targetAccount': _phoneController.text.trim(),
        'amount': amount,
      };

      if (widget.onSuccess != null) {
        await widget.onSuccess!(successResult);
      }

      if (!mounted) return;

      Navigator.of(context).pop(successResult);
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 24,
          bottom: bottomInset + 16,
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
                bottom: Radius.circular(28),
              ),
              border: Border.all(color: AppColors.border),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    s.isArabic ? 'شحن سريع' : 'Quick Recharge',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.serviceName,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    enabled: !_isSubmitting,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: s.isArabic ? 'رقم الهاتف' : 'Phone Number',
                      hintText: s.isArabic
                          ? 'أدخل رقم الهاتف'
                          : 'Enter phone number',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.phone_android),
                    ),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) {
                        return s.isArabic
                            ? 'رقم الهاتف مطلوب'
                            : 'Phone number is required';
                      }
                      if (text.length < 9) {
                        return s.isArabic
                            ? 'أدخل رقم هاتف صحيح'
                            : 'Enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    enabled: !_isSubmitting,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: s.amount,
                      hintText: s.isArabic ? 'أدخل المبلغ' : 'Enter amount',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.payments_outlined),
                    ),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) {
                        return s.isArabic
                            ? 'المبلغ مطلوب'
                            : 'Amount is required';
                      }

                      final amount = int.tryParse(text);
                      if (amount == null || amount <= 0) {
                        return s.isArabic
                            ? 'أدخل مبلغًا صحيحًا'
                            : 'Enter a valid amount';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    s.isArabic ? 'مبالغ سريعة' : 'Quick Amounts',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _quickAmounts.map((amount) {
                      final isSelected = _selectedAmount == amount;

                      return ChoiceChip(
                        label: Text('$amount'),
                        selected: isSelected,
                        onSelected: _isSubmitting
                            ? null
                            : (_) => _selectAmount(amount),
                        selectedColor: AppColors.primaryGreen,
                        backgroundColor: AppColors.cardDark,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                        side: const BorderSide(color: AppColors.border),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: _isSubmitting
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : Text(
                          s.isArabic ? 'متابعة' : 'Continue',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}