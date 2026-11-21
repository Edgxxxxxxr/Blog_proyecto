/// Archivo: main.dart.
/// Inicializa Flutter y configura la aplicación, sus rutas y su tema global.

import 'package:flutter/material.dart';

import 'screens/add_blog_page.dart';
import 'screens/blog_page.dart';
import 'screens/login_user_page.dart';
import 'screens/profile_page.dart';
import 'screens/register_user_page.dart';
import 'screens/users_page.dart';
import 'screens/movie_user_page.dart';

// Nueva pantalla del administrador
import 'screens/admin_dashboard_page.dart';

/// Arranca Flutter y monta el widget raíz de la aplicación.
void main() {
  runApp(const LoginApp());
}

/// Configura MaterialApp, el tema global y las rutas de acceso de la aplicación.
class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  /// Presenta el widget raíz con el tema global y las rutas configuradas.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'World of Movies',
      initialRoute: '/login',

      routes: {
        '/login': (context) => const LoginPage(),

        '/register': (context) => const RegisterPage(),

        '/users': (context) => const UsersPage(),

        '/blog': (context) => const BlogPage(),

        '/add-blog': (context) => const AddBlogPage(),

        '/profile': (context) => const ProfilePage(),

        // La vista de usuario recibe los datos y el token del inicio de sesión.
        '/movie-home': (context) {
          final argumentos = ModalRoute.of(context)?.settings.arguments;
          final usuario = argumentos is Map
              ? Map<String, dynamic>.from(argumentos)
              : <String, dynamic>{};
          return MovieUserPage(usuario: usuario);
        },

        // Nueva ruta para administrador
        '/admin': (context) =>
            const AdminDashboardPage(),
      },
    );
  }
}
