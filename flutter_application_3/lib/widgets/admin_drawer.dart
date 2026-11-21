/// Archivo: admin_drawer.dart.
/// Construye el menú lateral reutilizable de administración y su navegación.

import 'package:flutter/material.dart';

/// Construye el menú lateral que lleva a cada área administrativa.
class AdminDrawer extends StatelessWidget {
  final Map<String, dynamic> usuario;
  final String rutaActual;

  /// Crea el componente AdminDrawer con los valores que necesita para funcionar.
  const AdminDrawer({
    super.key,
    required this.usuario,
    required this.rutaActual,
  });

  /// Devuelve el valor calculado de nombre para la interfaz.
  String get nombre => usuario['nom_usr']?.toString() ?? 'Administrador';
  /// Devuelve el valor calculado de correo para la interfaz.
  String get correo => usuario['mail']?.toString() ?? '';

  /// Cierra el menú y navega a otra sección conservando los datos de sesión.
  void _navegar(BuildContext context, String ruta) {
    Navigator.pop(context);
    if (ruta == rutaActual) return;
    Navigator.pushReplacementNamed(
      context,
      ruta,
      arguments: usuario,
    );
  }

  /// Dibuja la cabecera del administrador y los enlaces de navegación lateral.
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF08245C)),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.admin_panel_settings,
                    color: Color(0xFF08245C), size: 34),
              ),
              accountName: Text(nombre),
              accountEmail: Text(correo),
            ),
            _opcion(context, Icons.people_alt_outlined, 'Gestión de usuarios',
                '/users'),
            _opcion(context, Icons.person_add_alt_1, 'Registrar usuario',
                '/register'),
            _opcion(context, Icons.post_add, 'Agregar blog', '/add-blog'),
            _opcion(context, Icons.account_circle_outlined, 'Mi perfil',
                '/profile'),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar sesión',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false,
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _opcion(
    BuildContext context,
    IconData icono,
    String titulo,
    String ruta,
  ) {
    final seleccionado = ruta == rutaActual;
    return ListTile(
      leading: Icon(icono,
          color: seleccionado ? const Color(0xFF08245C) : null),
      title: Text(titulo),
      selected: seleccionado,
      onTap: () => _navegar(context, ruta),
    );
  }
}
