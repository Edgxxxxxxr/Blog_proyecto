import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';
import '../widgets/admin_drawer.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final UserService userService = UserService();

  final nombreController = TextEditingController();
  final correoController = TextEditingController();
  final passwordController = TextEditingController();
  final direccionController = TextEditingController();

  late Future<List<UserModel>> futuroUsuarios;
  Map<String, dynamic> usuarioActual = {};
  bool argumentoLeido = false;

  @override
  void initState() {
    super.initState();
    futuroUsuarios = userService.obtenerUsuarios();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (argumentoLeido) return;

    final argumento = ModalRoute.of(context)?.settings.arguments;
    if (argumento is Map<String, dynamic>) {
      usuarioActual = Map<String, dynamic>.from(argumento);
    }
    argumentoLeido = true;
  }

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    passwordController.dispose();
    direccionController.dispose();
    super.dispose();
  }

  void recargarUsuarios() {
    setState(() {
      futuroUsuarios = userService.obtenerUsuarios();
    });
  }

  void mostrarMensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  Future<void> mostrarFormulario({UserModel? usuario}) async {
    final esEdicion = usuario != null;

    nombreController.text = usuario?.nombre ?? '';
    correoController.text = usuario?.correo ?? '';
    direccionController.text = usuario?.direccion ?? '';
    passwordController.clear();

    final resultado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        bool guardando = false;

        return StatefulBuilder(
          builder: (contextDialogo, actualizarDialogo) {
            return AlertDialog(
              title: Text(
                esEdicion ? 'Editar usuario' : 'Nuevo usuario',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo',
                      ),
                    ),
                    TextField(
                      controller: correoController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                      ),
                    ),
                    TextField(
                      controller: direccionController,
                      decoration: const InputDecoration(
                        labelText: 'Dirección',
                      ),
                    ),
                    if (!esEdicion)
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: guardando
                      ? null
                      : () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: guardando
                      ? null
                      : () async {
                          final nombre =
                              nombreController.text.trim();
                          final correo =
                              correoController.text.trim();
                          final direccion =
                              direccionController.text.trim();
                          final password =
                              passwordController.text;

                          if (nombre.isEmpty || correo.isEmpty) {
                            ScaffoldMessenger.of(dialogContext)
                                .showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Ingresa nombre y correo'),
                              ),
                            );
                            return;
                          }

                          if (!correo.contains('@')) {
                            ScaffoldMessenger.of(dialogContext)
                                .showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Ingresa un correo válido'),
                              ),
                            );
                            return;
                          }

                          if (!esEdicion &&
                              password.length < 8) {
                            ScaffoldMessenger.of(dialogContext)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'La contraseña debe tener al menos 8 caracteres',
                                ),
                              ),
                            );
                            return;
                          }

                          actualizarDialogo(() {
                            guardando = true;
                          });

                          try {
                            if (esEdicion) {
                              final actualizado = UserModel(
                                id: usuario.id,
                                nombre: nombre,
                                correo: correo,
                                direccion: direccion.isEmpty
                                    ? null
                                    : direccion,
                                tipoUsuario: usuario.tipoUsuario,
                              );

                              await userService.actualizarUsuario(
                                actualizado,
                              );
                            } else {
                              final nuevo = UserModel(
                                id: 0,
                                nombre: nombre,
                                correo: correo,
                                password: password,
                                direccion: direccion.isEmpty
                                    ? null
                                    : direccion,
                                tipoUsuario: 1,
                              );

                              await userService.agregarUsuario(nuevo);
                            }

                            if (!dialogContext.mounted) return;

                            Navigator.pop(dialogContext, true);
                          } catch (e) {
                            if (!dialogContext.mounted) return;

                            ScaffoldMessenger.of(dialogContext)
                                .showSnackBar(
                              SnackBar(
                                content:
                                    Text('No se pudo guardar: $e'),
                              ),
                            );

                            actualizarDialogo(() {
                              guardando = false;
                            });
                          }
                        },
                  child: Text(
                    esEdicion ? 'Actualizar' : 'Guardar',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (resultado == true && mounted) {
      recargarUsuarios();

      mostrarMensaje(
        esEdicion
            ? 'Usuario actualizado correctamente'
            : 'Usuario registrado correctamente',
      );
    }
  }

  Future<void> eliminarUsuario(UserModel usuario) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text(
          '¿Deseas eliminar a ${usuario.nombre}?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    try {
      await userService.eliminarUsuario(usuario.id);

      if (!mounted) return;

      recargarUsuarios();
      mostrarMensaje('Usuario eliminado correctamente');
    } catch (e) {
      mostrarMensaje('No se pudo eliminar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de usuarios'),
        actions: [
          IconButton(
            onPressed: recargarUsuarios,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar lista',
          ),
        ],
      ),
      drawer: usuarioActual.isEmpty
          ? null
          : AdminDrawer(usuario: usuarioActual, rutaActual: '/users'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => mostrarFormulario(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<UserModel>>(
        future: futuroUsuarios,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No se pudieron cargar los usuarios.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: recargarUsuarios,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final usuarios = snapshot.data ?? [];

          if (usuarios.isEmpty) {
            return const Center(
              child: Text('No hay usuarios registrados'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final nuevoFuturo =
                  userService.obtenerUsuarios();

              setState(() {
                futuroUsuarios = nuevoFuturo;
              });

              await nuevoFuturo;
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: usuarios.length,
              itemBuilder: (context, index) {
                final usuario = usuarios[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(usuario.nombre),
                    subtitle: Text(usuario.correo),
                    trailing: PopupMenuButton<String>(
                      onSelected: (opcion) {
                        if (opcion == 'editar') {
                          mostrarFormulario(
                            usuario: usuario,
                          );
                        } else if (opcion == 'eliminar') {
                          eliminarUsuario(usuario);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'editar',
                          child: Text('Editar'),
                        ),
                        PopupMenuItem(
                          value: 'eliminar',
                          child: Text('Eliminar'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
