import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';
import '../widgets/admin_drawer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService userService = UserService();

  final nombreController = TextEditingController();
  final correoController = TextEditingController();
  final direccionController = TextEditingController();

  Map<String, dynamic> usuarioActual = {};
  bool argumentoLeido = false;
  bool guardando = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (argumentoLeido) return;

    final argumento = ModalRoute.of(context)?.settings.arguments;

    if (argumento is Map<String, dynamic>) {
      usuarioActual = Map<String, dynamic>.from(argumento);
      nombreController.text = usuarioActual['nom_usr']?.toString() ?? '';
      correoController.text = usuarioActual['mail']?.toString() ?? '';
      direccionController.text = usuarioActual['dir_usr']?.toString() ?? '';
    }

    argumentoLeido = true;
  }

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    direccionController.dispose();
    super.dispose();
  }

  Future<void> actualizarPerfil() async {
    final id = usuarioActual['id_usr'];
    final idUsuario = id is num ? id.toInt() : int.tryParse('$id');

    if (idUsuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró el ID del usuario')),
      );
      return;
    }

    final nombre = nombreController.text.trim();
    final correo = correoController.text.trim();
    final direccion = direccionController.text.trim();
    final tipo = usuarioActual['tip_usu'];
    final tipoUsuario = tipo is num ? tipo.toInt() : 2;

    if (nombre.length < 2 || !correo.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Revisa el nombre y el correo electrónico'),
        ),
      );
      return;
    }

    setState(() => guardando = true);

    try {
      final actualizado = UserModel(
        id: idUsuario,
        nombre: nombre,
        correo: correo,
        direccion: direccion.isEmpty ? null : direccion,
        tipoUsuario: tipoUsuario,
      );

      final respuesta = await userService.actualizarUsuario(actualizado);

      if (!mounted) return;

      setState(() {
        usuarioActual = {
          'id_usr': respuesta.id,
          'nom_usr': respuesta.nombre,
          'mail': respuesta.correo,
          'dir_usr': respuesta.direccion,
          'tip_usu': respuesta.tipoUsuario,
        };
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar el perfil: $error')),
      );
    } finally {
      if (mounted) setState(() => guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      drawer: usuarioActual.isEmpty
          ? null
          : AdminDrawer(
              usuario: usuarioActual,
              rutaActual: '/profile',
            ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: nombreController,
            decoration: const InputDecoration(
              labelText: 'Nombre completo',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: correoController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: direccionController,
            decoration: const InputDecoration(
              labelText: 'Dirección',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: guardando ? null : actualizarPerfil,
            child: Text(guardando ? 'Actualizando...' : 'Guardar cambios'),
          ),
        ],
      ),
    );
  }
}