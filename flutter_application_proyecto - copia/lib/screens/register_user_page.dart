import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../widgets/admin_drawer.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nombreController = TextEditingController();
  final correoController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmarPasswordController = TextEditingController();
  final direccionController = TextEditingController();

  final AuthService authService = AuthService();
  final UserService userService = UserService();

  int tipoUsuario = 2;
  bool guardando = false;

  Map<String, dynamic> usuarioActual = {};
  bool argumentoLeido = false;

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
    confirmarPasswordController.dispose();
    direccionController.dispose();
    super.dispose();
  }

  Future<void> registrarUsuario() async {
    final nombre = nombreController.text.trim();
    final correo = correoController.text.trim();
    final password = passwordController.text;
    final confirmarPassword = confirmarPasswordController.text;
    final direccion = direccionController.text.trim();

    final mensaje = authService.validarRegistro(
      nombre: nombre,
      correo: correo,
      password: password,
      confirmarpassword: confirmarPassword,
    );

    if (mensaje != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
      return;
    }

    setState(() => guardando = true);

    try {
      final usuario = UserModel(
        id: 0,
        nombre: nombre,
        correo: correo,
        password: password,
        direccion: direccion.isEmpty ? null : direccion,
        tipoUsuario: tipoUsuario,
      );

      await userService.agregarUsuario(usuario);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario registrado correctamente'),
        ),
      );

      nombreController.clear();
      correoController.clear();
      passwordController.clear();
      confirmarPasswordController.clear();
      direccionController.clear();

      setState(() => tipoUsuario = 2);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo registrar: $error')),
      );
    } finally {
      if (mounted) setState(() => guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar usuario')),
      drawer: usuarioActual.isEmpty
          ? null
          : AdminDrawer(
              usuario: usuarioActual,
              rutaActual: '/register',
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
          const SizedBox(height: 14),
          DropdownButtonFormField<int>(
            value: tipoUsuario,
            decoration: const InputDecoration(
              labelText: 'Tipo de usuario',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: 1,
                child: Text('Administrador'),
              ),
              DropdownMenuItem(
                value: 2,
                child: Text('Usuario general'),
              ),
            ],
            onChanged: guardando
                ? null
                : (valor) {
                    if (valor != null) {
                      setState(() => tipoUsuario = valor);
                    }
                  },
          ),
          const SizedBox(height: 14),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Contraseña',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: confirmarPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Confirmar contraseña',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: guardando ? null : registrarUsuario,
            child: Text(guardando ? 'Registrando...' : 'Registrar usuario'),
          ),
        ],
      ),
    );
  }
}