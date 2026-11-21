/// Archivo: post_detail_page.dart.
/// Presenta el contenido completo de una publicación seleccionada del blog.

import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../widgets/post_card.dart';

/// Presenta una publicación completa seleccionada desde el blog.
class PostDetailPage extends StatelessWidget {
  final PostModel post;
  /// Crea el componente PostDetailPage con los valores que necesita para funcionar.
  const PostDetailPage({
    super.key,
    required this.post,
  });
  /// Presenta el título, imagen y descripción completa de la publicación.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de publicación'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [            
            if (post.imagen.isNotEmpty)
              Image.network(
                 obtenerUrlImagen(post.imagen),
                  height: 230,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('Error al cargar imagen: $error');

                    return const SizedBox(
                      height: 150,
                      child: Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 50,
                        ),
                      ),
                    );
                  },
              ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.tags.isNotEmpty) ...[
                    Text(
                      post.tags,
                      style: const TextStyle(
                        color: Color(0xFF2196F3),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  Text(
                    post.titulo,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF08245C),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    post.descripcion.isNotEmpty
                        ? post.descripcion
                        : 'Esta publicación no tiene descripción.',
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
