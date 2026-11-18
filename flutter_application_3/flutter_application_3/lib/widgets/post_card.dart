import 'package:flutter/material.dart';
import '../models/post_model.dart';


String obtenerUrlImagen(String? ruta) {
  const baseUrl = 'http://127.0.0.1:8000';

  if (ruta == null || ruta.trim().isEmpty) {
    return '';
  }

  final imagen = ruta.trim().replaceAll('\\', '/');

  if (imagen.startsWith('http://') ||
      imagen.startsWith('https://')) {
    return imagen;
  }

  if (imagen.startsWith('/')) {
    return '$baseUrl$imagen';
  }

  return '$baseUrl/$imagen';
}

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onTap;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.imagen.trim().isNotEmpty)
              Image.network(
                obtenerUrlImagen(post.imagen),
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    height: 200,
                    child: Center(
                      child: Text('No se pudo cargar la imagen'), 
                      ),
                    );
                },
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.tags.isNotEmpty) ...[
                    Text(
                      post.tags,
                      style: const TextStyle(
                        color: Color(0xFF2196F3),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  Text(
                    post.titulo,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF08245C),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    post.descripcion,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Row(
                    children: [
                      Icon(Icons.article_outlined, size: 18),
                      SizedBox(width: 5),
                      Text('Leer publicación'),
                    ],
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
