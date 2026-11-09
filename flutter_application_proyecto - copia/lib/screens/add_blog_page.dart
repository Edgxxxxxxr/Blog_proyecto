import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/post_service.dart';
import '../widgets/admin_drawer.dart';

class AddBlogPage extends StatefulWidget {
  const AddBlogPage({super.key});

  @override
  State<AddBlogPage> createState() => _AddBlogPageState();
}

class _AddBlogPageState extends State<AddBlogPage> {
  final PostService postService = PostService();
  final ImagePicker picker = ImagePicker();

  final tituloController = TextEditingController();
  final descripcionController = TextEditingController();
  final tagsController = TextEditingController();

  XFile? foto;
  Uint8List? imagenBytes;
  bool guardando = false;

  @override
  void dispose() {
    tituloController.dispose();
    descripcionController.dispose();
    tagsController.dispose();
    super.dispose();
  }

  Future<void> tomarFoto() async {
    try {
      final imagen = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 75,
      );

      if (imagen == null) return;

      final bytes = await imagen.readAsBytes();
      if (!mounted) return;

      setState(() {
        foto = imagen;
        imagenBytes = bytes;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir la cámara: $error')),
      );
    }
  }

  Future<void> guardarPublicacion() async {
    if (tituloController.text.trim().length < 2 ||
        descripcionController.text.trim().isEmpty ||
        foto == null ||
        imagenBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa el título, la descripción y toma una foto.'),
        ),
      );
      return;
    }

    setState(() => guardando = true);

    try {
      await postService.agregarPost(
        titulo: tituloController.text,
        descripcion: descripcionController.text,
        imagenBytes: imagenBytes!,
        nombreArchivo: foto!.name,
        tags: tagsController.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Publicación guardada correctamente')),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo guardar: '
            '${error.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final argumentos = ModalRoute.of(context)?.settings.arguments;
    final usuario = argumentos is Map<String, dynamic>
        ? Map<String, dynamic>.from(argumentos)
        : <String, dynamic>{};

    return Scaffold(
      appBar: AppBar(title: const Text('Agregar publicación')),
      drawer: usuario.isEmpty
          ? null
          : AdminDrawer(
              usuario: usuario,
              rutaActual: '/add-blog',
            ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: tituloController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Título',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: descripcionController,
            minLines: 4,
            maxLines: 8,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: tagsController,
            decoration: const InputDecoration(
              labelText: 'Etiquetas (opcional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: guardando ? null : tomarFoto,
            icon: const Icon(Icons.camera_alt_outlined),
            label: Text(foto == null ? 'Tomar foto' : 'Cambiar foto'),
          ),
          if (imagenBytes != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                imagenBytes!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: guardando ? null : guardarPublicacion,
            icon: guardando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(
              guardando ? 'Guardando...' : 'Guardar publicación',
            ),
          ),
        ],
      ),
    );
  }
}
