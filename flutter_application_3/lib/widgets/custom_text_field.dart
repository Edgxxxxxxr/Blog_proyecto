/// Archivo: custom_text_field.dart.
/// Construye un campo de formulario reutilizable con etiqueta, error y autocompletado.

import 'package:flutter/material.dart';

/// Unifica entrada, etiqueta visible, error de validación e indicaciones de autocompletado.
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final List<String>? autofillHints;

  /// Crea el componente CustomTextField con los valores que necesita para funcionar.
  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.onChanged,
    this.autofillHints,
  });

  /// Dibuja el campo con etiqueta, iconos, errores y opciones de entrada.
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      autofillHints: autofillHints,

      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,

        prefixIcon: Icon(prefixIcon),

        suffixIcon: suffixIcon,
        suffixIconConstraints: const BoxConstraints(
          minWidth: 90,
          minHeight: 48,
        ),

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }
}
