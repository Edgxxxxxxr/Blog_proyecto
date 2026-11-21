/// Archivo: blog_page.dart.
/// Carga y presenta las publicaciones del blog con navegación al detalle de cada una.

import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';
import '../widgets/post_card.dart';
import 'post_detail_page.dart';
import '../widgets/admin_drawer.dart';

/// Carga las publicaciones y presenta su lista con estados de carga y error.
class BlogPage extends StatefulWidget {
  const BlogPage({super.key});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

/// Controla la carga de publicaciones y abre el detalle seleccionado.
class _BlogPageState extends State<BlogPage> {
  final PostService postService = PostService();
  late Future<List<PostModel>> futurePosts;
  String nombreUsuario = 'Usuario';
  Map<String, dynamic> usuarioActual = {'nom_usr': 'Usuario', 'mail': '', 'tip_usu': 2};
  bool argumentoLeido = false;

  /// Actualiza los datos que dependen del contexto de la aplicación.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!argumentoLeido) {
      final argumento = ModalRoute.of(context)?.settings.arguments;

      if (argumento is Map<String, dynamic>) {
        usuarioActual = Map<String, dynamic>.from(argumento);
        nombreUsuario = usuarioActual['nom_usr']?.toString() ?? 'Usuario';
      } else if (argumento is String && argumento.isNotEmpty) {
        nombreUsuario = argumento;
        usuarioActual = {'nom_usr': nombreUsuario, 'mail': '', 'tip_usu': 2};
      }

      argumentoLeido = true;
    }
  }

  /// Inicializa el estado y los recursos que necesita la pantalla.
  @override
  void initState() {
    super.initState();
    futurePosts = postService.obtenerPosts();
  }

  /// Vuelve a solicitar las publicaciones y reconstruye la lista al terminar.
  void recargarPosts() {
    setState(() {
      futurePosts = postService.obtenerPosts();
    });
  }

  /// Presenta las publicaciones y sus estados de carga, error o lista vacía.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Mi Blog'),
            Text(
              'Bienvenido, $nombreUsuario',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
            onPressed: recargarPosts,
          ),

        ],
      ),
      drawer: (usuarioActual['tip_usu'] as num? ?? 2).toInt() == 1
          ? AdminDrawer(usuario: usuarioActual, rutaActual: '/blog')
          : null,
      body: FutureBuilder<List<PostModel>>(
        future: futurePosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 45),
                    const SizedBox(height: 12),
                    const Text(
                      'No fue posible cargar el blog.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: recargarPosts,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final posts = snapshot.data ?? <PostModel>[];

          if (posts.isEmpty) {
            return const Center(
              child: Text('No hay publicaciones registradas.'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Bienvenido',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF08245C),
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Descubre nuevas ideas',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              // Crea una tarjeta de navegación para cada publicación recibida.
              ...posts.map(
                (post) => PostCard(
                  post: post,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => PostDetailPage(post: post),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
