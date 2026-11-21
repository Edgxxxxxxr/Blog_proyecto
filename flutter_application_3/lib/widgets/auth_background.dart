/// Archivo: auth_background.dart.
/// Proporciona el fondo adaptable y desplazable para las pantallas de acceso y registro.

import 'package:flutter/material.dart';

/// Envuelve los formularios con fondo, área segura y desplazamiento adaptable.
class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  /// Pinta el fondo y coloca el formulario en un área desplazable y segura.
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,

          colors: [
            Color(0xFFE6F6FF),
            Color(0xFFBFD9FF),
            Color(0xFFD9D1FF),
            Color(0xFFE8DFFF),
          ],
        ),
      ),

      // Permite desplazar los formularios cuando el teclado o el texto ampliado
      // reducen el espacio vertical disponible.
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: (constraints.maxHeight - 32)
                    .clamp(0, double.infinity)
                    .toDouble(),
              ),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
