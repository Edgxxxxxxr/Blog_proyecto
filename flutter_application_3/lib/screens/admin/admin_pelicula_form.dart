// World of Movies: Formulario, selección de imagen, año, duración y guardado.
// part of permite compartir imports y el estado de la pantalla principal.
part of '../admin_dashboard_page.dart';

// Este mixin aporta funciones al mismo estado; no crea otra pantalla independiente.
mixin _AdminPeliculaForm on _AdminDashboardBase {
  // Separa el año y la duración almacenados juntos en tags.
  Map<String, String> separarTags(dynamic valor) {
    // Convierte el valor a texto; si es nulo, utiliza una cadena vacía.
    final texto = valor?.toString() ?? '';

    // Busca el patrón Año: 0000 | Duración: ... mediante una expresión regular.
    final coincidencia = RegExp(r'(?:^| \| )Año: (\d{4}) \| Duración: (.+)$')
        // Obtiene la primera coincidencia encontrada en el texto.
        .firstMatch(texto);

    // Comprueba si los tags no tienen el formato esperado.
    if (coincidencia == null) {
      // Devuelve ambos datos vacíos para publicaciones sin ese formato.
      return {'año': '', 'duración': ''};
    }

    // Construye el mapa con los datos extraídos.
    return {
      // El primer grupo de la expresión regular contiene el año.
      'año': coincidencia.group(1) ?? '',
      // El segundo grupo contiene la duración.
      'duración': coincidencia.group(2) ?? '',
    };
  }

  // =====================================
  // FORMULARIO DE PELÍCULAS
  // =====================================

  // Abre el formulario para agregar o editar una película.
  @override
  Future<void> formularioPelicula([Map<String, dynamic>? pelicula]) async {
    // Distingue entre creación y edición según exista un registro.
    final editando = pelicula != null;

    // Extrae año y duración de los tags existentes.
    final datosTags = separarTags(pelicula?['tags']);

    // Crea el controlador del título con su valor previo, si existe.
    final titulo = TextEditingController(
      // Carga el título anterior o utiliza una cadena vacía.
      text: pelicula?['titulo']?.toString() ?? '',
    );


    // Crea el controlador del año con el dato recuperado.
    final anio = TextEditingController(text: datosTags['año']);

    // Crea el controlador de la duración con el dato recuperado.
    final duracion = TextEditingController(text: datosTags['duración']);

    // Crea el controlador de la sinopsis.
    final sinopsis = TextEditingController(
      // Carga la descripción anterior o utiliza texto vacío.
      text: pelicula?['descripcion']?.toString() ?? '',
    );

    // Conserva la ruta de la imagen previamente guardada.
    String? imagenActual = pelicula?['img']?.toString();

    // Guarda los bytes de la nueva imagen seleccionada.
    Uint8List? imagenBytes;
    // Guarda el nombre original del archivo seleccionado.
    String? nombreImagen;
    // Guarda un error de selección de imagen, si ocurre.
    String? errorImagen;

    // Indica si el selector está trabajando.
    bool seleccionando = false;

    // Clave que permite ejecutar las validaciones del formulario.
    final formulario = GlobalKey<FormState>();

    // Crea una ruta de diálogo para esperar también su animación de cierre.
    final ruta = DialogRoute<Map<String, dynamic>>(
      // Contexto que se utiliza para construir o navegar entre widgets.
      context: context,
      // Controla si un toque fuera del diálogo permite cerrarlo.
      barrierDismissible: false,

      // Función que construye el contenido cuando Flutter lo necesita.
      builder: (dialogContext) {
        // Permite actualizar solamente el contenido del diálogo.
        return StatefulBuilder(
          // Función que construye el contenido cuando Flutter lo necesita.
          builder: (context, cambiarEstado) {
            // Crea el componente AlertDialog de la interfaz.
            return AlertDialog(
              // Define el título visible.
              title: Text(editando ? 'Editar película' : 'Agregar película'),

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
                        // ====================
                        // IMAGEN DE LA PELÍCULA
                        // ====================

                        // Crea el componente GestureDetector de la interfaz.
                        GestureDetector(
                          // Define qué sucede al tocar el elemento.
                          onTap: seleccionando
                              // Valor que se utiliza cuando la condición es verdadera.
                              ? null
                              // Valor alternativo cuando la condición es falsa.
                              : () async {
                                  // Actualiza solo el estado interno del diálogo.
                                  cambiarEstado(() {
                                    // Indica que se está seleccionando una imagen.
                                    seleccionando = true;
                                    // Limpia el mensaje de error de una selección anterior.
                                    errorImagen = null;
                                  });

                                  // Inicia un bloque de instrucciones que pueden producir un error.
                                  try {
                                    // Crea el selector de imágenes.
                                    final picker = ImagePicker();

                                    // Abre la galería y espera que el usuario seleccione un archivo.
                                    final archivo = await picker.pickImage(
                                      // Solicita una imagen de la galería (selector de archivos en web).
                                      source: ImageSource.gallery,
                                      // Solicita calidad de imagen 85 al selector.
                                      imageQuality: 85,
                                    );

                                    // Si se cancela la selección, no cambia la imagen.
                                    if (archivo == null) return;

                                    // Lee el contenido del archivo en memoria.
                                    final bytes = await archivo.readAsBytes();

                                    // Comprueba que el widget sigue montado antes de utilizar su contexto.
                                    if (!dialogContext.mounted) {
                                      // Termina la función sin continuar.
                                      return;
                                    }

                                    // Rechaza archivos vacíos o superiores al límite indicado.
                                    if (bytes.isEmpty ||
                                        // Compara la cantidad de bytes con 5 MiB.
                                        bytes.length > 5 * 1024 * 1024) {
                                      // Actualiza solo el estado interno del diálogo.
                                      cambiarEstado(() {
                                        // Establece el mensaje por tamaño de imagen inválido.
                                        errorImagen = 'Selecciona una imagen menor a 5 MB';
                                      });

                                      // Termina la función sin continuar.
                                      return;
                                    }

                                    // Obtiene la extensión del nombre del archivo.
                                    final extension = archivo.name
                                        // Separa el nombre por puntos.
                                        .split('.')
                                        // Toma la última parte del nombre.
                                        .last
                                        // Normaliza la extensión a minúsculas.
                                        .toLowerCase();

                                    // Comprueba que la extensión pertenezca a los formatos admitidos.
                                    if (![
                                      // Admite archivos JPG.
                                      'jpg',
                                      // Admite archivos JPEG.
                                      'jpeg',
                                      // Admite archivos PNG.
                                      'png',
                                      // Admite archivos WebP.
                                      'webp',
                                    // Comprueba la extensión contra los formatos autorizados.
                                    ].contains(extension)) {
                                      // Actualiza solo el estado interno del diálogo.
                                      cambiarEstado(() {
                                        // Guarda el error de formato de imagen.
                                        errorImagen =
                                            // Texto que informa de los formatos aceptados.
                                            'Selecciona JPG, PNG o WebP';
                                      });
                                      // Termina la función sin continuar.
                                      return;
                                    }

                                    // Actualiza solo el estado interno del diálogo.
                                    cambiarEstado(() {
                                      // Conserva los bytes para la vista previa y la subida posterior.
                                      imagenBytes = bytes;
                                      // Conserva el nombre para enviarlo a la API.
                                      nombreImagen = archivo.name;
                                    });
                                  // Captura una excepción para gestionar el error.
                                  } catch (e) {
                                    // Comprueba que el widget sigue montado antes de utilizar su contexto.
                                    if (!dialogContext.mounted) {
                                      // Termina la función sin continuar.
                                      return;
                                    }

                                    // Actualiza solo el estado interno del diálogo.
                                    cambiarEstado(() {
                                      // Guarda el mensaje de error al fallar el selector.
                                      errorImagen =
                                          // Texto que se muestra si falla la selección.
                                          'No se pudo seleccionar la imagen';
                                    });
                                  // Ejecuta esta sección al terminar, incluso si hubo una excepción.
                                  } finally {
                                    // Comprueba que el widget permanece montado.
                                    if (dialogContext.mounted) {
                                      // Actualiza solo el estado interno del diálogo.
                                      cambiarEstado(() {
                                        // Reactiva los controles cuando acaba la selección.
                                        seleccionando = false;
                                      });
                                    }
                                  }
                                },

                          // Contiene el widget hijo.
                          child: Container(
                            // Define la altura o el espacio vertical.
                            height: 155,
                            // Define el ancho del elemento.
                            width: 155,

                            // Configura la apariencia visual del elemento.
                            decoration: BoxDecoration(
                              // Establece el color del elemento.
                              color: Colors.grey.shade100,

                              // Redondea las esquinas.
                              borderRadius: BorderRadius.circular(12),

                              // Define el borde del componente.
                              border: Border.all(color: Colors.grey),
                            ),

                            // Contiene el widget hijo.
                            child: Stack(
                              // Centra los elementos superpuestos dentro del contenedor.
                              alignment: Alignment.center,

                              // Lista de widgets que componen esta sección.
                              children: [
                                // Si se eligió una imagen nueva, la muestra en memoria.
                                if (imagenBytes != null)
                                  // Crea el componente ClipRRect de la interfaz.
                                  ClipRRect(
                                    // Redondea las esquinas.
                                    borderRadius: BorderRadius.circular(12),

                                    // Contiene el widget hijo.
                                    child: Image.memory(
                                      // Usa los bytes no nulos de la imagen seleccionada.
                                      imagenBytes!,
                                      // Define el ancho del elemento.
                                      width: 155,
                                      // Define la altura o el espacio vertical.
                                      height: 155,
                                      // Controla cómo se ajusta la imagen al espacio disponible.
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                // Si no hay imagen nueva, verifica si hay una imagen existente.
                                else if (imagenActual != null &&
                                    // Comprueba que la ruta existente no esté vacía.
                                    imagenActual.isNotEmpty)
                                  // Muestra la imagen que ya estaba guardada.
                                  fotoPelicula(imagenActual)
                                // Alternativa cuando no se cumple la condición anterior.
                                else
                                  // Crea el componente Icon de la interfaz.
                                  const Icon(
                                    // Selecciona el icono visual indicado.
                                    Icons.image_outlined,
                                    // Establece el color del elemento.
                                    color: Colors.grey,
                                    // Define el tamaño del icono.
                                    size: 75,
                                  ),

                                // Mientras se abre o lee la imagen, muestra un indicador.
                                if (seleccionando)
                                  // Crea el componente CircularProgressIndicator de la interfaz.
                                  const CircularProgressIndicator(),

                                // Crea el componente Positioned de la interfaz.
                                Positioned(
                                  // Distancia desde el borde inferior.
                                  bottom: 5,
                                  // Distancia desde el borde derecho.
                                  right: 5,

                                  // Contiene el widget hijo.
                                  child: Container(
                                    // Define el espacio interior del elemento.
                                    padding: const EdgeInsets.all(8),

                                    // Configura la apariencia visual del elemento.
                                    decoration: const BoxDecoration(
                                      // Establece el color del elemento.
                                      color: Color(0xFF08245C),
                                      // Define la forma del elemento.
                                      shape: BoxShape.circle,
                                    ),

                                    // Contiene el widget hijo.
                                    child: const Icon(
                                      // Selecciona el icono visual indicado.
                                      Icons.camera_alt,
                                      // Establece el color del elemento.
                                      color: Colors.white,
                                      // Define el tamaño del icono.
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Añade un espacio fijo entre los componentes.
                        const SizedBox(height: 8),

                        // Crea el componente Text de la interfaz.
                        Text(
                          // Muestra el nombre del archivo o las instrucciones para seleccionarlo.
                          nombreImagen ?? 'Toca para seleccionar imagen',

                          // Alinea el texto dentro de su espacio.
                          textAlign: TextAlign.center,

                          // Configura la apariencia del texto.
                          style: const TextStyle(fontSize: 13),
                        ),

                        // Comprueba esta condición antes de ejecutar el siguiente bloque.
                        if (errorImagen != null)
                          // Crea el componente Padding de la interfaz.
                          Padding(
                            // Define el espacio interior del elemento.
                            padding: const EdgeInsets.all(8),

                            // Contiene el widget hijo.
                            child: Text(
                              // Muestra el mensaje de error de imagen no nulo.
                              errorImagen!,
                              // Configura la apariencia del texto.
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),

                        // Añade un espacio fijo entre los componentes.
                        const SizedBox(height: 20),

                        // TÍTULO
                        // Crea un campo de formulario con las opciones indicadas.
                        campo(titulo, 'Título', minimo: 2, maximo: 200),

                        // GÉNERO

                        // AÑO DE ESTRENO
                        // Crea el componente TextFormField de la interfaz.
                        TextFormField(
                          // Vincula el campo con su controlador de texto.
                          controller: anio,
                          // Indica el tipo de teclado que se solicita.
                          keyboardType: TextInputType.number,

                          // Limita el número de caracteres del campo.
                          maxLength: 4,

                          // Configura la apariencia visual del elemento.
                          decoration: const InputDecoration(
                            // Etiqueta visible del campo.
                            labelText: 'Año de estreno',
                            // Define el borde del componente.
                            border: OutlineInputBorder(),
                          ),

                          // Valida el año introducido antes de guardar.
                          validator: (valor) {
                            // Intenta convertir el texto a un número entero.
                            final numero = int.tryParse(valor?.trim() ?? '');

                            // Rechaza un valor que no pueda convertirse a entero.
                            if (numero == null ||
                                // No admite años anteriores a 1888.
                                numero < 1888 ||
                                // Limita el año al actual más cinco años.
                                numero > DateTime.now().year + 5) {
                              // Informa que el año está fuera de los valores aceptados.
                              return 'Ingresa un año válido';
                            }

                            // Devuelve null cuando no hay error o no existe un resultado.
                            return null;
                          },
                        ),

                        // Añade un espacio fijo entre los componentes.
                        const SizedBox(height: 12),

                        // DURACIÓN
                        // Crea un campo de formulario con las opciones indicadas.
                        campo(
                          // Vincula el controlador de la duración.
                          duracion,
                          // Etiqueta con un ejemplo del formato de duración.
                          'Duración (ej. 2 h 10 min)',
                          // Longitud máxima aceptada.
                          maximo: 60,
                        ),

                        // SINOPSIS
                        // Crea un campo de formulario con las opciones indicadas.
                        campo(sinopsis, 'Sinopsis', lineas: 4, maximo: 500),
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
                  onPressed: seleccionando
                      // Valor que se utiliza cuando la condición es verdadera.
                      ? null
                      // Valor alternativo cuando la condición es falsa.
                      : () {
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
                  onPressed: seleccionando
                      // Valor que se utiliza cuando la condición es verdadera.
                      ? null
                      // Valor alternativo cuando la condición es falsa.
                      : () {
                          // Ejecuta todas las validaciones antes de cerrar el formulario.
                          if (!formulario.currentState!.validate()) {
                            // Termina la función sin continuar.
                            return;
                          }

                          // Compone el texto que se guardará en la columna tags.
                          final tags =
                              // Incluye el año de estreno, sin espacios exteriores.
                              'Año: ${anio.text.trim()} | '
                              // Añade la duración en el formato acordado.
                              'Duración: ${duracion.text.trim()}';

                          // Verifica que tags no supere los 255 caracteres.
                          if (tags.length > 255) {
                            // Muestra el mensaje correspondiente al resultado.
                            aviso('El año y duración son demasiado largos');
                            // Termina la función sin continuar.
                            return;
                          }

                          // Prepara el mapa JSON para crear o actualizar la película.
                          final datos = <String, dynamic>{
                            // Incluye el título en la clave esperada por la API.
                            'titulo': titulo.text.trim(),
                            // Envía la sinopsis como descripcion.
                            'descripcion': sinopsis.text.trim(),
                            // Incluye año y duración en tags.
                            'tags': tags,
                            // Mantiene la ruta de la imagen existente mientras no se suba otra.
                            'img': imagenActual,
                          };

                          // Quita el foco del campo de texto antes de cerrar.
                          FocusScope.of(dialogContext).unfocus();

                          // Cierra el diálogo y devuelve los datos preparados.
                          Navigator.of(dialogContext).pop(datos);
                        },

                  // Contiene el widget hijo.
                  child: Text(editando ? 'Actualizar' : 'Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    // Abrir el formulario
    // Abre el diálogo en el navegador raíz y espera su resultado.
    final datos = await Navigator.of(context, rootNavigator: true).push(ruta);

    // Esperar a que termine la animación
    // Espera que termine por completo el cierre de la ruta.
    await ruta.completed;

    // Liberar los controladores
    // Libera el controlador del título.
    titulo.dispose();
    // Libera el controlador del año.
    anio.dispose();
    // Libera el controlador de la duración.
    duracion.dispose();
    // Libera el controlador de la sinopsis.
    sinopsis.dispose();

    // Si se canceló o se desmontó la pantalla, no guarda.
    if (datos == null || !mounted) return;

    // =====================================
    // GUARDAR EN FASTAPI Y MYSQL
    // =====================================

    // Ejecuta la acción remota y actualiza la información del panel.
    await ejecutarOperacion(
      // Define la función asíncrona que se ejecutará para guardar.
      () async {
        // Subir una imagen nueva si se seleccionó
        // Solo sube una imagen cuando se seleccionaron bytes y nombre.
        if (imagenBytes != null && nombreImagen != null) {
          // Envía la imagen al servidor y recibe su ruta.
          final rutaImagen = await servicio!.subirImagen(
            // Envía los bytes de la imagen nueva.
            bytes: imagenBytes!,
            // Envía el nombre del archivo nuevo.
            nombre: nombreImagen!,
          );

          // Reemplaza la ruta anterior por la nueva.
          datos['img'] = rutaImagen;
        }

        // Actualizar película
        // Comprueba que existe un registro para editar.
        if (pelicula != null) {
          // Actualiza la película por su id_blog mediante FastAPI.
          await servicio!.editarPelicula(pelicula['id_blog'], datos);
        // Alternativa cuando no se cumple la condición anterior.
        } else {
          // Registrar película nueva
          // Crea una película mediante FastAPI.
          await servicio!.agregarPelicula(datos);
        }
      },

      // El mensaje de éxito depende de si se está editando.
      editando
          // Valor que se utiliza cuando la condición es verdadera.
          ? 'Película actualizada correctamente'
          // Valor alternativo cuando la condición es falsa.
          : 'Película agregada correctamente',
    );
  }

}
