
import 'package:flutter/material.dart';

import 'screens/add_blog_page.dart';
import 'screens/blog_page.dart';
import 'screens/login_user_page.dart';
import 'screens/profile_page.dart';
import 'screens/register_user_page.dart';
import 'screens/users_page.dart';

// Nueva pantalla del administrador
import 'screens/admin_dashboard_page.dart';

void main() {
  runApp(const LoginApp());
}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

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

        // Nueva ruta para administrador
        '/admin': (context) =>
            const AdminDashboardPage(),
      },
    );
  }
}
