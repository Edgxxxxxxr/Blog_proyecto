import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class RegisterPage extends StatefulWidget {

  const RegisterPage({
    super.key,
  });

  @override
  State<RegisterPage> createState() =>
      _RegisterPageState();
}

class _RegisterPageState
    extends State<RegisterPage> {

  final TextEditingController nombreController =
      TextEditingController();

  final TextEditingController correoController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController direccionController = TextEditingController();
  final TextEditingController confirmarController = TextEditingController();
  int tipoUsuario = 1;
  bool guardando = false;

  final AuthService authService = AuthService();

  @override
  void dispose() {

    nombreController.dispose();
    correoController.dispose();
    passwordController.dispose();
    direccionController.dispose();
    confirmarController.dispose();

    super.dispose();
  }

  Future<void> registrarUsuario() async {
    if (guardando) return;

    final mensaje = authService.validarRegistro(
      nombre: nombreController.text.trim(),
      correo: correoController.text.trim(),
      password: passwordController.text,
      confirmarpassword: confirmarController.text,
    );

    if (mensaje != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
      return;
    }

    setState(() => guardando = true);
    try {
      await authService.registrarUsuario(
        nombre: nombreController.text.trim(),
        correo: correoController.text.trim(),
        password: passwordController.text,
        direccion: direccionController.text.trim().isEmpty
            ? null
            : direccionController.text.trim(),
        tipoUsuario: tipoUsuario,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario guardado en la base de datos')),
      );
      nombreController.clear();
      correoController.clear();
      passwordController.clear();
      confirmarController.clear();
      direccionController.clear();
      setState(() => tipoUsuario = 1);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo registrar: $e')),
      );
    } finally {
      if (mounted) setState(() => guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: AuthBackground(

        child: Center(

          child: AuthCard(

            child: Column(

              mainAxisSize:
                  MainAxisSize.min,

              children: [

                const Icon(
                  Icons.person_add,
                  size: 65,
                  color:
                      Color(0xFF2196F3),
                ),

                const SizedBox(
                  height: 15,
                ),

                const Text(
                  'CREAR CUENTA',

                  style: TextStyle(
                    fontSize: 27,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(0xFF08245C),
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),

                CustomTextField(
                  controller:
                      nombreController,

                  label:
                      'Nombre completo',

                  prefixIcon:
                      Icons.person,
                ),

                const SizedBox(
                  height: 15,
                ),

                CustomTextField(
                  controller:
                      correoController,

                  label:
                      'Correo electrónico',

                  prefixIcon:
                      Icons.email,

                  keyboardType:
                      TextInputType.emailAddress,
                ),

                const SizedBox(
                  height: 15,
                ),

                CustomTextField(
                  controller:
                      passwordController,

                  label:
                      'Contraseña',

                  prefixIcon:
                      Icons.lock,

                  obscureText: true,
                ),

                const SizedBox(height: 15),

                CustomTextField(
                  controller: confirmarController,
                  label: 'Confirmar contraseña',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                ),

                const SizedBox(height: 15),

                CustomTextField(
                  controller: direccionController,
                  label: 'Dirección (opcional)',
                  prefixIcon: Icons.home,
                ),

                const SizedBox(height: 15),

                DropdownButtonFormField<int>(
                  initialValue: tipoUsuario,
                  decoration: const InputDecoration(labelText: 'Tipo de usuario'),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Administrador')),
                    DropdownMenuItem(value: 2, child: Text('Usuario')),
                  ],
                  onChanged: guardando ? null : (valor) {
                    if (valor != null) setState(() => tipoUsuario = valor);
                  },
                ),

                const SizedBox(height: 25),

                PrimaryButton(
                  text: guardando ? 'GUARDANDO...' : 'REGISTRARME',
                  onPressed: guardando ? () {} : registrarUsuario,
                ),

                const SizedBox(
                  height: 15,
                ),

                TextButton(

                  onPressed: () {

                    Navigator.pop(
                      context,
                    );
                  },

                  child: const Text(
                    'Ya tengo una cuenta',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}