import 'package:flutter/material.dart';

class LocaleController extends ChangeNotifier {
  Locale _locale = const Locale('ar');

  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode == 'ar';

  void toggleLocale() {
    _locale = isArabic ? const Locale('en') : const Locale('ar');
    notifyListeners();
  }

  void setArabic() {
    _locale = const Locale('ar');
    notifyListeners();
  }

  void setEnglish() {
    _locale = const Locale('en');
    notifyListeners();
  }
}