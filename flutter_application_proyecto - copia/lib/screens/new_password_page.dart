import 'package:flutter/material.dart';

class RegisterPasswordPage extends StatefulWidget {
  const RegisterPasswordPage({super.key});

  @override
  State<RegisterPasswordPage> createState() =>
      _RegisterPasswordPageState();
}

class _RegisterPasswordPageState
    extends State<RegisterPasswordPage> {

  final TextEditingController correoController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController passwordController2 =
      TextEditingController();

  bool ocultarPassword = true;
  bool ocultarPassword2 = true;

  @override
  void dispose() {
    correoController.dispose();
    passwordController.dispose();
    passwordController2.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar cuenta'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          children: [

            const Icon(
              Icons.person_add,
              size: 70,
            ),

            const SizedBox(height: 20),

            const Text(
              'RECUPERAR CUENTA',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            TextField(
              controller:
                  correoController,

              decoration:
                  const InputDecoration(
                labelText:
                    'Correo electrónico',
                prefixIcon:
                    Icon(Icons.email),
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

               TextField(
                      controller:
                          passwordController2,

                      obscureText:
                          ocultarPassword2,

                      decoration:
                          InputDecoration(

                        labelText:
                            'Contraseña',

                        prefixIcon:
                            const Icon(
                          Icons.lock_outline,
                        ),

                        suffixIcon:
                            IconButton(
                          icon: Icon(
                            ocultarPassword2
                                ? Icons
                                    .visibility_off_outlined
                                : Icons
                                    .visibility_outlined,
                          ),

                          onPressed: () {
                            setState(() {
                              ocultarPassword2 =
                                  !ocultarPassword2;
                            });
                          },
                        ),

                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(6),
                        ),
                      ),
                    ),

            const SizedBox(height: 15),

               TextField(
                      controller:
                          passwordController,

                      obscureText:
                          ocultarPassword,

                      decoration:
                          InputDecoration(

                        labelText:
                            'Contraseña',

                        prefixIcon:
                            const Icon(
                          Icons.lock_outline,
                        ),

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

                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(6),
                        ),
                      ),
                    ),
            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Usuario registrado',
                      ),
                    ),
                  );
                },

                child:
                    const Text('REGISTRARME'),
              ),
            ),

            const SizedBox(height: 15),

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text(
                'Ya tengo una cuenta',
              ),
            ),
          ],
        ),
      ),
    );
  }
}