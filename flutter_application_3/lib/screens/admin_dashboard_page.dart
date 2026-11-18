import 'package:flutter/material.dart';

import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

import '../services/admin_service.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  Map<String, String> separarTags(dynamic valor) {
    final texto = valor?.toString() ?? '';

    final coincidencia = RegExp(r'(?:^| \| )Año: (\d{4}) \| Duración: (.+)$')
        .firstMatch(texto);

    if (coincidencia == null) {
      return {'año': '', 'duración': ''};
    }

    return {
      'año': coincidencia.group(1) ?? '',
      'duración': coincidencia.group(2) ?? '',
    };
  }

  AdminService? servicio;

  Map<String, dynamic> administrador = {};

  int pagina = 0;
  String busqueda = '';
  String? error;
  bool cargando = true;
  bool iniciado = false;

  List<Map<String, dynamic>> peliculas = [];
  List<Map<String, dynamic>> usuarios = [];
  List<Map<String, dynamic>> resenas = [];

  final titulos = [
    'Inicio',
    'Películas',
    'Usuarios',
    'Reseñas',
    'Configuración',
  ];

  final iconos = [
    Icons.home_outlined,
    Icons.movie_outlined,
    Icons.people_outline,
    Icons.star_border,
    Icons.settings_outlined,
  ];

  // =====================================
  // RECIBIR DATOS DEL LOGIN
  // =====================================

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (iniciado) return;
    iniciado = true;

    final argumentos = ModalRoute.of(context)?.settings.arguments;

    if (argumentos is Map) {
      administrador = Map<String, dynamic>.from(argumentos);

      final token = administrador['access_token']?.toString() ?? '';

      final rol = administrador['tip_usu']?.toString();

      if (token.isNotEmpty && rol == '1') {
        servicio = AdminService(token);
        cargarDatos();
        return;
      }
    }

    cargando = false;
    error = 'Debes iniciar sesión como administrador.';
  }

  // =====================================
  // CARGAR DATOS REALES DE MYSQL
  // =====================================

  Future<void> cargarDatos() async {
    if (servicio == null) return;

    setState(() {
      cargando = true;
      error = null;
    });

    try {
      final listaPeliculas = await servicio!.obtenerPeliculas();

      final listaUsuarios = await servicio!.obtenerUsuarios();

      final listaResenas = await servicio!.obtenerResenas();

      if (!mounted) return;

      setState(() {
        peliculas = listaPeliculas;
        usuarios = listaUsuarios;
        resenas = listaResenas;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  // =====================================
  // FUNCIONES GENERALES
  // =====================================

  void aviso(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  void cambiarPagina(int destino) {
    setState(() {
      pagina = destino;
      busqueda = '';
    });
  }

  Future<bool> confirmar(String mensaje) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmar'),
            content: Text(mensaje),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> ejecutarOperacion(
    Future<void> Function() operacion,
    String mensaje,
  ) async {
    if (cargando || servicio == null) return;

    setState(() {
      cargando = true;
    });

    try {
      await operacion();

      if (!mounted) return;

      aviso(mensaje);
      await cargarDatos();
    } catch (e) {
      if (!mounted) return;

      aviso(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  Future<void> cerrarSesion() async {
    final respuesta = await confirmar('¿Deseas cerrar sesión?');

    if (!respuesta || !mounted) return;

    administrador.clear();
    servicio = null;

    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  // =====================================
  // CAMPO DE FORMULARIO
  // =====================================

  Widget campo(
    TextEditingController controlador,
    String etiqueta, {
    bool obligatorio = true,
    bool oculto = false,
    int lineas = 1,
    int? maximo,
    int minimo = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controlador,
        obscureText: oculto,
        maxLines: lineas,
        maxLength: maximo,
        decoration: InputDecoration(
          labelText: etiqueta,
          border: const OutlineInputBorder(),
        ),
        validator: (valor) {
          final texto = valor?.trim() ?? '';

          if (obligatorio && texto.isEmpty) {
            return 'Completa este campo';
          }

          if (texto.isNotEmpty && texto.length < minimo) {
            return 'Mínimo $minimo caracteres';
          }

          return null;
        },
      ),
    );
  }

  // =====================================
  // FORMULARIO DE PELÍCULAS
  // =====================================

  Future<void> formularioPelicula([Map<String, dynamic>? pelicula]) async {
    final editando = pelicula != null;

    final datosTags = separarTags(pelicula?['tags']);

    final titulo = TextEditingController(
      text: pelicula?['titulo']?.toString() ?? '',
    );


    final anio = TextEditingController(text: datosTags['año']);

    final duracion = TextEditingController(text: datosTags['duración']);

    final sinopsis = TextEditingController(
      text: pelicula?['descripcion']?.toString() ?? '',
    );

    String? imagenActual = pelicula?['img']?.toString();

    Uint8List? imagenBytes;
    String? nombreImagen;
    String? errorImagen;

    bool seleccionando = false;

    final formulario = GlobalKey<FormState>();

    final ruta = DialogRoute<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,

      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, cambiarEstado) {
            return AlertDialog(
              title: Text(editando ? 'Editar película' : 'Agregar película'),

              content: SizedBox(
                width: 420,

                child: SingleChildScrollView(
                  child: Form(
                    key: formulario,

                    child: Column(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        // ====================
                        // IMAGEN DE LA PELÍCULA
                        // ====================

                        GestureDetector(
                          onTap: seleccionando
                              ? null
                              : () async {
                                  cambiarEstado(() {
                                    seleccionando = true;
                                    errorImagen = null;
                                  });

                                  try {
                                    final picker = ImagePicker();

                                    final archivo = await picker.pickImage(
                                      source: ImageSource.gallery,
                                      imageQuality: 85,
                                    );

                                    if (archivo == null) return;

                                    final bytes = await archivo.readAsBytes();

                                    if (!dialogContext.mounted) {
                                      return;
                                    }

                                    if (bytes.isEmpty ||
                                        bytes.length > 5 * 1024 * 1024) {
                                      cambiarEstado(() {
                                        errorImagen = 'Selecciona una imagen menor a 5 MB';
                                      });

                                      return;
                                    }

                                    final extension = archivo.name
                                        .split('.')
                                        .last
                                        .toLowerCase();

                                    if (![
                                      'jpg',
                                      'jpeg',
                                      'png',
                                      'webp',
                                    ].contains(extension)) {
                                      cambiarEstado(() {
                                        errorImagen =
                                            'Selecciona JPG, PNG o WebP';
                                      });
                                      return;
                                    }

                                    cambiarEstado(() {
                                      imagenBytes = bytes;
                                      nombreImagen = archivo.name;
                                    });
                                  } catch (e) {
                                    if (!dialogContext.mounted) {
                                      return;
                                    }

                                    cambiarEstado(() {
                                      errorImagen =
                                          'No se pudo seleccionar la imagen';
                                    });
                                  } finally {
                                    if (dialogContext.mounted) {
                                      cambiarEstado(() {
                                        seleccionando = false;
                                      });
                                    }
                                  }
                                },

                          child: Container(
                            height: 155,
                            width: 155,

                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,

                              borderRadius: BorderRadius.circular(12),

                              border: Border.all(color: Colors.grey),
                            ),

                            child: Stack(
                              alignment: Alignment.center,

                              children: [
                                if (imagenBytes != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),

                                    child: Image.memory(
                                      imagenBytes!,
                                      width: 155,
                                      height: 155,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                else if (imagenActual != null &&
                                    imagenActual.isNotEmpty)
                                  fotoPelicula(imagenActual)
                                else
                                  const Icon(
                                    Icons.image_outlined,
                                    color: Colors.grey,
                                    size: 75,
                                  ),

                                if (seleccionando)
                                  const CircularProgressIndicator(),

                                Positioned(
                                  bottom: 5,
                                  right: 5,

                                  child: Container(
                                    padding: const EdgeInsets.all(8),

                                    decoration: const BoxDecoration(
                                      color: Color(0xFF08245C),
                                      shape: BoxShape.circle,
                                    ),

                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          nombreImagen ?? 'Toca para seleccionar imagen',

                          textAlign: TextAlign.center,

                          style: const TextStyle(fontSize: 13),
                        ),

                        if (errorImagen != null)
                          Padding(
                            padding: const EdgeInsets.all(8),

                            child: Text(
                              errorImagen!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),

                        const SizedBox(height: 20),

                        // TÍTULO
                        campo(titulo, 'Título', minimo: 2, maximo: 200),

                        // GÉNERO

                        // AÑO DE ESTRENO
                        TextFormField(
                          controller: anio,
                          keyboardType: TextInputType.number,

                          maxLength: 4,

                          decoration: const InputDecoration(
                            labelText: 'Año de estreno',
                            border: OutlineInputBorder(),
                          ),

                          validator: (valor) {
                            final numero = int.tryParse(valor?.trim() ?? '');

                            if (numero == null ||
                                numero < 1888 ||
                                numero > DateTime.now().year + 5) {
                              return 'Ingresa un año válido';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        // DURACIÓN
                        campo(
                          duracion,
                          'Duración (ej. 2 h 10 min)',
                          maximo: 60,
                        ),

                        // SINOPSIS
                        campo(sinopsis, 'Sinopsis', lineas: 4, maximo: 500),
                      ],
                    ),
                  ),
                ),
              ),

              actions: [
                TextButton(
                  onPressed: seleccionando
                      ? null
                      : () {
                          FocusScope.of(dialogContext).unfocus();

                          Navigator.of(dialogContext).pop();
                        },

                  child: const Text('Cancelar'),
                ),

                FilledButton(
                  onPressed: seleccionando
                      ? null
                      : () {
                          if (!formulario.currentState!.validate()) {
                            return;
                          }

                          final tags =
                              'Año: ${anio.text.trim()} | '
                              'Duración: ${duracion.text.trim()}';

                          if (tags.length > 255) {
                            aviso('El año y duración son demasiado largos');
                            return;
                          }

                          final datos = <String, dynamic>{
                            'titulo': titulo.text.trim(),
                            'descripcion': sinopsis.text.trim(),
                            'tags': tags,
                            'img': imagenActual,
                          };

                          FocusScope.of(dialogContext).unfocus();

                          Navigator.of(dialogContext).pop(datos);
                        },

                  child: Text(editando ? 'Actualizar' : 'Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    // Abrir el formulario
    final datos = await Navigator.of(context, rootNavigator: true).push(ruta);

    // Esperar a que termine la animación
    await ruta.completed;

    // Liberar los controladores
    titulo.dispose();
    anio.dispose();
    duracion.dispose();
    sinopsis.dispose();

    if (datos == null || !mounted) return;

    // =====================================
    // GUARDAR EN FASTAPI Y MYSQL
    // =====================================

    await ejecutarOperacion(
      () async {
        // Subir una imagen nueva si se seleccionó
        if (imagenBytes != null && nombreImagen != null) {
          final rutaImagen = await servicio!.subirImagen(
            bytes: imagenBytes!,
            nombre: nombreImagen!,
          );

          datos['img'] = rutaImagen;
        }

        // Actualizar película
        if (pelicula != null) {
          await servicio!.editarPelicula(pelicula['id_blog'], datos);
        } else {
          // Registrar película nueva
          await servicio!.agregarPelicula(datos);
        }
      },

      editando
          ? 'Película actualizada correctamente'
          : 'Película agregada correctamente',
    );
  }

  // =====================================
  // FORMULARIO DE USUARIOS
  // =====================================

  Future<void> formularioUsuario([Map<String, dynamic>? usuario]) async {
    final editando = usuario != null;

    final nombre = TextEditingController(
      text: usuario?['nom_usr']?.toString() ?? '',
    );

    final correo = TextEditingController(
      text: usuario?['mail']?.toString() ?? '',
    );

    final direccion = TextEditingController(
      text: usuario?['dir_usr']?.toString() ?? '',
    );

    final password = TextEditingController();

    final formulario = GlobalKey<FormState>();

    // 1 = Administrador
    // 2 = Usuario normal
    int rol = usuario?['tip_usu'] == 1 ? 1 : 2;

    final esMiCuenta = editando && usuario['id_usr'] == administrador['id_usr'];

    final ruta = DialogRoute<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,

      builder: (dialogContext) => StatefulBuilder(
        builder: (context, cambiarEstado) {
          return AlertDialog(
            title: Text(editando ? 'Editar usuario' : 'Agregar usuario'),

            content: SizedBox(
              width: 420,

              child: SingleChildScrollView(
                child: Form(
                  key: formulario,

                  child: Column(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      const Icon(Icons.person_outline, size: 65),

                      const SizedBox(height: 20),

                      campo(nombre, 'Nombre', minimo: 2, maximo: 100),

                      // Correo electrónico
                      TextFormField(
                        controller: correo,
                        maxLength: 150,
                        keyboardType: TextInputType.emailAddress,

                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          border: OutlineInputBorder(),
                        ),

                        validator: (valor) {
                          if (valor == null || valor.trim().isEmpty) {
                            return 'Ingresa el correo';
                          }

                          if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                              .hasMatch(valor.trim())) {
                            return 'Correo inválido';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      if (!editando)
                        campo(
                          password,
                          'Contraseña',
                          oculto: true,
                          minimo: 8,
                          maximo: 72,
                        ),

                      campo(
                        direccion,
                        'Dirección',
                        obligatorio: false,
                        maximo: 255,
                      ),

                      const SizedBox(height: 10),

                      // Seleccionar rol
                      DropdownButtonFormField<int>(
                        value: rol,

                        decoration: const InputDecoration(
                          labelText: 'Rol',
                          border: OutlineInputBorder(),
                        ),

                        items: const [
                          DropdownMenuItem(
                            value: 1,
                            child: Text('Administrador'),
                          ),

                          DropdownMenuItem(value: 2, child: Text('Usuario')),
                        ],

                        // Evitar quitar el propio rol
                        onChanged: esMiCuenta
                            ? null
                            : (valor) {
                                cambiarEstado(() {
                                  rol = valor ?? 2;
                                });
                              },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            actions: [
              TextButton(
                onPressed: () {
                  FocusScope.of(dialogContext).unfocus();

                  Navigator.of(dialogContext).pop();
                },

                child: const Text('Cancelar'),
              ),

              FilledButton(
                onPressed: () {
                  if (!formulario.currentState!.validate()) {
                    return;
                  }

                  final datosUsuario = <String, dynamic>{
                    'nom_usr': nombre.text.trim(),
                    'mail': correo.text.trim(),
                    'dir_usr': direccion.text.trim(),
                    'tip_usu': rol,
                  };

                  if (!editando) {
                    datosUsuario['password'] = password.text;
                  }

                  FocusScope.of(dialogContext).unfocus();

                  Navigator.of(dialogContext).pop(datosUsuario);
                },

                child: Text(editando ? 'Actualizar' : 'Guardar'),
              ),
            ],
          );
        },
      ),
    );

    // Abrir el formulario
    final datos = await Navigator.of(context, rootNavigator: true).push(ruta);

    // Esperar a que se cierre completamente
    await ruta.completed;

    // Liberar los controladores
    nombre.dispose();
    correo.dispose();
    direccion.dispose();
    password.dispose();

    if (datos == null || !mounted) return;

    // Guardar los cambios utilizando FastAPI
    await ejecutarOperacion(
      () async {
        if (usuario != null) {
          await servicio!.editarUsuario(usuario['id_usr'], datos);
        } else {
          await servicio!.agregarUsuario(datos);
        }
      },

      editando
          ? 'Usuario actualizado correctamente'
          : 'Usuario registrado correctamente',
    );
  }

  // =====================================
  // DASHBOARD PRINCIPAL
  // =====================================

  Widget inicio() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Bienvenido, ${administrador['nom_usr'] ?? 'Administrador'}',
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        const Text('Panel de administración de World of Movies'),

        const SizedBox(height: 25),

        GridView.extent(
          maxCrossAxisExtent: 280,
          mainAxisExtent: 170,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,

          children: [
            tarjetaInicio(
              'Películas',
              peliculas.length.toString(),
              Icons.movie_outlined,
              1,
            ),

            tarjetaInicio(
              'Usuarios',
              usuarios.length.toString(),
              Icons.people_outline,
              2,
            ),

            tarjetaInicio(
              'Reseñas',
              resenas.length.toString(),
              Icons.star_border,
              3,
            ),

            tarjetaInicio('Configuración', '', Icons.settings_outlined, 4),
          ],
        ),
      ],
    );
  }

  Widget tarjetaInicio(
    String titulo,
    String cantidad,
    IconData icono,
    int destino,
  ) {
    return Card(
      color: Colors.white,
      elevation: 2,
      clipBehavior: Clip.antiAlias,

      child: InkWell(
        onTap: () => cambiarPagina(destino),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(icono, color: const Color(0xFFC9A227), size: 45),

            const SizedBox(height: 12),

            Text(
              titulo,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            if (cantidad.isNotEmpty)
              Text(cantidad, style: const TextStyle(fontSize: 22)),
          ],
        ),
      ),
    );
  }

  // =====================================
  // BUSCADOR
  // =====================================

  Widget buscador(String texto) {
    return Padding(
      padding: const EdgeInsets.all(15),

      child: TextField(
        key: ValueKey(pagina),

        onChanged: (valor) {
          setState(() {
            busqueda = valor;
          });
        },

        decoration: InputDecoration(
          hintText: texto,
          prefixIcon: const Icon(Icons.search),

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // =====================================
  // IMÁGENES DE LAS PELÍCULAS
  // =====================================

  Widget fotoPelicula(dynamic imagen) {
    String ruta = imagen?.toString().trim() ?? '';

    if (ruta.isEmpty) {
      return const Icon(Icons.movie_outlined, size: 42);
    }

    if (ruta.startsWith('/')) {
      ruta = '${AdminService.baseUrl}$ruta';
    } else if (!ruta.startsWith('http://') && !ruta.startsWith('https://')) {
      if (ruta.startsWith('imagenes/') || ruta.startsWith('uploads/')) {
        ruta = '${AdminService.baseUrl}/$ruta';
      } else {
        ruta = '${AdminService.baseUrl}/imagenes/$ruta';
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        ruta,
        width: 55,
        height: 65,
        fit: BoxFit.cover,

        errorBuilder: (context, error, stack) {
          return const Icon(Icons.movie_outlined, size: 40);
        },
      ),
    );
  }

  // =====================================
  // PROMEDIO DE CALIFICACIONES
  // =====================================

  double? promedioPelicula(dynamic idPelicula) {
    final calificaciones = resenas
        .where((resena) {
          final valor = resena['calificacion'];

          return resena['blog_id'] == idPelicula &&
              resena['estatus'] == 1 &&
              valor is num &&
              valor >= 1 &&
              valor <= 5;
        })
        .map((resena) => (resena['calificacion'] as num).toDouble())
        .toList();

    if (calificaciones.isEmpty) {
      return null;
    }

    final suma = calificaciones.reduce((a, b) => a + b);

    return suma / calificaciones.length;
  }

  // =====================================
  // MOSTRAR ESTRELLAS
  // =====================================

  Widget estrellas(dynamic valor) {
    final double? calificacion = double.tryParse(valor.toString());

    if (calificacion == null || calificacion < 1 || calificacion > 5) {
      return const Text(
        'Sin calificación',
        style: TextStyle(color: Colors.grey, fontSize: 13),
      );
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 3,

      children: [
        ...List.generate(5, (index) {
          IconData icono;

          if (calificacion >= index + 1) {
            icono = Icons.star;
          } else if (calificacion >= index + 0.5) {
            icono = Icons.star_half;
          } else {
            icono = Icons.star_border;
          }

          return Icon(icono, color: const Color(0xFFC9A227), size: 19);
        }),

        Text(
          '${calificacion.toStringAsFixed(1)}/5',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // =====================================
  // LISTADO DE PELÍCULAS
  // =====================================

  Widget pantallaPeliculas() {
    final lista = peliculas.where((p) {
      return '${p['titulo']} ${p['tags'] ?? ''}'.toLowerCase().contains(
        busqueda.toLowerCase(),
      );
    }).toList();

    return Column(
      children: [
        buscador('Buscar película...'),

        Expanded(
          child: lista.isEmpty
              ? const Center(child: Text('No hay películas'))
              : ListView.builder(
                  itemCount: lista.length,

                  itemBuilder: (context, index) {
                    final pelicula = lista[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 6,
                      ),

                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),

                        leading: fotoPelicula(pelicula['img']),

                        title: Text(
                          pelicula['titulo'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pelicula['tags'] ?? 'Sin categoría'),

                            const SizedBox(height: 5),

                            estrellas(promedioPelicula(pelicula['id_blog'])),
                          ],
                        ),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,

                          children: [
                            IconButton(
                              tooltip: 'Editar',
                              icon: const Icon(Icons.edit),
                              onPressed: () => formularioPelicula(pelicula),
                            ),

                            IconButton(
                              tooltip: 'Eliminar',
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),

                              onPressed: () async {
                                if (await confirmar(
                                  '¿Eliminar esta película?',
                                )) {
                                  await ejecutarOperacion(
                                    () => servicio!.eliminarPelicula(
                                      pelicula['id_blog'],
                                    ),
                                    'Película eliminada',
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // =====================================
  // LISTADO DE USUARIOS
  // =====================================

  Widget pantallaUsuarios() {
    final lista = usuarios.where((u) {
      return '${u['nom_usr']} ${u['mail']}'.toLowerCase().contains(
        busqueda.toLowerCase(),
      );
    }).toList();

    return Column(
      children: [
        buscador('Buscar usuario...'),

        Expanded(
          child: lista.isEmpty
              ? const Center(child: Text('No hay usuarios'))
              : ListView.builder(
                  itemCount: lista.length,

                  itemBuilder: (context, index) {
                    final usuario = lista[index];

                    final esAdmin = usuario['tip_usu'] == 1;

                    final esMiCuenta =
                        usuario['id_usr'] == administrador['id_usr'];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 6,
                      ),

                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(
                            esAdmin ? Icons.admin_panel_settings : Icons.person,
                          ),
                        ),

                        title: Text(usuario['nom_usr'] ?? ''),

                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(usuario['mail'] ?? ''),

                            Text(
                              esAdmin ? 'Administrador' : 'Usuario',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,

                          children: [
                            IconButton(
                              tooltip: 'Editar',
                              icon: const Icon(Icons.edit),

                              onPressed: () => formularioUsuario(usuario),
                            ),

                            IconButton(
                              tooltip: 'Eliminar',
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),

                              onPressed: esMiCuenta
                                  ? null
                                  : () async {
                                      if (await confirmar(
                                        '¿Eliminar este usuario?',
                                      )) {
                                        await ejecutarOperacion(
                                          () => servicio!.eliminarUsuario(
                                            usuario['id_usr'],
                                          ),
                                          'Usuario eliminado',
                                        );
                                      }
                                    },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // =====================================
  // OBTENER NOMBRES PARA LAS RESEÑAS
  // =====================================

  String nombrePelicula(dynamic id) {
    for (final pelicula in peliculas) {
      if (pelicula['id_blog'] == id) {
        return pelicula['titulo']?.toString() ?? 'Película';
      }
    }

    return 'Película #$id';
  }

  String nombreUsuario(dynamic id) {
    for (final usuario in usuarios) {
      if (usuario['id_usr'] == id) {
        return usuario['nom_usr']?.toString() ?? 'Usuario';
      }
    }

    return 'Usuario #$id';
  }

  // =====================================
  // MODERACIÓN DE RESEÑAS
  // =====================================

  Widget pantallaResenas() {
    final lista = resenas.where((r) {
      final texto =
          '${nombrePelicula(r['blog_id'])} '
          '${nombreUsuario(r['usr_id'])} '
          '${r['comentario']}';

      return texto.toLowerCase().contains(busqueda.toLowerCase());
    }).toList();

    return Column(
      children: [
        buscador('Buscar reseña...'),

        Expanded(
          child: lista.isEmpty
              ? const Center(child: Text('No hay reseñas'))
              : ListView.builder(
                  itemCount: lista.length,

                  itemBuilder: (context, index) {
                    final resena = lista[index];

                    final aprobada = resena['estatus'] == 1;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 6,
                      ),

                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),

                        title: Text(
                          nombrePelicula(resena['blog_id']),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(nombreUsuario(resena['usr_id'])),

                            const SizedBox(height: 5),

                            estrellas(resena['calificacion']),

                            const SizedBox(height: 5),

                            const SizedBox(height: 5),

                            Text(resena['comentario'] ?? ''),

                            const SizedBox(height: 4),

                            Text(
                              aprobada ? 'Aprobada' : 'Oculta',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: aprobada ? Colors.green : Colors.orange,
                              ),
                            ),
                          ],
                        ),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,

                          children: [
                            IconButton(
                              tooltip: aprobada ? 'Ocultar' : 'Aprobar',

                              icon: Icon(
                                aprobada
                                    ? Icons.visibility_off
                                    : Icons.check_circle,

                                color: Colors.green,
                              ),

                              onPressed: () async {
                                await ejecutarOperacion(
                                  () => servicio!.moderarResena(
                                    resena['id_com'],
                                    aprobada ? 0 : 1,
                                  ),
                                  'Reseña actualizada',
                                );
                              },
                            ),

                            IconButton(
                              tooltip: 'Eliminar',

                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),

                              onPressed: () async {
                                if (await confirmar('¿Eliminar esta reseña?')) {
                                  await ejecutarOperacion(
                                    () => servicio!.eliminarResena(
                                      resena['id_com'],
                                    ),
                                    'Reseña eliminada',
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // =====================================
  // PERFIL Y CONFIGURACIÓN
  // =====================================

  Widget configuracion() {
    Map<String, dynamic> perfil = administrador;

    for (final usuario in usuarios) {
      if (usuario['id_usr'] == administrador['id_usr']) {
        perfil = usuario;
        break;
      }
    }

    return ListView(
      padding: const EdgeInsets.all(20),

      children: [
        const SizedBox(height: 20),

        const CircleAvatar(
          radius: 50,
          backgroundColor: Color(0xFF08245C),

          child: Icon(Icons.person, size: 65, color: Colors.white),
        ),

        const SizedBox(height: 15),

        Text(
          perfil['nom_usr'] ?? 'Administrador',
          textAlign: TextAlign.center,

          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        Text(perfil['mail'] ?? '', textAlign: TextAlign.center),

        const SizedBox(height: 10),

        const Text('Administrador', textAlign: TextAlign.center),

        const SizedBox(height: 30),

        ListTile(
          leading: const Icon(Icons.edit_outlined),
          title: const Text('Editar perfil'),
          trailing: const Icon(Icons.chevron_right),

          onTap: () => formularioUsuario(perfil),
        ),

        const Divider(),

        ListTile(
          leading: const Icon(Icons.refresh),
          title: const Text('Actualizar información'),
          trailing: const Icon(Icons.chevron_right),

          onTap: cargarDatos,
        ),

        const Divider(),

        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),

          title: const Text(
            'Cerrar sesión',
            style: TextStyle(color: Colors.red),
          ),

          onTap: cerrarSesion,
        ),
      ],
    );
  }

  // =====================================
  // MENÚ LATERAL
  // =====================================

  Widget menuLateral() {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF08245C)),

            accountName: Text(administrador['nom_usr'] ?? 'Administrador'),

            accountEmail: Text(administrador['mail'] ?? ''),

            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,

              child: Icon(
                Icons.movie_creation_outlined,
                color: Color(0xFF08245C),
                size: 40,
              ),
            ),
          ),

          for (int i = 0; i < titulos.length; i++)
            ListTile(
              leading: Icon(iconos[i]),
              title: Text(titulos[i]),
              selected: pagina == i,

              onTap: () {
                Navigator.pop(context);
                cambiarPagina(i);
              },
            ),

          const Spacer(),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),

            title: const Text('Cerrar sesión'),

            onTap: () {
              Navigator.pop(context);
              cerrarSesion();
            },
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // =====================================
  // MOSTRAR PANTALLA
  // =====================================

  Widget contenido() {
    if (cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 55),

              const SizedBox(height: 15),

              Text(error!, textAlign: TextAlign.center),

              const SizedBox(height: 15),

              if (servicio != null)
                FilledButton(
                  onPressed: cargarDatos,
                  child: const Text('Reintentar'),
                ),

              TextButton(
                onPressed: cerrarSesion,
                child: const Text('Volver al login'),
              ),
            ],
          ),
        ),
      );
    }

    switch (pagina) {
      case 1:
        return pantallaPeliculas();

      case 2:
        return pantallaUsuarios();

      case 3:
        return pantallaResenas();

      case 4:
        return configuracion();

      default:
        return inicio();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF08245C)),

        scaffoldBackgroundColor: const Color(0xFFF5F5F5),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF08245C),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),

      child: Scaffold(
        appBar: AppBar(
          title: Text(pagina == 0 ? 'World of Movies' : titulos[pagina]),

          actions: [
            IconButton(
              tooltip: 'Actualizar',
              onPressed: cargando ? null : cargarDatos,
              icon: const Icon(Icons.refresh),
            ),

            IconButton(
              tooltip: 'Mi perfil',
              onPressed: () => cambiarPagina(4),
              icon: const Icon(Icons.account_circle_outlined),
            ),
          ],
        ),

        drawer: servicio != null ? menuLateral() : null,

        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),

            child: contenido(),
          ),
        ),

        floatingActionButton:
            !cargando && error == null && (pagina == 1 || pagina == 2)
            ? FloatingActionButton(
                backgroundColor: const Color(0xFF08245C),

                foregroundColor: Colors.white,

                onPressed: () {
                  if (pagina == 1) {
                    formularioPelicula();
                  } else {
                    formularioUsuario();
                  }
                },

                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }
}
