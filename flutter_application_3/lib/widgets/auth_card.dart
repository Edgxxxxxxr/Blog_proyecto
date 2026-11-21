/// Archivo: auth_card.dart.
/// Presenta formularios de autenticación dentro de una tarjeta con ancho adaptable.

import 'package:flutter/material.dart';

/// Centra el contenido de autenticación dentro de una tarjeta de ancho limitado.
class AuthCard extends StatelessWidget {
  final Widget child;

  const AuthCard({super.key, required this.child});

  /// Centra el formulario dentro de una tarjeta de ancho máximo limitado.
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),

      child: Padding(
        padding: const EdgeInsets.all(24),

        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: child,
        ),
      ),
    );
  }
}
