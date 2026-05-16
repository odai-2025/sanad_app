import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/i18n/app_strings.dart';
import '../../../../core/i18n/locale_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit(AppStrings s) async {
    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.login(
      phone: _phoneController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            s.isArabic ? 'تم تسجيل الدخول بنجاح' : 'Login successful',
          ),
        ),
      );
      context.go('/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ??
                (s.isArabic ? 'فشل تسجيل الدخول' : 'Login failed'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);

    return Consumer2<LocaleController, AuthProvider>(
      builder: (context, localeController, authProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(s.login),
            actions: [
              TextButton(
                onPressed: localeController.toggleLocale,
                child: Text(
                  localeController.isArabic ? 'EN' : 'AR',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.appName,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          s.isArabic
                              ? 'منصة شحن رقمي للوكلاء في اليمن'
                              : 'Digital top-up platform for store agents in Yemen',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: s.isArabic ? 'رقم الهاتف' : 'Phone',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: s.password,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: authProvider.isLoading ? null : () => _submit(s),
                    child: Text(
                      authProvider.isLoading
                          ? (s.isArabic ? 'جاري الدخول...' : 'Loading...')
                          : s.signIn,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {},
                    child: Text(s.continueWithGoogle),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      context.push('/register');
                    },
                    child: Text(
                      s.isArabic ? 'إنشاء حساب جديد' : 'Create new account',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}