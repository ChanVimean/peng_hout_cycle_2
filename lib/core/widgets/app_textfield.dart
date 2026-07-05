// dart format off

import 'package:flutter/material.dart';
import 'package:peng_houth_cycle/core/const/constant.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final Widget? prefixIcon;
  final bool isPassword;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final VoidCallback? onTap;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.isPassword = false,
    this.enabled = true,
    this.onChanged,
    this.keyboardType,
    this.onTap,
  });

  @override
  State<AppTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<AppTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onTap: widget.onTap,
      obscureText: widget.isPassword && _obscure,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      keyboardType: widget.keyboardType,
      style: const TextStyle(color: AppColors.textPrimaryColor),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon,
        hintStyle: const TextStyle(color: AppColors.textSecondaryColor),

        // Password toggle
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textSecondaryColor,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,

        filled: true,
        fillColor: AppColors.cardBackgroundColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.defaultPadding,
          vertical: AppSpacing.defaultPadding,
        ),

        // Pill shape — matches your search bar's rounded look
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusLG),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusLG),
          borderSide: const BorderSide(color: AppColors.textSecondaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.radiusLG),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
      ),
    );
  }
}
