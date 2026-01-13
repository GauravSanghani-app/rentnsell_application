import 'package:flutter/material.dart';
import '../../../utils/theme_manager.dart';

class FormTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool readOnly;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? maxLength;
  final TextCapitalization? textCapitalization;

  const FormTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.textCapitalization,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textStyleSubHeading.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          onChanged: onChanged,
          readOnly: readOnly,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          textCapitalization: textCapitalization ?? TextCapitalization.none,
          decoration: inputDecoration.copyWith(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
          ),
        ),
      ],
    );
  }
}

