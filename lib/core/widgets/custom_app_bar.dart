import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final bool centerTitle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.onBackPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.centerTitle = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return AppBar(
      automaticallyImplyLeading: false,
      elevation: elevation,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppColors.surfaceDark,
      foregroundColor: foregroundColor ?? AppColors.textPrimary,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: AppColors.textPrimary,
        ),
      ),
      leading: showBackButton && canPop
          ? IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        tooltip: 'Back',
      )
          : null,
      actions: actions,
    );
  }
}