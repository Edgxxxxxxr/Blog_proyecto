/// Archivo: primary_button.dart.
/// Construye el botón principal de formularios con contraste y tamaño táctil adecuados.

import 'package:flutter/material.dart';

/// Presenta la acción principal y permite mostrarla deshabilitada durante una solicitud.
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const PrimaryButton({super.key, required this.text, required this.onPressed});

  /// Presenta el botón principal y refleja si la acción está habilitada.
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,

      child: ElevatedButton(
        onPressed: onPressed,

        style: ElevatedButton.styleFrom(
          // Azul oscuro para mantener contraste AA con el texto blanco.
          backgroundColor: const Color(0xFF005A9C),

          foregroundColor: Colors.white,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),

        child: Text(
          text,

          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
