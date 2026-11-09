import 'package:flutter/material.dart';
import 'screens/add_blog_page.dart';
import 'screens/blog_page.dart';
import 'screens/login_user_page.dart';
import 'screens/profile_page.dart';
import 'screens/register_user_page.dart';
import 'screens/users_page.dart';

void main() {
  runApp(const LoginApp());
}

class LoginApp extends StatelessWidget {
  const LoginApp({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mi aplicacion',
      initialRoute: '/login',
      routes: {
        '/blog': (context) => const BlogPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/users': (context) => const UsersPage(),
        '/add-blog': (context) => const AddBlogPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
