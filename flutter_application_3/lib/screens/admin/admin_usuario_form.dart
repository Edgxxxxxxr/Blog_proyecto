/// Archivo: admin_usuario_form.dart.
/// Construye y valida el formulario para crear o actualizar una cuenta.

// World of Movies: Formularios de alta y edición de usuarios.
// part of permite compartir imports y el estado de la pantalla principal.
part of '../admin_dashboard_page.dart';

// Este mixin aporta funciones al mismo estado; no crea otra pantalla independiente.
mixin _AdminUsuarioForm on _AdminDashboardBase {
  // =====================================
  // FORMULARIO DE USUARIOS
  // =====================================

  // Abre el formulario de registro o edición de usuarios.
  /// Carga o inicializa los campos y envía el alta o edición de la cuenta.
  @override
  Future<void> formularioUsuario([Map<String, dynamic>? usuario]) async {
    // Indica si el usuario ya existe.
    final editando = usuario != null;

    // Inicializa el nombre con los datos del usuario.
    final nombre = TextEditingController(
      // Carga el nombre existente o una cadena vacía.
      text: usuario?['nom_usr']?.toString() ?? '',
    );

    // Inicializa el correo con los datos del usuario.
    final correo = TextEditingController(
      // Carga el correo existente o una cadena vacía.
      text: usuario?['mail']?.toString() ?? '',
    );

    // Inicializa la dirección con los datos del usuario.
    final direccion = TextEditingController(
      // Carga la dirección existente o una cadena vacía.
      text: usuario?['dir_usr']?.toString() ?? '',
    );

    // Crea el controlador de contraseña vacío.
    final password = TextEditingController();

    // Clave para validar el formulario de usuario.
    final formulario = GlobalKey<FormState>();

    // 1 = Administrador
    // 2 = Usuario normal
    // Selecciona el rol actual o el rol 2 por defecto.
    int rol = usuario?['tip_usu'] == 1 ? 1 : 2;

    // Identifica si se está editando la propia cuenta.
    final esMiCuenta = editando && usuario['id_usr'] == administrador['id_usr'];

    // Crea la ruta de diálogo para el formulario de usuarios.
    final ruta = DialogRoute<Map<String, dynamic>>(
      // Contexto que se utiliza para construir o navegar entre widgets.
      context: context,
      // Controla si un toque fuera del diálogo permite cerrarlo.
      barrierDismissible: false,

      // Función que construye el contenido cuando Flutter lo necesita.
      builder: (dialogContext) => StatefulBuilder(
        // Función que construye el contenido cuando Flutter lo necesita.
        builder: (context, cambiarEstado) {
          // Crea el componente AlertDialog de la interfaz.
          return AlertDialog(
            // Define el título visible.
            title: Text(editando ? 'Editar usuario' : 'Agregar usuario'),

            // Define el contenido principal del diálogo.
            content: SizedBox(
              // Define el ancho del elemento.
              width: 420,

              // Contiene el widget hijo.
              child: SingleChildScrollView(
                // Contiene el widget hijo.
                child: Form(
                  // Identifica el formulario o widget.
                  key: formulario,

                  // Contiene el widget hijo.
                  child: Column(
                    // Controla cuánto espacio ocupa el widget en su eje principal.
                    mainAxisSize: MainAxisSize.min,

                    // Lista de widgets que componen esta sección.
                    children: [
                      // Crea el componente Icon de la interfaz.
                      const Icon(Icons.person_outline, size: 65),

                      // Añade un espacio fijo entre los componentes.
                      const SizedBox(height: 20),

                      // Crea un campo de formulario con las opciones indicadas.
                      campo(nombre, 'Nombre', minimo: 2, maximo: 100),

                      // Correo electrónico
                      // Crea el componente TextFormField de la interfaz.
                      TextFormField(
                        // Vincula el campo con su controlador de texto.
                        controller: correo,
                        // Limita el número de caracteres del campo.
                        maxLength: 150,
                        // Indica el tipo de teclado que se solicita.
                        keyboardType: TextInputType.emailAddress,

                        // Configura la apariencia visual del elemento.
                        decoration: const InputDecoration(
                          // Etiqueta visible del campo.
                          labelText: 'Correo electrónico',
                          // Define el borde del componente.
                          border: OutlineInputBorder(),
                        ),

                        // Valida el correo electrónico.
                        validator: (valor) {
                          // Comprueba esta condición antes de ejecutar el siguiente bloque.
                          if (valor == null || valor.trim().isEmpty) {
                            // Devuelve el mensaje de correo obligatorio.
                            return 'Ingresa el correo';
                          }

                          // Comprueba el formato básico del correo con una expresión regular.
                          if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                              // Comprueba la coincidencia de la expresión regular.
                              .hasMatch(valor.trim())) {
                            // Informa de un correo con formato inválido.
                            return 'Correo inválido';
                          }

                          // Devuelve null cuando no hay error o no existe un resultado.
                          return null;
                        },
                      ),

                      // Añade un espacio fijo entre los componentes.
                      const SizedBox(height: 12),

                      // Solo solicita contraseña al crear un usuario.
                      if (!editando)
                        // Crea un campo de formulario con las opciones indicadas.
                        campo(
                          // Vincula el controlador de la contraseña.
                          password,
                          // Etiqueta del campo de contraseña.
                          'Contraseña',
                          // Indica si se oculta el texto.
                          oculto: true,
                          // Longitud mínima aceptada.
                          minimo: 8,
                          // Longitud máxima aceptada.
                          maximo: 72,
                        ),

                      // Crea un campo de formulario con las opciones indicadas.
                      campo(
                        // Vincula el controlador de la dirección.
                        direccion,
                        // Etiqueta del campo de dirección.
                        'Dirección',
                        // Indica si el campo es obligatorio.
                        obligatorio: false,
                        // Longitud máxima aceptada.
                        maximo: 255,
                      ),

                      // Añade un espacio fijo entre los componentes.
                      const SizedBox(height: 10),

                      // Seleccionar rol
                      // Crea el selector desplegable del rol mediante valores enteros.
                      DropdownButtonFormField<int>(
                        // Valor que se muestra seleccionado.
                        initialValue: rol,

                        // Configura la apariencia visual del elemento.
                        decoration: const InputDecoration(
                          // Etiqueta visible del campo.
                          labelText: 'Rol',
                          // Define el borde del componente.
                          border: OutlineInputBorder(),
                        ),

                        // Opciones disponibles para seleccionar.
                        items: const [
                          // Crea el componente DropdownMenuItem de la interfaz.
                          DropdownMenuItem(
                            // Valor que se muestra seleccionado.
                            value: 1,
                            // Contiene el widget hijo.
                            child: Text('Administrador'),
                          ),

                          // Crea el componente DropdownMenuItem de la interfaz.
                          DropdownMenuItem(value: 2, child: Text('Usuario')),
                        ],

                        // Evitar quitar el propio rol
                        // Deshabilita el cambio de rol para la cuenta propia.
                        onChanged: esMiCuenta
                            // Valor que se utiliza cuando la condición es verdadera.
                            ? null
                            // Valor alternativo cuando la condición es falsa.
                            : (valor) {
                                // Actualiza solo el estado interno del diálogo.
                                cambiarEstado(() {
                                  // Actualiza el rol seleccionado en el diálogo.
                                  rol = valor ?? 2;
                                });
                              },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Define los botones o acciones disponibles.
            actions: [
              // Crea el componente TextButton de la interfaz.
              TextButton(
                // Define qué sucede al pulsar el botón.
                onPressed: () {
                  // Retira el foco del campo de entrada antes de cerrar el diálogo.
                  FocusScope.of(dialogContext).unfocus();

                  // Cierra el diálogo y devuelve el resultado si se proporcionó.
                  Navigator.of(dialogContext).pop();
                },

                // Contiene el widget hijo.
                child: const Text('Cancelar'),
              ),

              // Crea el componente FilledButton de la interfaz.
              FilledButton(
                // Define qué sucede al pulsar el botón.
                onPressed: () {
                  // Impide guardar si algún campo no es válido.
                  if (!formulario.currentState!.validate()) {
                    // Termina la función sin continuar.
                    return;
                  }

                  // Prepara los datos con las claves de la API.
                  final datosUsuario = <String, dynamic>{
                    // Envía el nombre sin espacios exteriores.
                    'nom_usr': nombre.text.trim(),
                    // Envía el correo sin espacios exteriores.
                    'mail': correo.text.trim(),
                    // Envía la dirección sin espacios exteriores.
                    'dir_usr': direccion.text.trim(),
                    // Incluye el número del rol seleccionado.
                    'tip_usu': rol,
                  };

                  // Solo añade la contraseña al crear una cuenta.
                  if (!editando) {
                    // Envía la contraseña al backend para su procesamiento.
                    datosUsuario['password'] = password.text;
                  }

                  // Retira el foco del campo de entrada antes de cerrar el diálogo.
                  FocusScope.of(dialogContext).unfocus();

                  // Cierra el diálogo y devuelve el mapa del usuario.
                  Navigator.of(dialogContext).pop(datosUsuario);
                },

                // Contiene el widget hijo.
                child: Text(editando ? 'Actualizar' : 'Guardar'),
              ),
            ],
          );
        },
      ),
    );

    // Abrir el formulario
    // Abre el diálogo y espera el resultado seleccionado.
    final datos = await Navigator.of(context, rootNavigator: true).push(ruta);

    // Esperar a que se cierre completamente
    // Espera que finalice la animación de cierre.
    await ruta.completed;

    // Liberar los controladores
    // Libera el controlador del nombre.
    nombre.dispose();
    // Libera el controlador del correo.
    correo.dispose();
    // Libera el controlador de la dirección.
    direccion.dispose();
    // Libera el controlador de la contraseña.
    password.dispose();

    // Comprueba que el widget permanece montado.
    if (datos == null || !mounted) return;

    // Guardar los cambios utilizando FastAPI
    // Ejecuta la acción remota y actualiza la información del panel.
    await ejecutarOperacion(
      // Define la operación asíncrona de guardar el usuario.
      () async {
        // Determina si hay un usuario existente para actualizar.
        if (usuario != null) {
          // Envía la actualización con el identificador del usuario.
          await servicio!.editarUsuario(usuario['id_usr'], datos);
        // Alternativa cuando no se cumple la condición anterior.
        } else {
          // Envía el registro de un usuario nuevo.
          await servicio!.agregarUsuario(datos);
        }
      },

      // Selecciona el mensaje de éxito según sea edición o alta.
      editando
          // Valor que se utiliza cuando la condición es verdadera.
          ? 'Usuario actualizado correctamente'
          // Valor alternativo cuando la condición es falsa.
          : 'Usuario registrado correctamente',
    );
  }

}
