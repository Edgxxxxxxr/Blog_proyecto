/// Archivo: users_page.dart.
/// Administra la lista de usuarios, sus formularios y las acciones de eliminación.

import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';
import '../widgets/admin_drawer.dart';

/// Administra la lista de cuentas y sus operaciones CRUD.
class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

/// Carga cuentas, abre formularios y procesa las acciones administrativas.
class _UsersPageState extends State<UsersPage> {
  final UserService userService = UserService();

  final nombreController = TextEditingController();
  final correoController = TextEditingController();
  final passwordController = TextEditingController();
  final direccionController = TextEditingController();

  late Future<List<UserModel>> futuroUsuarios;
  String nombreUsuario = 'Usuario';
  Map<String, dynamic> usuarioActual = {'nom_usr': 'Usuario', 'mail': '', 'tip_usu': 1};
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
      } else if (argumento is String && argumento.trim().isNotEmpty) {
        nombreUsuario = argumento.trim();
        usuarioActual = {'nom_usr': nombreUsuario, 'mail': '', 'tip_usu': 1};
      }
      argumentoLeido = true;
    }
  }

  /// Inicializa el estado y los recursos que necesita la pantalla.
  @override
  void initState() {
    super.initState();
    futuroUsuarios = userService.obtenerUsuarios();
  }

  /// Marca el ViewModel como cerrado y libera el notificador base.
  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    passwordController.dispose();
    direccionController.dispose();
    super.dispose();
  }

  /// Actualiza la consulta de cuentas para refrescar la lista administrativa.
  void recargarUsuarios() {
    setState(() {
      futuroUsuarios = userService.obtenerUsuarios();
    });
  }

  /// Muestra una notificación breve con el resultado de la acción solicitada.
  void mostrarMensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  /// Abre el formulario, envía los cambios y actualiza la lista al guardar.
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
                                content: Text(
                                  'Ingresa nombre y correo',
                                ),
                              ),
                            );
                            return;
                          }

                          if (!correo.contains('@')) {
                            ScaffoldMessenger.of(dialogContext)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Ingresa un correo válido',
                                ),
                              ),
                            );
                            return;
                          }

                          if (!esEdicion && password.length < 8) {
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
                                content: Text(
                                  'No se pudo guardar: $e',
                                ),
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

  /// Confirma y ejecuta la eliminación de eliminarUsuario.
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
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
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

  /// Presenta la lista de cuentas y los controles para administrarlas.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Gestión de usuarios',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Bienvenido, $nombreUsuario',
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: recargarUsuarios,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar lista',
          ),
        ],
      ),
      drawer: AdminDrawer(usuario: usuarioActual, rutaActual: '/users'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => mostrarFormulario(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<UserModel>>(
        future: futuroUsuarios,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
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
                    const Icon(Icons.cloud_off, size: 48),
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
              final nuevoFuturo = userService.obtenerUsuarios();

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
                          mostrarFormulario(usuario: usuario);
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
