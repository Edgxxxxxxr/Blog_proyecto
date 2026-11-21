/// Archivo: review_form_dialog.dart.
/// Permite elegir una puntuación y escribir un comentario opcional para una película.

import 'package:flutter/material.dart';

/// Formulario del wireframe: de una a cinco estrellas y texto opcional.
class ReviewFormDialog extends StatefulWidget {
  const ReviewFormDialog({super.key});

  @override
  State<ReviewFormDialog> createState() => _ReviewFormDialogState();
}

/// Mantiene la calificación y el comentario antes de enviarlos al ViewModel.
class _ReviewFormDialogState extends State<ReviewFormDialog> {
  final TextEditingController _comentario = TextEditingController();
  int _calificacion = 0;

  /// Marca el ViewModel como cerrado y libera el notificador base.
  @override
  void dispose() {
    _comentario.dispose();
    super.dispose();
  }

  /// Dibuja las cinco estrellas, el campo opcional y las acciones del diálogo.
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      backgroundColor: const Color(0xFF1F2937),
      title: const Text(
        'Calificar película',
        style: TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            // Genera un control por cada elemento solicitado para la interfaz.
            children: List.generate(5, (index) {
              final estrella = index + 1;
              return IconButton(
                tooltip: 'Calificar con $estrella de 5 estrellas',
                onPressed: () => setState(() => _calificacion = estrella),
                isSelected: estrella == _calificacion,
                icon: Icon(
                  estrella <= _calificacion ? Icons.star : Icons.star_border,
                  color: const Color(0xFFEAB308),
                  size: 30,
                ),
              );
            }),
          ),
          TextField(
            controller: _comentario,
            maxLength: 250,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Comentario (opcional)',
              hintText: 'Escribe tu opinión',
              hintStyle: TextStyle(color: Colors.white54),
              counterStyle: TextStyle(color: Colors.white54),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          // El PDF establece que publicar requiere elegir al menos una estrella.
          onPressed: _calificacion == 0
              ? null
              : () => Navigator.pop(context, {
                  'calificacion': _calificacion,
                  'comentario': _comentario.text.trim(),
                }),
          child: const Text('Publicar'),
        ),
      ],
    );
  }
}
