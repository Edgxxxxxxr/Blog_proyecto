/// Archivo: login_user_page.dart.
/// Valida las credenciales, inicia sesión y dirige a la persona según su rol.

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

/// Presenta el acceso, valida campos y enruta a la sección correspondiente al rol.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

/// Controla la validación del formulario y el envío de credenciales.
class _LoginPageState extends State<LoginPage> {
  // Controladores de los campos
  final TextEditingController usuarioController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  // Servicio de autenticación con FastAPI
  final AuthService authService = AuthService();

  bool ocultarPassword = true;
  bool cargando = false;
  String? _correoError;
  String? _passwordError;
  String? _errorGeneral;

  /// Marca el ViewModel como cerrado y libera el notificador base.
  @override
  void dispose() {
    usuarioController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ==========================================
  // INICIAR SESIÓN
  // ==========================================

  /// Valida correo y contraseña, solicita autenticación y redirige según el rol.
  Future<void> iniciarSesion() async {
    // Presenta cada error junto al campo que la persona debe corregir.
    setState(() {
      _correoError = usuarioController.text.trim().isEmpty
          ? 'Ingresa tu correo electrónico.'
          : (!usuarioController.text.contains('@')
                ? 'Ingresa un correo válido.'
                : null);
      _passwordError = passwordController.text.isEmpty
          ? 'Ingresa tu contraseña.'
          : null;
      _errorGeneral = null;
    });
    if (_correoError != null || _passwordError != null) return;

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
      final int tipoUsuario = int.parse(usuario['tip_usu'].toString());

      // Guardar los datos recibidos del backend,
      // incluyendo el access_token.
      final Map<String, dynamic> datosUsuario = Map<String, dynamic>.from(
        usuario,
      );

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
          '/movie-home',
          (route) => false,
          arguments: datosUsuario,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El tipo de usuario no tiene acceso asignado'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final mensaje = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        if (mensaje.toLowerCase().contains('correo o contraseña')) {
          _passwordError = mensaje;
        } else {
          _errorGeneral = mensaje;
        }
      });
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

  /// Presenta los campos de acceso y sus mensajes de validación o error.
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
                const Icon(Icons.lock, size: 65, color: Color(0xFFC9A227)),

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
                  autofillHints: const [AutofillHints.email],
                  errorText: _correoError,
                  onChanged: (_) {
                    if (_correoError != null) {
                      setState(() => _correoError = null);
                    }
                  },
                ),

                const SizedBox(height: 15),

                // Contraseña
                CustomTextField(
                  controller: passwordController,
                  label: 'Contraseña',
                  prefixIcon: Icons.lock_outline,
                  obscureText: ocultarPassword,
                  autofillHints: const [AutofillHints.password],
                  errorText: _passwordError,
                  onChanged: (_) {
                    if (_passwordError != null) {
                      setState(() => _passwordError = null);
                    }
                  },
                  suffixIcon: IconButton(
                    tooltip: ocultarPassword
                        ? 'Mostrar contraseña'
                        : 'Ocultar contraseña',
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

                if (_errorGeneral != null) ...[
                  const SizedBox(height: 8),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      _errorGeneral!,
                      style: const TextStyle(color: Color(0xFFB3261E)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],

                const SizedBox(height: 5),

                // Botón de inicio de sesión
                PrimaryButton(
                  text: cargando ? 'VALIDANDO...' : 'INGRESAR',
                  onPressed: cargando ? null : iniciarSesion,
                ),

                const SizedBox(height: 15),

                // Registro de usuario
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿No tienes cuenta?'),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
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
