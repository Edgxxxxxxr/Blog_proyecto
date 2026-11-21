/// Archivo: review_card.dart.
/// Presenta una reseña, su puntuación y la acción para reportarla.

import 'package:flutter/material.dart';

import '../models/resena_model.dart';

/// Muestra una reseña y ofrece la acción de reportarla.
class ReviewCard extends StatelessWidget {
  final ResenaModel resena;
  final VoidCallback onReport;
  final bool canReport;

  /// Crea el componente ReviewCard con los valores que necesita para funcionar.
  const ReviewCard({
    super.key,
    required this.resena,
    required this.onReport,
    this.canReport = true,
  });

  /// Muestra autor, calificación y texto, con acción condicional de reporte.
  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1F2937),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    resena.nombreUsuario,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Semantics(
                  label: 'Calificación: ${resena.calificacion} de 5 estrellas',
                  child: ExcludeSemantics(
                    child: Text(
                      '${List.filled(resena.calificacion, '★').join()} '
                      '(${resena.calificacion}/5)',
                      style: const TextStyle(color: Color(0xFFEAB308)),
                    ),
                  ),
                ),
                if (canReport)
                  IconButton(
                    tooltip: 'Reportar reseña',
                    onPressed: onReport,
                    icon: const Icon(
                      Icons.flag_outlined,
                      color: Colors.white70,
                    ),
                  ),
              ],
            ),
            if (resena.comentario.isNotEmpty)
              Text(
                resena.comentario,
                style: const TextStyle(color: Colors.white70, height: 1.4),
              ),
            if (resena.fecha != null) ...[
              const SizedBox(height: 7),
              Text(
                '${resena.fecha!.day}/${resena.fecha!.month}/${resena.fecha!.year}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
