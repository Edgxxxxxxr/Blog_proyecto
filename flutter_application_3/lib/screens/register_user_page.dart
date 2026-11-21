/// Archivo: register_user_page.dart.
/// Valida los datos del formulario y crea una cuenta de usuario.

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

/// Presenta el registro, valida cada campo y crea una cuenta de usuario.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

/// Valida los campos y gestiona la visibilidad de las contraseñas del registro.
class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nombreController = TextEditingController();

  final TextEditingController correoController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController direccionController = TextEditingController();
  final TextEditingController confirmarController = TextEditingController();
  bool guardando = false;
  bool mostrarPassword = false;
  bool mostrarConfirmacion = false;
  String? _nombreError;
  String? _correoError;
  String? _passwordError;
  String? _confirmarError;
  String? _errorGeneral;

  final AuthService authService = AuthService();

  /// Marca el ViewModel como cerrado y libera el notificador base.
  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    passwordController.dispose();
    direccionController.dispose();
    confirmarController.dispose();

    super.dispose();
  }

  /// Valida los datos y solicita a la API crear la cuenta.
  Future<void> registrarUsuario() async {
    if (guardando) return;

    final nombre = nombreController.text.trim();
    final correo = correoController.text.trim();
    final password = passwordController.text;
    final confirmacion = confirmarController.text;
    setState(() {
      _nombreError = nombre.isEmpty
          ? 'Escribe tu nombre.'
          : (nombre.length < 2
                ? 'El nombre debe tener al menos 2 caracteres.'
                : null);
      _correoError = correo.isEmpty
          ? 'Escribe tu correo electrónico.'
          : (!correo.contains('@') ? 'Ingresa un correo válido.' : null);
      _passwordError = password.isEmpty
          ? 'Escribe una contraseña.'
          : (password.length < 8 ? 'Usa al menos 8 caracteres.' : null);
      _confirmarError = confirmacion.isEmpty
          ? 'Confirma tu contraseña.'
          : (password != confirmacion ? 'Las contraseñas no coinciden.' : null);
      _errorGeneral = null;
    });

    if (_nombreError != null ||
        _correoError != null ||
        _passwordError != null ||
        _confirmarError != null) {
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
        tipoUsuario: 2,
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
      setState(() {
        _nombreError = null;
        _correoError = null;
        _passwordError = null;
        _confirmarError = null;
      });
    } catch (e) {
      if (!mounted) return;
      final mensaje = e.toString().replaceFirst('Exception: ', '');
      if (mensaje.toLowerCase().contains('correo')) {
        setState(() => _correoError = mensaje);
      } else {
        setState(() => _errorGeneral = 'No se pudo registrar: $mensaje');
      }
    } finally {
      if (mounted) setState(() => guardando = false);
    }
  }

  /// Presenta el formulario de registro y los controles de visibilidad de contraseña.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: Center(
          child: AuthCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                const Icon(
                  Icons.person_add,
                  size: 65,
                  color: Color(0xFF2196F3),
                ),

                const SizedBox(height: 15),

                const Text(
                  'CREAR CUENTA',

                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF08245C),
                  ),
                ),

                const SizedBox(height: 25),

                CustomTextField(
                  controller: nombreController,

                  label: 'Nombre completo',

                  prefixIcon: Icons.person,
                  autofillHints: const [AutofillHints.name],
                  errorText: _nombreError,
                  onChanged: (_) {
                    if (_nombreError != null) {
                      setState(() => _nombreError = null);
                    }
                  },
                ),

                const SizedBox(height: 15),

                CustomTextField(
                  controller: correoController,

                  label: 'Correo electrónico',

                  prefixIcon: Icons.email,

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

                CustomTextField(
                  controller: passwordController,

                  label: 'Contraseña',

                  prefixIcon: Icons.lock,

                  obscureText: !mostrarPassword,
                  autofillHints: const [AutofillHints.newPassword],
                  errorText: _passwordError,
                  onChanged: (_) {
                    setState(() {
                      _passwordError = null;
                      if (confirmarController.text.isNotEmpty &&
                          confirmarController.text != passwordController.text) {
                        _confirmarError = 'Las contraseñas no coinciden.';
                      }
                    });
                  },
                  suffixIcon: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF4A4458),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    onPressed: () =>
                        setState(() => mostrarPassword = !mostrarPassword),
                    icon: Icon(
                      mostrarPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                    ),
                    label: Text(mostrarPassword ? 'Ocultar' : 'Mostrar'),
                  ),
                ),

                const SizedBox(height: 15),

                CustomTextField(
                  controller: confirmarController,
                  label: 'Confirmar contraseña',
                  prefixIcon: Icons.lock_outline,
                  obscureText: !mostrarConfirmacion,
                  autofillHints: const [AutofillHints.newPassword],
                  errorText: _confirmarError,
                  onChanged: (value) {
                    setState(() {
                      _confirmarError = value == passwordController.text
                          ? null
                          : 'Las contraseñas no coinciden.';
                    });
                  },
                  suffixIcon: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF4A4458),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    onPressed: () => setState(
                      () => mostrarConfirmacion = !mostrarConfirmacion,
                    ),
                    icon: Icon(
                      mostrarConfirmacion
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                    ),
                    label: Text(mostrarConfirmacion ? 'Ocultar' : 'Mostrar'),
                  ),
                ),

                const SizedBox(height: 15),

                CustomTextField(
                  controller: direccionController,
                  label: 'Dirección (opcional)',
                  prefixIcon: Icons.home,
                  autofillHints: const [AutofillHints.streetAddressLine1],
                ),

                const SizedBox(height: 15),

                const SizedBox(height: 25),

                if (_errorGeneral != null) ...[
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      _errorGeneral!,
                      style: const TextStyle(color: Color(0xFFB3261E)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                PrimaryButton(
                  text: guardando ? 'GUARDANDO...' : 'REGISTRARME',
                  onPressed: guardando ? null : registrarUsuario,
                ),

                const SizedBox(height: 15),

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  child: const Text('Ya tengo una cuenta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
