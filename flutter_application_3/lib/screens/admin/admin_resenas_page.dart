/// Archivo: admin_resenas_page.dart.
/// Presenta reseñas, identifica sus autores y permite moderar su publicación.

// World of Movies: Listado de reseñas, identificación de registros y moderación.
// part of permite compartir imports y el estado de la pantalla principal.
part of '../admin_dashboard_page.dart';

// Este mixin aporta funciones al mismo estado; no crea otra pantalla independiente.
mixin _AdminResenas on _AdminDashboardBase {
  // =====================================
  // OBTENER NOMBRES PARA LAS RESEÑAS
  // =====================================

  // Busca el título de una película a partir de su identificador.
  /// Busca el título asociado a una película y usa un texto alternativo si falta.
  String nombrePelicula(dynamic id) {
    // Recorre la lista de películas cargadas.
    for (final pelicula in peliculas) {
      // Comprueba si coincide el identificador.
      if (pelicula['id_blog'] == id) {
        // Devuelve el título encontrado o un texto alternativo.
        return pelicula['titulo']?.toString() ?? 'Película';
      }
    }

    // Si no existe una coincidencia, muestra el identificador.
    return 'Película #$id';
  }

  // Busca el nombre de un usuario a partir de su identificador.
  /// Busca el nombre asociado a una cuenta y usa un texto alternativo si falta.
  String nombreUsuario(dynamic id) {
    // Recorre la lista de usuarios cargados.
    for (final usuario in usuarios) {
      // Comprueba si coincide el identificador.
      if (usuario['id_usr'] == id) {
        // Devuelve el nombre encontrado o un texto alternativo.
        return usuario['nom_usr']?.toString() ?? 'Usuario';
      }
    }

    // Si no existe coincidencia, muestra el identificador.
    return 'Usuario #$id';
  }

  // =====================================
  // MODERACIÓN DE RESEÑAS
  // =====================================

  // Construye el listado de reseñas y sus opciones de moderación.
  /// Construye la lista de reseñas y las acciones de moderación.
  @override
  Widget pantallaResenas() {
    // Filtra las reseñas según los datos buscados.
    final lista = resenas.where((r) {
      // Combina película, usuario y comentario para permitir su búsqueda.
      final texto =
          // Incluye el nombre de la película en la búsqueda.
          '${nombrePelicula(r['blog_id'])} '
          // Incluye el nombre del usuario en la búsqueda.
          '${nombreUsuario(r['usr_id'])} '
          // Incluye el texto del comentario en la búsqueda.
          '${r['comentario']}';

      // Compara la búsqueda sin distinguir mayúsculas.
      return texto.toLowerCase().contains(busqueda.toLowerCase());
      // Convierte las reseñas filtradas en una lista.
    }).toList();

    // La moderación separa las reseñas normales de la bandeja de reportes.
    return Column(
      children: [
        _selectorModeracion(),
        Expanded(
          child: mostrarReportes
              ? _listaReportes()
              : Column(
                  children: [
                    buscador('Buscar reseña...'),
                    Expanded(
                      child: lista.isEmpty
                          ? const Center(child: Text('No hay reseñas'))
                          : ListView.builder(
                              // Número de registros que tendrá la lista.
                              itemCount: lista.length,

                              // Construye cada fila utilizando su índice.
                              itemBuilder: (context, index) {
                                // Obtiene la reseña correspondiente a la posición.
                                final resena = lista[index];

                                // Interpreta estatus 1 como reseña aprobada.
                                final aprobada = resena['estatus'] == 1;

                                // Crea el componente Card de la interfaz.
                                return Card(
                                  // Define el espacio exterior del elemento.
                                  margin: const EdgeInsets.symmetric(
                                    // Espacio horizontal.
                                    horizontal: 15,
                                    // Espacio vertical.
                                    vertical: 6,
                                  ),

                                  // Contiene el widget hijo.
                                  child: ListTile(
                                    // Contenido situado al inicio de la fila.
                                    leading: const CircleAvatar(
                                      child: Icon(Icons.person),
                                    ),

                                    // Define el título visible.
                                    title: Text(
                                      // Muestra el nombre de la película asociada.
                                      nombrePelicula(resena['blog_id']),
                                      // Configura la apariencia del texto.
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    // Contenido secundario debajo del título.
                                    subtitle: Column(
                                      // Alinea los hijos en el eje transversal.
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      // Lista de widgets que componen esta sección.
                                      children: [
                                        // Crea el componente Text de la interfaz.
                                        Text(nombreUsuario(resena['usr_id'])),

                                        // Añade un espacio fijo entre los componentes.
                                        const SizedBox(height: 5),

                                        // Muestra la calificación individual de la reseña.
                                        estrellas(resena['calificacion']),

                                        // Añade un espacio fijo entre los componentes.
                                        const SizedBox(height: 5),

                                        // Conserva el espacio adicional que tenía el diseño original.
                                        const SizedBox(height: 5),

                                        // Crea el componente Text de la interfaz.
                                        Text(resena['comentario'] ?? ''),

                                        // Añade un espacio fijo entre los componentes.
                                        const SizedBox(height: 4),

                                        // Crea el componente Text de la interfaz.
                                        Text(
                                          // Muestra el estado actual de la reseña.
                                          aprobada ? 'Aprobada' : 'Oculta',
                                          // Configura la apariencia del texto.
                                          style: TextStyle(
                                            // Define el grosor del texto.
                                            fontWeight: FontWeight.bold,
                                            // Establece el color del elemento.
                                            color: aprobada
                                                ? Colors.green
                                                : Colors.orange,
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Acciones o contenido situado al final de la fila.
                                    trailing: Row(
                                      // Controla cuánto espacio ocupa el widget en su eje principal.
                                      mainAxisSize: MainAxisSize.min,

                                      // Lista de widgets que componen esta sección.
                                      children: [
                                        // Crea el componente IconButton de la interfaz.
                                        IconButton(
                                          // Texto de ayuda de la acción.
                                          tooltip: aprobada
                                              ? 'Ocultar'
                                              : 'Aprobar',

                                          // Icono que representa la acción.
                                          icon: Icon(
                                            // Selecciona el icono según el estado de la reseña.
                                            aprobada
                                                // Valor que se utiliza cuando la condición es verdadera.
                                                ? Icons.visibility_off
                                                // Valor alternativo cuando la condición es falsa.
                                                : Icons.check_circle,

                                            // Establece el color del elemento.
                                            color: Colors.green,
                                          ),

                                          // Define qué sucede al pulsar el botón.
                                          onPressed: () async {
                                            // Ejecuta la acción remota y actualiza la información del panel.
                                            await ejecutarOperacion(
                                              // Envía el cambio de estado de la reseña por su identificador.
                                              () => servicio!.moderarResena(
                                                // Identificador del comentario que se actualizará.
                                                resena['id_com'],
                                                // Cambia de aprobada a oculta (0), o de oculta a aprobada (1).
                                                aprobada ? 0 : 1,
                                              ),
                                              // Mensaje de éxito de moderación.
                                              'Reseña actualizada',
                                            );
                                          },
                                        ),

                                        // Crea el componente IconButton de la interfaz.
                                        IconButton(
                                          // Texto de ayuda de la acción.
                                          tooltip: 'Eliminar',

                                          // Icono que representa la acción.
                                          icon: const Icon(
                                            // Selecciona el icono visual indicado.
                                            Icons.delete_outline,
                                            // Establece el color del elemento.
                                            color: Colors.red,
                                          ),

                                          // Define qué sucede al pulsar el botón.
                                          onPressed: () async {
                                            // Comprueba esta condición antes de ejecutar el siguiente bloque.
                                            if (await confirmar(
                                              '¿Eliminar esta reseña?',
                                            )) {
                                              // Ejecuta la acción remota y actualiza la información del panel.
                                              await ejecutarOperacion(
                                                // Solicita eliminar la reseña por su identificador.
                                                () => servicio!.eliminarResena(
                                                  // Identificador del comentario que se eliminará.
                                                  resena['id_com'],
                                                ),
                                                // Mensaje de éxito de eliminación de la reseña.
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
                ),
        ),
      ],
    );
  }

  /// Selector para alternar entre moderación general y reportes recibidos.
  Widget _selectorModeracion() {
    final pendientes = reportes
        .where((reporte) => reporte['estatus'] == 'pendiente')
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.tonalIcon(
              style: FilledButton.styleFrom(
                backgroundColor: mostrarReportes
                    ? null
                    : const Color(0xFFDCE8FA),
              ),
              onPressed: () {
                setState(() {
                  mostrarReportes = false;
                  busqueda = '';
                });
              },
              icon: const Icon(Icons.rate_review_outlined),
              label: Text('Reseñas (${resenas.length})'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FilledButton.tonalIcon(
              style: FilledButton.styleFrom(
                backgroundColor: mostrarReportes
                    ? const Color(0xFFFFE3E0)
                    : null,
                foregroundColor: mostrarReportes
                    ? const Color(0xFF9B1C1C)
                    : null,
              ),
              onPressed: () {
                setState(() {
                  mostrarReportes = true;
                  busqueda = '';
                });
              },
              icon: const Icon(Icons.flag_outlined),
              label: Text('Reportes ($pendientes)'),
            ),
          ),
        ],
      ),
    );
  }

  /// Muestra reportes pendientes y atendidos con acciones de moderación.
  Widget _listaReportes() {
    final lista = reportes.where((reporte) {
      final texto =
          '${reporte['titulo_pelicula']} '
          '${reporte['autor_resena']} ${reporte['reportado_por']} '
          '${reporte['comentario']}';
      return texto.toLowerCase().contains(busqueda.toLowerCase());
    }).toList();

    return Column(
      children: [
        buscador('Buscar reporte...'),
        Expanded(
          child: lista.isEmpty
              ? const Center(child: Text('No hay reportes'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: lista.length,
                  itemBuilder: (context, index) {
                    final reporte = lista[index];
                    final pendiente = reporte['estatus'] == 'pendiente';
                    final estado = switch (reporte['estatus']) {
                      'resuelto' => 'Resuelto',
                      'descartado' => 'Descartado',
                      _ => 'Pendiente',
                    };

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    reporte['titulo_pelicula']?.toString() ??
                                        'Película',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Chip(
                                  avatar: Icon(
                                    pendiente
                                        ? Icons.pending_outlined
                                        : Icons.check_circle_outline,
                                    size: 18,
                                  ),
                                  label: Text(estado),
                                ),
                              ],
                            ),
                            Text(
                              'Reseña de ${reporte['autor_resena']} · '
                              'Reportada por ${reporte['reportado_por']}',
                            ),
                            const SizedBox(height: 8),
                            estrellas(reporte['calificacion']),
                            const SizedBox(height: 6),
                            Text(
                              reporte['comentario']?.toString().isNotEmpty ==
                                      true
                                  ? reporte['comentario'].toString()
                                  : 'La reseña no incluye comentario.',
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Fecha del reporte: '
                              '${reporte['fecha_reporte']?.toString() ?? 'Sin fecha'}',
                              style: const TextStyle(color: Colors.black54),
                            ),
                            if (pendiente) ...[
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () => ejecutarOperacion(
                                      () => servicio!.atenderReporte(
                                        id: reporte['id_reporte'] as int,
                                        estatus: 'descartado',
                                      ),
                                      'Reporte descartado; la reseña se conserva',
                                    ),
                                    icon: const Icon(Icons.check),
                                    label: const Text('Conservar reseña'),
                                  ),
                                  FilledButton.tonalIcon(
                                    onPressed: () => ejecutarOperacion(
                                      () => servicio!.atenderReporte(
                                        id: reporte['id_reporte'] as int,
                                        estatus: 'resuelto',
                                        ocultarResena: true,
                                      ),
                                      'Reseña ocultada y reporte atendido',
                                    ),
                                    icon: const Icon(Icons.visibility_off),
                                    label: const Text('Ocultar reseña'),
                                  ),
                                  IconButton(
                                    tooltip: 'Eliminar reseña',
                                    color: Colors.red,
                                    onPressed: () async {
                                      if (await confirmar(
                                        '¿Eliminar esta reseña? El reporte asociado también se quitará.',
                                      )) {
                                        await ejecutarOperacion(
                                          () => servicio!.eliminarResena(
                                            reporte['id_com'] as int,
                                          ),
                                          'Reseña eliminada',
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                ],
                              ),
                            ],
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
}
