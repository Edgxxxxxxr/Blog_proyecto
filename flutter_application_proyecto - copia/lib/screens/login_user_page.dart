import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';



class LoginPage extends StatefulWidget {

  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState
    extends State<LoginPage> {

  final TextEditingController usuarioController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final AuthService authService =
      AuthService();

  bool ocultarPassword = true;
  bool cargando= false;

  @override
  void dispose() {
    usuarioController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  Future<void> iniciarSesion() async {
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
    final usuario = await authService.autenticar(
      correo: usuarioController.text,
      password: passwordController.text,
    );

    if (!mounted) return;

    final int tipoUsuario = (usuario['tip_usu'] as num).toInt();

    if (tipoUsuario == 1) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/users',
        (route) => false,
        arguments: usuario,
      );
    } else if (tipoUsuario == 2) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/blog',
        (route) => false,
        arguments: usuario,
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
                  Icons.lock,
                  size: 65,
                  color:
                      Color(0xFFC9A227),
                ),

                const SizedBox(
                  height: 15,
                ),

                const Text(
                  'INICIAR SESIÓN',

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
                      usuarioController,

                  label: 'correo electronico',

                  prefixIcon:
                      Icons.person,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(
                  height: 15,
                ),

                CustomTextField(
                  controller:
                      passwordController,

                  label: 'Contraseña',

                  prefixIcon:
                      Icons.lock_outline,

                  obscureText:
                      ocultarPassword,

                  suffixIcon:
                      IconButton(

                    icon: Icon(
                      ocultarPassword
                          ? Icons
                              .visibility_off_outlined
                          : Icons
                              .visibility_outlined,
                    ),

                    onPressed: () {

                      setState(() {

                        ocultarPassword =
                            !ocultarPassword;

                      });
                    },
                  ),
                ),

                Align(

                  alignment:
                      Alignment.centerRight,

                  child: TextButton(

                    onPressed: () {},

                    child: const Text(
                      '¿Olvidaste tu contraseña?',
                    ),
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                PrimaryButton(
                  text: cargando ? 'Validando..' : 'Ingresar',
                  onPressed: cargando
                    ?  (){}
                    : (){
                      iniciarSesion();
                      }
                      
                ),

                const SizedBox(
                  height: 15,
                ),

                Row(

                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [

                    const Text(
                      '¿No tienes cuenta?',
                    ),

                    TextButton(

                      onPressed: () {

                        Navigator.pushNamed(
                          context,
                          '/register',
                        );
                      },

                      child: const Text(
                        'Registrarse',
                      ),
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
