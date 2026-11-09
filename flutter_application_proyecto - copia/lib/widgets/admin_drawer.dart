import 'package:flutter/material.dart';

class AdminDrawer extends StatelessWidget {
  final Map<String, dynamic> usuario;
  final String rutaActual;
  final VoidCallback? onPostCreated;

  const AdminDrawer({
    super.key,
    required this.usuario,
    required this.rutaActual,
    this.onPostCreated,
  });

  Future<void> _navegar(BuildContext context, String ruta) async {
    final navigator = Navigator.of(context);
    navigator.pop();

    if (ruta == rutaActual) return;

    if (ruta == '/logout') {
      navigator.pushNamedAndRemoveUntil('/login', (route) => false);
      return;
    }

    final resultado = await navigator.pushNamed<Object?>(
      ruta,
      arguments: usuario,
    );
    if (resultado == true) onPostCreated?.call();
  }

  @override
  Widget build(BuildContext context) {
    final nombre = usuario['nom_usr']?.toString() ?? 'Administrador';

    return Drawer(
      width: 304,
      backgroundColor: const Color(0xFFF7F1FA),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              decoration: const BoxDecoration(color: Color(0xFF102D65)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.admin_panel_settings,
                      color: Color(0xFF102D65),
                      size: 34,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    nombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            _opcion(
              context,
              icono: Icons.people_outline,
              texto: 'Gestión de usuarios',
              ruta: '/users',
            ),
            _opcion(
              context,
              icono: Icons.person_add_alt_1_outlined,
              texto: 'Registrar usuario',
              ruta: '/register',
            ),
            _opcion(
              context,
              icono: Icons.post_add,
              texto: 'Agregar blog',
              ruta: '/add-blog',
            ),
            _opcion(
              context,
              icono: Icons.person_outline,
              texto: 'Mi perfil',
              ruta: '/profile',
            ),
            const Spacer(),
            const Divider(height: 1),
            _opcion(
              context,
              icono: Icons.logout,
              texto: 'Cerrar sesión',
              ruta: '/logout',
            ),
          ],
        ),
      ),
    );
  }

  Widget _opcion(
    BuildContext context, {
    required IconData icono,
    required String texto,
    required String ruta,
  }) {
    final esCerrarSesion = ruta == '/logout';
    return ListTile(
      leading: Icon(
        icono,
        color: esCerrarSesion
            ? Colors.red
            : ruta == rutaActual
                ? const Color(0xFF102D65)
                : null,
      ),
      title: Text(
        texto,
        style: esCerrarSesion ? const TextStyle(color: Colors.red) : null,
      ),
      selected: ruta == rutaActual,
      selectedColor: const Color(0xFF7655AD),
      onTap: () => _navegar(context, ruta),
    );
  }
}
