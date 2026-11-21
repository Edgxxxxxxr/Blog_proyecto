/// Archivo: movie_card.dart.
/// Presenta una película en una tarjeta reutilizable con cartel y puntuación accesible.

import 'package:flutter/material.dart';

import '../models/pelicula_model.dart';
import 'movie_poster.dart';

/// Tarjeta reutilizable para resultados, populares y favoritos.
class MovieCard extends StatelessWidget {
  final PeliculaModel pelicula;
  final VoidCallback onTap;
  final Widget? trailing;

  /// Crea el componente MovieCard con los valores que necesita para funcionar.
  const MovieCard({
    super.key,
    required this.pelicula,
    required this.onTap,
    this.trailing,
  });

  /// Dibuja el cartel, título, puntuación y acción de apertura de la película.
  @override
  Widget build(BuildContext context) {
    final datos = [if (pelicula.anio != null) pelicula.anio!].join(' · ');

    return Card(
      color: const Color(0xFF1F2937),
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              MoviePoster(
                imagePath: pelicula.imagen,
                semanticLabel: 'Cartel de ${pelicula.titulo}',
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pelicula.titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (datos.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        datos,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Semantics(
                      label: pelicula.totalResenas == 0
                          ? 'Sin calificaciones'
                          : 'Calificación promedio '
                                '${pelicula.calificacionPromedio.toStringAsFixed(1)} '
                                'de 5, ${pelicula.totalResenas} reseñas',
                      child: ExcludeSemantics(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Color(0xFFEAB308),
                              size: 17,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              pelicula.totalResenas == 0
                                  ? 'Sin calificaciones'
                                  : '${pelicula.calificacionPromedio.toStringAsFixed(1)} '
                                        '(${pelicula.totalResenas})',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (pelicula.duracion != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        pelicula.duracion!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
