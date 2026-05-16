import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/i18n/app_strings.dart';
import '../../../../core/i18n/locale_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _secondNameController = TextEditingController();
  final _thirdNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _countryCodeController = TextEditingController(text: '+967');
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedGender = 'male';

  @override
  void dispose() {
    _firstNameController.dispose();
    _secondNameController.dispose();
    _thirdNameController.dispose();
    _lastNameController.dispose();
    _countryCodeController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _t(
      AppStrings s, {
        required String ar,
        required String en,
      }) {
    return s.isArabic ? ar : en;
  }

  String? _validateName(String? value, AppStrings s, String label) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return _t(
        s,
        ar: '$label مطلوب',
        en: '$label is required',
      );
    }

    if (text.length < 2) {
      return _t(
        s,
        ar: '$label قصير جدًا',
        en: '$label is too short',
      );
    }

    final regex = RegExp(r'^[\u0600-\u06FFa-zA-Z\s]+$');
    if (!regex.hasMatch(text)) {
      return _t(
        s,
        ar: 'الاسم يقبل حروفًا فقط بدون أرقام أو رموز',
        en: 'Name accepts letters only without numbers or symbols',
      );
    }

    return null;
  }

  String? _validateCountryCode(String? value, AppStrings s) {
    final text = value?.trim() ?? '';
    if (text != '+967') {
      return _t(
        s,
        ar: 'مفتاح اليمن فقط',
        en: 'Yemen code only',
      );
    }
    return null;
  }

  String? _validatePhone(String? value, AppStrings s) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return _t(
        s,
        ar: 'بيانات الدخول غير صحيحة',
        en: 'Invalid login data',
      );
    }

    if (!RegExp(r'^\d+$').hasMatch(text)) {
      return _t(
        s,
        ar: 'بيانات الدخول غير صحيحة',
        en: 'Invalid login data',
      );
    }

    if (text.length != 9) {
      return _t(
        s,
        ar: 'بيانات الدخول غير صحيحة',
        en: 'Invalid login data',
      );
    }

    if (!RegExp(r'^(77|78|71|73)\d{7}$').hasMatch(text)) {
      return _t(
        s,
        ar: 'بيانات الدخول غير صحيحة',
        en: 'Invalid login data',
      );
    }

    return null;
  }

  String? _validatePassword(String? value, AppStrings s) {
    final text = value ?? '';

    if (text.isEmpty) {
      return _t(
        s,
        ar: 'كلمة المرور مطلوبة',
        en: 'Password is required',
      );
    }

    if (text.length < 6) {
      return _t(
        s,
        ar: 'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
        en: 'Password must be at least 6 characters',
      );
    }

    return null;
  }

  String? _validateConfirmPassword(String? value, AppStrings s) {
    final text = value ?? '';

    if (text.isEmpty) {
      return _t(
        s,
        ar: 'تأكيد كلمة المرور مطلوب',
        en: 'Confirm password is required',
      );
    }

    if (text != _passwordController.text) {
      return _t(
        s,
        ar: 'كلمتا المرور غير متطابقتين',
        en: 'Passwords do not match',
      );
    }

    return null;
  }
  Future<void> _submit(AppStrings s) async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.register(
      firstName: _firstNameController.text.trim(),
      secondName: _secondNameController.text.trim(),
      thirdName: _thirdNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      gender: _selectedGender,
      countryCode: _countryCodeController.text.trim(),
      phone: _phoneController.text.trim(),
      email: null,
      password: _passwordController.text.trim(),
      passwordConfirmation: _confirmPasswordController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              s,
              ar: 'تم إنشاء الحساب بنجاح',
              en: 'Account created successfully',
            ),
          ),
        ),
      );

      context.go('/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ??
                _t(
                  s,
                  ar: 'فشل إنشاء الحساب',
                  en: 'Registration failed',
                ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);

    return Consumer<LocaleController>(
      builder: (context, localeController, _) {
        final isArabic = localeController.isArabic;

        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                _t(
                  s,
                  ar: 'إنشاء حساب',
                  en: 'Create Account',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: localeController.toggleLocale,
                  child: Text(
                    isArabic ? 'EN' : 'AR',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppColors.cardDark,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _t(
                                    s,
                                    ar: 'افتح حسابك الجديد',
                                    en: 'Open your new account',
                                  ),
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _t(
                                    s,
                                    ar: 'أدخل بياناتك الصحيحة للمتابعة',
                                    en: 'Enter your correct details to continue',
                                  ),
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Expanded(
                                child: _AuthInput(
                                  controller: _firstNameController,
                                  label: _t(
                                    s,
                                    ar: 'الاسم الأول',
                                    en: 'First name',
                                  ),
                                  hint: _t(
                                    s,
                                    ar: 'الأول',
                                    en: 'First',
                                  ),
                                  icon: Icons.person_outline,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[\u0600-\u06FFa-zA-Z\s]'),
                                    ),
                                  ],
                                  validator: (value) => _validateName(
                                    value,
                                    s,
                                    _t(
                                      s,
                                      ar: 'الاسم الأول',
                                      en: 'First name',
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _AuthInput(
                                  controller: _secondNameController,
                                  label: _t(
                                    s,
                                    ar: 'الاسم الثاني',
                                    en: 'Second name',
                                  ),
                                  hint: _t(
                                    s,
                                    ar: 'الثاني',
                                    en: 'Second',
                                  ),
                                  icon: Icons.person_outline,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[\u0600-\u06FFa-zA-Z\s]'),
                                    ),
                                  ],
                                  validator: (value) => _validateName(
                                    value,
                                    s,
                                    _t(
                                      s,
                                      ar: 'الاسم الثاني',
                                      en: 'Second name',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(
                                child: _AuthInput(
                                  controller: _thirdNameController,
                                  label: _t(
                                    s,
                                    ar: 'الاسم الثالث',
                                    en: 'Third name',
                                  ),
                                  hint: _t(
                                    s,
                                    ar: 'الثالث',
                                    en: 'Third',
                                  ),
                                  icon: Icons.person_outline,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[\u0600-\u06FFa-zA-Z\s]'),
                                    ),
                                  ],
                                  validator: (value) => _validateName(
                                    value,
                                    s,
                                    _t(
                                      s,
                                      ar: 'الاسم الثالث',
                                      en: 'Third name',
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _AuthInput(
                                  controller: _lastNameController,
                                  label: _t(
                                    s,
                                    ar: 'اللقب',
                                    en: 'Last name',
                                  ),
                                  hint: _t(
                                    s,
                                    ar: 'اللقب',
                                    en: 'Last',
                                  ),
                                  icon: Icons.badge_outlined,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[\u0600-\u06FFa-zA-Z\s]'),
                                    ),
                                  ],
                                  validator: (value) => _validateName(
                                    value,
                                    s,
                                    _t(
                                      s,
                                      ar: 'اللقب',
                                      en: 'Last name',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          _GenderSelector(
                            isArabic: isArabic,
                            selectedGender: _selectedGender,
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value;
                              });
                            },
                          ),
                          const SizedBox(height: 14),

                          Row(
                            children: [
                              SizedBox(
                                width: 110,
                                child: _AuthInput(
                                  controller: _countryCodeController,
                                  label: _t(
                                    s,
                                    ar: 'المفتاح',
                                    en: 'Code',
                                  ),
                                  hint: '+967',
                                  icon: Icons.flag_outlined,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[+\d]'),
                                    ),
                                  ],
                                  validator: (value) =>
                                      _validateCountryCode(value, s),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _AuthInput(
                                  controller: _phoneController,
                                  label: _t(
                                    s,
                                    ar: 'رقم الهاتف',
                                    en: 'Phone number',
                                  ),
                                  hint: '77xxxxxxx',
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  maxLength: 9,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  validator: (value) => _validatePhone(value, s),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          _AuthInput(
                            controller: _passwordController,
                            label: _t(
                              s,
                              ar: 'كلمة المرور',
                              en: 'Password',
                            ),
                            hint: _t(
                              s,
                              ar: 'أدخل كلمة المرور',
                              en: 'Enter password',
                            ),
                            icon: Icons.lock_outline,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            validator: (value) => _validatePassword(value, s),
                          ),
                          const SizedBox(height: 14),

                          _AuthInput(
                            controller: _confirmPasswordController,
                            label: _t(
                              s,
                              ar: 'تأكيد كلمة المرور',
                              en: 'Confirm password',
                            ),
                            hint: _t(
                              s,
                              ar: 'أعد إدخال كلمة المرور',
                              en: 'Re-enter password',
                            ),
                            icon: Icons.lock_reset_outlined,
                            obscureText: _obscureConfirmPassword,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                                });
                              },
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            validator: (value) =>
                                _validateConfirmPassword(value, s),
                          ),
                          const SizedBox(height: 22),

                          SizedBox(
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () => _submit(s),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: Text(
                                _t(
                                  s,
                                  ar: 'إنشاء الحساب',
                                  en: 'Create account',
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          TextButton(
                            onPressed: () {
                              context.pop();
                            },
                            child: Text(
                              _t(
                                s,
                                ar: 'لديك حساب؟ تسجيل الدخول',
                                en: 'Already have an account? Login',
                              ),
                              style: const TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GenderSelector extends StatelessWidget {
  final bool isArabic;
  final String selectedGender;
  final ValueChanged<String> onChanged;

  const _GenderSelector({
    required this.isArabic,
    required this.selectedGender,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final male = isArabic ? 'ذكر' : 'Male';
    final female = isArabic ? 'أنثى' : 'Female';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'الجنس' : 'Gender',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _GenderCard(
                title: male,
                selected: selectedGender == 'male',
                icon: Icons.male_rounded,
                onTap: () => onChanged('male'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _GenderCard(
                title: female,
                selected: selectedGender == 'female',
                icon: Icons.female_rounded,
                onTap: () => onChanged('female'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GenderCard extends StatelessWidget {
  final String title;
  final bool selected;
  final IconData icon;
  final VoidCallback onTap;

  const _GenderCard({
    required this.title,
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? AppColors.primaryGreen : AppColors.border;
    final bgColor = selected
        ? AppColors.primaryGreen.withValues(alpha: 0.10)
        : AppColors.surfaceDark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? AppColors.primaryGreen : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: selected
                    ? AppColors.primaryGreen
                    : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType keyboardType;
  final int? maxLength;

  const _AuthInput({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.inputFormatters,
    this.keyboardType = TextInputType.text,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      maxLength: maxLength,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        counterText: '',
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.surfaceDark,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.primaryGreen,
            width: 1.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
        ),
      ),
    );
  }
}