import 'package:flutter/material.dart';

class AppStrings {
  final Locale locale;

  AppStrings(this.locale);

  static AppStrings of(BuildContext context) {
    return AppStrings(Localizations.localeOf(context));
  }

  bool get isArabic => locale.languageCode == 'ar';

  String get appName => isArabic ? 'سند' : 'Sanad';
  String get login => isArabic ? 'تسجيل الدخول' : 'Login';
  String get email => isArabic ? 'البريد الإلكتروني' : 'Email';
  String get password => isArabic ? 'كلمة المرور' : 'Password';
  String get signIn => isArabic ? 'دخول' : 'Sign In';
  String get continueWithGoogle =>
      isArabic ? 'المتابعة عبر Google' : 'Continue with Google';

  String get welcome => isArabic ? 'مرحبًا بك' : 'Welcome';
  String get dashboardSubtitle => isArabic
      ? 'إدارة الرصيد والشحن السريع لوكلاء المتاجر'
      : 'Manage balance and quick top-ups for store agents';

  String get balances => isArabic ? 'الأرصدة' : 'Balances';
  String get yerBalance =>
      isArabic ? 'الرصيد بالريال اليمني' : 'Balance in Yemeni Rial';
  String get usdBalance =>
      isArabic ? 'الرصيد بالدولار الأمريكي' : 'Balance in US Dollar';

  String get todayStats => isArabic ? 'إحصائيات اليوم' : 'Today Stats';
  String get todayOrders => isArabic ? 'طلبات اليوم' : 'Today Orders';
  String get successful => isArabic ? 'ناجح' : 'Successful';
  String get pending => isArabic ? 'معلق' : 'Pending';
  String get todaySales => isArabic ? 'مبيعات اليوم' : 'Today Sales';

  String get quickRecharge => isArabic ? 'الشحن السريع' : 'Quick Recharge';
  String get wallet => isArabic ? 'المحفظة' : 'Wallet';
  String get walletTopup => isArabic ? 'شحن المحفظة' : 'Wallet Top-up';
  String get topupViaJeeb => isArabic ? 'شحن عبر جيب' : 'Top up via Jeeb';
  String get topupViaKYB => isArabic
      ? 'شحن عبر بنك اليمن الكويتي'
      : 'Top up via Kuwait Yemen Bank';

  String get home => isArabic ? 'الرئيسية' : 'Home';
  String get products => isArabic ? 'المنتجات' : 'Products';
  String get transactions => isArabic ? 'المعاملات' : 'Transactions';

  String get transactionHistory =>
      isArabic ? 'سجل المعاملات' : 'Transaction History';
  String get all => isArabic ? 'الكل' : 'All';
  String get transactionDetails =>
      isArabic ? 'تفاصيل المعاملة' : 'Transaction Details';
  String get transactionId => isArabic ? 'رقم العملية' : 'Transaction ID';
  String get type => isArabic ? 'النوع' : 'Type';
  String get amount => isArabic ? 'المبلغ' : 'Amount';
  String get customer => isArabic ? 'العميل' : 'Customer';
  String get date => isArabic ? 'التاريخ' : 'Date';
  String get unknown => isArabic ? 'غير معروف' : 'Unknown';

  String get searchProduct => isArabic
      ? 'ابحث عن لعبة أو بطاقة أو شركة'
      : 'Search for a game, card, or company';

  String get availableBalance =>
      isArabic ? 'الرصيد المتاح' : 'Available Balance';
  String get lastTopups => isArabic ? 'آخر عمليات الشحن' : 'Latest Top-ups';
  String get topup => isArabic ? 'شحن' : 'Top Up';
  String get instantTransfer => isArabic
      ? 'تحويل فوري إلى رصيد التطبيق'
      : 'Instant transfer to app balance';
  String get bankTransfer =>
      isArabic ? 'شحن عبر خدمة البنك' : 'Top up through bank service';

  String get support => isArabic ? 'الدعم' : 'Support';

  String get phoneNumber => isArabic ? 'رقم الهاتف' : 'Phone Number';
  String get enterPhoneNumber =>
      isArabic ? 'أدخل رقم الهاتف' : 'Enter phone number';
  String get phoneNumberRequired =>
      isArabic ? 'رقم الهاتف مطلوب' : 'Phone number is required';
  String get invalidPhoneNumber =>
      isArabic ? 'رقم الهاتف غير صالح' : 'Invalid phone number';

  String get enterAmount => isArabic ? 'أدخل المبلغ' : 'Enter amount';
  String get amountRequired =>
      isArabic ? 'المبلغ مطلوب' : 'Amount is required';
  String get invalidAmount =>
      isArabic ? 'أدخل مبلغًا صحيحًا' : 'Enter a valid amount';

  String get continueText => isArabic ? 'متابعة' : 'Continue';
  String get dataEnteredSuccessfully =>
      isArabic ? 'تم إدخال البيانات بنجاح' : 'Data entered successfully';
}