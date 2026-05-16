import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/i18n/app_strings.dart';
import '../../../../core/i18n/locale_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedGender = 'male';

  final _firstNameController = TextEditingController();
  final _secondNameController = TextEditingController();
  final _thirdNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _countryCodeController = TextEditingController(text: '+967');
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

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

  String? _validateName(String? value, AppStrings s, String fieldLabel) {
    if (_isLogin) return null;

    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return _t(
        s,
        ar: '$fieldLabel مطلوب',
        en: '$fieldLabel is required',
      );
    }

    if (text.length < 2) {
      return _t(
        s,
        ar: '$fieldLabel قصير جدًا',
        en: '$fieldLabel is too short',
      );
    }

    final nameRegex = RegExp(r'^[\u0600-\u06FFa-zA-Z\s]+$');
    if (!nameRegex.hasMatch(text)) {
      return _t(
        s,
        ar: 'الاسم يقبل حروفًا فقط بدون أرقام أو رموز',
        en: 'Name accepts letters only without numbers or symbols',
      );
    }

    return null;
  }

  String? _validateYemeniPhone(String? value, AppStrings s) {
    final phone = value?.trim() ?? '';

    if (phone.isEmpty) {
      return _t(
        s,
        ar: 'بيانات الدخول غير صحيحة',
        en: 'Invalid login data',
      );
    }

    if (!RegExp(r'^\d+$').hasMatch(phone)) {
      return _t(
        s,
        ar: 'بيانات الدخول غير صحيحة',
        en: 'Invalid login data',
      );
    }

    if (phone.length != 9) {
      return _t(
        s,
        ar: 'بيانات الدخول غير صحيحة',
        en: 'Invalid login data',
      );
    }
    if (!RegExp(r'^(77|78|71|73)\d{7}$').hasMatch(phone)) {
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
    if (_isLogin) return null;

    if ((value ?? '').isEmpty) {
      return _t(
        s,
        ar: 'تأكيد كلمة المرور مطلوب',
        en: 'Confirm password is required',
      );
    }

    if (value != _passwordController.text) {
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

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    authProvider.clearError();

    bool success = false;

    if (_isLogin) {
      success = await authProvider.login(
        phone: _phoneController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } else {
      success = await authProvider.register(
        firstName: _firstNameController.text.trim(),
        secondName: _secondNameController.text.trim(),
        thirdName: _thirdNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        gender: _selectedGender,
        countryCode: _countryCodeController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text.trim(),
        passwordConfirmation: _confirmPasswordController.text.trim(),
      );
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isLogin
                ? _t(
              s,
              ar: 'تم تسجيل الدخول بنجاح',
              en: 'Login successful',
            )
                : _t(
              s,
              ar: 'تم إنشاء الحساب بنجاح',
              en: 'Account created successfully',
            ),
          ),
        ),
      );

      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            authProvider.errorMessage ??
                _t(
                  s,
                  ar: 'حدث خطأ غير متوقع',
                  en: 'Unexpected error occurred',
                ),
          ),
        ),
      );
    }
  }

  void _switchMode(bool loginMode) {
    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();
    authProvider.clearError();

    setState(() {
      _isLogin = loginMode;
      _obscurePassword = true;
      _obscureConfirmPassword = true;
    });

    _formKey.currentState?.reset();

    _passwordController.clear();
    _confirmPasswordController.clear();

    if (loginMode) {
      _firstNameController.clear();
      _secondNameController.clear();
      _thirdNameController.clear();
      _lastNameController.clear();
      _selectedGender = 'male';
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final authProvider = context.watch<AuthProvider>();

    return Consumer<LocaleController>(
      builder: (context, localeController, _) {
        final isArabic = localeController.isArabic;

        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: AppColors.surfaceDark,
            appBar: AppBar(
              backgroundColor: AppColors.surfaceDark,
              elevation: 0,
              centerTitle: true,
              title: Text(
                _t(
                  s,
                  ar: 'تسجيل الدخول',
                  en: 'Authentication',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: authProvider.isLoading
                      ? null
                      : localeController.toggleLocale,
                  child: Text(
                    isArabic ? 'EN' : 'AR',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Column(
                      children: [
                        Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: AppColors.primaryGreen.withValues(alpha: 0.22),
                            ),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            size: 44,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          _isLogin
                              ? _t(
                            s,
                            ar: 'أهلًا بك مجددًا',
                            en: 'Welcome back',
                          )
                              : _t(
                            s,
                            ar: 'إنشاء حساب جديد',
                            en: 'Create new account',
                          ),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isLogin
                              ? _t(
                            s,
                            ar: 'سجل دخولك للوصول إلى محفظتك بسرعة وأمان',
                            en: 'Log in to access your wallet quickly and securely',
                          )
                              : _t(
                            s,
                            ar: 'املأ بياناتك الشخصية الصحيحة لإنشاء حسابك',
                            en: 'Fill in your correct personal details to create your account',
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.cardDark,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.border),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceDark,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _ModeButton(
                                          title: _t(
                                            s,
                                            ar: 'دخول',
                                            en: 'Login',
                                          ),
                                          selected: _isLogin,
                                          enabled: !authProvider.isLoading,
                                          onTap: () => _switchMode(true),
                                        ),
                                      ),
                                      Expanded(
                                        child: _ModeButton(
                                          title: _t(
                                            s,
                                            ar: 'حساب جديد',
                                            en: 'Sign up',
                                          ),
                                          selected: !_isLogin,
                                          enabled: !authProvider.isLoading,
                                          onTap: () => _switchMode(false),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                if (authProvider.errorMessage != null &&
                                    authProvider.errorMessage!.trim().isNotEmpty) ...[
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.withValues(alpha: 0.10),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.redAccent.withValues(alpha: 0.35),
                                      ),
                                    ),
                                    child: Text(
                                      authProvider.errorMessage!,
                                      style: const TextStyle(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                ],

                                if (!_isLogin) ...[
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
                                          enabled: !authProvider.isLoading,
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
                                          enabled: !authProvider.isLoading,
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
                                          enabled: !authProvider.isLoading,
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
                                          enabled: !authProvider.isLoading,
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
                                  AbsorbPointer(
                                    absorbing: authProvider.isLoading,
                                    child: _GenderSelector(
                                      isArabic: isArabic,
                                      selectedGender: _selectedGender,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedGender = value;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                ],

                                Row(
                                  children: [
                                    SizedBox(
                                      width: 104,
                                      child: _AuthInput(
                                        controller: _countryCodeController,
                                        label: _t(
                                          s,
                                          ar: 'المفتاح',
                                          en: 'Code',
                                        ),
                                        hint: '+967',
                                        icon: Icons.flag_outlined,
                                        enabled: !authProvider.isLoading,
                                        readOnly: false,
                                        keyboardType: TextInputType.phone,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                            RegExp(r'[+\d]'),
                                          ),
                                        ],
                                        validator: (value) {
                                          if ((value ?? '').trim() != '+967') {
                                            return _t(
                                              s,
                                              ar: 'غير صحيح',
                                              en: 'Invalid',
                                            );
                                          }
                                          return null;
                                        },
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
                                        hint: _t(
                                          s,
                                          ar: '77xxxxxxx',
                                          en: '77xxxxxxx',
                                        ),
                                        icon: Icons.phone_outlined,
                                        enabled: !authProvider.isLoading,
                                        keyboardType: TextInputType.phone,
                                        maxLength: 9,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                        ],
                                        validator: (value) =>
                                            _validateYemeniPhone(value, s),
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
                                  enabled: !authProvider.isLoading,
                                  obscureText: _obscurePassword,
                                  suffixIcon: IconButton(
                                    onPressed: authProvider.isLoading
                                        ? null
                                        : () {
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

                                if (!_isLogin) ...[
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
                                    enabled: !authProvider.isLoading,
                                    obscureText: _obscureConfirmPassword,
                                    suffixIcon: IconButton(
                                      onPressed: authProvider.isLoading
                                          ? null
                                          : () {
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
                                ],

                                const SizedBox(height: 22),

                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: ElevatedButton(
                                    onPressed: authProvider.isLoading
                                        ? null
                                        : () => _submit(s),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryGreen,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: AppColors.primaryGreen
                                          .withValues(alpha: 0.55),
                                      disabledForegroundColor: Colors.white70,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: authProvider.isLoading
                                        ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                        : Text(
                                      _isLogin
                                          ? _t(
                                        s,
                                        ar: 'تسجيل الدخول',
                                        en: 'Login',
                                      )
                                          : _t(
                                        s,
                                        ar: 'إنشاء حساب',
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
                                  onPressed: authProvider.isLoading
                                      ? null
                                      : () => _switchMode(!_isLogin),
                                  child: Text(
                                    _isLogin
                                        ? _t(
                                      s,
                                      ar: 'ليس لديك حساب؟ أنشئ حسابًا',
                                      en: 'Don’t have an account? Sign up',
                                    )
                                        : _t(
                                      s,
                                      ar: 'لديك حساب؟ سجل الدخول',
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
                        const SizedBox(height: 14),
                        Text(
                          _t(
                            s,
                            ar: 'الأرقام المقبولة تبدأ بـ 77 أو 78 أو 71 أو 73',
                            en: 'Accepted numbers start with 77, 78, 71, or 73',
                          ),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
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

class _ModeButton extends StatelessWidget {
  final String title;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _ModeButton({
    required this.title,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
              color: selected
                  ? AppColors.primaryGreen
                  : AppColors.textSecondary,
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
  final bool readOnly;
  final int? maxLength;
  final bool enabled;

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
    this.readOnly = false,
    this.maxLength,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      readOnly: readOnly,
      enabled: enabled,
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
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: AppColors.border.withValues(alpha: 0.60),
          ),
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
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}