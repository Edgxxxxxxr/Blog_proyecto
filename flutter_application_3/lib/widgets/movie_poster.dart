/// Archivo: movie_poster.dart.
/// Carga el cartel de una película o presenta un reemplazo con descripción accesible.

import 'package:flutter/material.dart';

import '../services/auth_service.dart';

/// Dibuja la portada remota o un reemplazo cuando no existe imagen.
class MoviePoster extends StatelessWidget {
  final String? imagePath;
  final String semanticLabel;
  final double width;
  final double height;
  final BorderRadius borderRadius;

  /// Crea el componente MoviePoster con los valores que necesita para funcionar.
  const MoviePoster({
    super.key,
    required this.imagePath,
    required this.semanticLabel,
    this.width = 92,
    this.height = 132,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  /// Convierte una ruta relativa de imagen en una URL absoluta de la API.
  String? _imageUrl() {
    final path = imagePath?.trim() ?? '';
    if (path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final normalized = path.startsWith('/') ? path : '/$path';
    return AuthService.baseUrl + normalized;
  }

  /// Carga el cartel de red y conserva el reemplazo accesible ante errores.
  @override
  Widget build(BuildContext context) {
    final url = _imageUrl();
    return Semantics(
      image: true,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: ClipRRect(
          borderRadius: borderRadius,
          child: SizedBox(
            width: width,
            height: height,
            child: url == null
                ? _placeholder()
                : Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _placeholder(),
                  ),
          ),
        ),
      ),
    );
  }

  /// Muestra un icono alternativo si la película no tiene cartel disponible.
  Widget _placeholder() {
    return Container(
      color: const Color(0xFF374151),
      child: const Center(
        child: Icon(Icons.movie_outlined, color: Color(0xFFEAB308), size: 34),
      ),
    );
  }
}
