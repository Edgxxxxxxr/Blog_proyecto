import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/category_chip.dart';
import '../widgets/post_card.dart';
import 'post_detail_page.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({super.key});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  final PostService postService = PostService();
  late Future<List<PostModel>> futurePosts;
  String nombreUsuario = 'Usuario';
  Map<String, dynamic> usuarioActual = {
    'nom_usr': 'Usuario',
    'mail': '',
    'tip_usu': 2,
  };
  bool argumentoLeido = false;

  @override
  void initState() {
    super.initState();
    futurePosts = postService.obtenerPosts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (argumentoLeido) return;

    final argumento = ModalRoute.of(context)?.settings.arguments;
    if (argumento is Map<String, dynamic>) {
      usuarioActual = Map<String, dynamic>.from(argumento);
      nombreUsuario = usuarioActual['nom_usr']?.toString() ?? 'Usuario';
    } else if (argumento is String && argumento.isNotEmpty) {
      nombreUsuario = argumento;
      usuarioActual = {
        'nom_usr': nombreUsuario,
        'mail': '',
        'tip_usu': 2,
      };
    }

    argumentoLeido = true;
  }

  int get tipoUsuario {
    final tipo = usuarioActual['tip_usu'];
    if (tipo is num) return tipo.toInt();
    return int.tryParse(tipo?.toString() ?? '') ?? 2;
  }

  void recargarPosts() {
    setState(() {
      futurePosts = postService.obtenerPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Blog'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: recargarPosts,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar publicaciones',
          ),
        ],
      ),
      drawer: tipoUsuario == 1
          ? AdminDrawer(
              usuario: usuarioActual,
              rutaActual: '/blog',
              onPostCreated: recargarPosts,
            )
          : null,
      body: FutureBuilder<List<PostModel>>(
        future: futurePosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
                    Text('${snapshot.error}', textAlign: TextAlign.center),
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
              Text(
                'Bienvenido, $nombreUsuario',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF08245C),
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Descubre nuevas ideas',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(
                height: 45,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    CategoryChip(
                      text: 'Todos',
                      selected: true,
                      onTap: () {},
                    ),
                    const SizedBox(width: 10),
                    CategoryChip(
                      text: 'Flutter',
                      selected: false,
                      onTap: () {},
                    ),
                    const SizedBox(width: 10),
                    CategoryChip(
                      text: 'IA',
                      selected: false,
                      onTap: () {},
                    ),
                    const SizedBox(width: 10),
                    CategoryChip(
                      text: 'Diseño',
                      selected: false,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
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
