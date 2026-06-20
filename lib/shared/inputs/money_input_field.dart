import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

/// Campo de entrada optimizado para valores en COP
class MoneyInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;

  const MoneyInputField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(
        fontFamily: AppConstants.fontPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint ?? AppConstants.defaultHintAmount,
        prefixText: AppConstants.currencyPrefix,
        prefixStyle: const TextStyle(
          fontFamily: AppConstants.fontPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.secondary,
        ),
      ),
    );
  }
}
