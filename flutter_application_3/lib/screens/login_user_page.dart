
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controladores de los campos
  final TextEditingController usuarioController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  // Servicio de autenticación con FastAPI
  final AuthService authService = AuthService();

  bool ocultarPassword = true;
  bool cargando = false;

  @override
  void dispose() {
    usuarioController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ==========================================
  // INICIAR SESIÓN
  // ==========================================

  Future<void> iniciarSesion() async {
    // Validar campos vacíos
    final mensaje = authService.validarLogin(
      usuario: usuarioController.text,
      password: passwordController.text,
    );

    if (mensaje != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
      return;
    }

    setState(() {
      cargando = true;
    });

    try {
      // Consultar el login en FastAPI
      final usuario = await authService.autenticar(
        correo: usuarioController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;

      // Obtener el rol
      final int tipoUsuario =
          int.parse(usuario['tip_usu'].toString());

      // Guardar los datos recibidos del backend,
      // incluyendo el access_token.
      final Map<String, dynamic> datosUsuario =
          Map<String, dynamic>.from(usuario);

      // ======================================
      // REDIRECCIÓN SEGÚN EL ROL
      // ======================================

      if (tipoUsuario == 1) {
        // ADMINISTRADOR
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/admin',
          (route) => false,
          arguments: datosUsuario,
        );
      } else if (tipoUsuario == 2) {
        // USUARIO NORMAL
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/blog',
          (route) => false,
          arguments: datosUsuario,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'El tipo de usuario no tiene acceso asignado',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  // ==========================================
  // INTERFAZ DE INICIO DE SESIÓN
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: Center(
          child: AuthCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono
                const Icon(
                  Icons.lock,
                  size: 65,
                  color: Color(0xFFC9A227),
                ),

                const SizedBox(height: 15),

                // Título
                const Text(
                  'INICIAR SESIÓN',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF08245C),
                  ),
                ),

                const SizedBox(height: 25),

                // Correo electrónico
                CustomTextField(
                  controller: usuarioController,
                  label: 'Correo electrónico',
                  prefixIcon: Icons.person,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 15),

                // Contraseña
                CustomTextField(
                  controller: passwordController,
                  label: 'Contraseña',
                  prefixIcon: Icons.lock_outline,
                  obscureText: ocultarPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      ocultarPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        ocultarPassword = !ocultarPassword;
                      });
                    },
                  ),
                ),

                // Recuperar contraseña
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      '¿Olvidaste tu contraseña?',
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                // Botón de inicio de sesión
                PrimaryButton(
                  text: cargando
                      ? 'VALIDANDO...'
                      : 'INGRESAR',
                  onPressed: cargando
                      ? () {}
                      : () {
                          iniciarSesion();
                        },
                ),

                const SizedBox(height: 15),

                // Registro de usuario
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿No tienes cuenta?'),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/register',
                        );
                      },
                      child: const Text('Registrarse'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
