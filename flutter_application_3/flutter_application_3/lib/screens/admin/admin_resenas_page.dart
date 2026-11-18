// World of Movies: Listado de reseñas, identificación de registros y moderación.
// part of permite compartir imports y el estado de la pantalla principal.
part of '../admin_dashboard_page.dart';

// Este mixin aporta funciones al mismo estado; no crea otra pantalla independiente.
mixin _AdminResenas on _AdminDashboardBase {
  // =====================================
  // OBTENER NOMBRES PARA LAS RESEÑAS
  // =====================================

  // Busca el título de una película a partir de su identificador.
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

    // Crea el componente Column de la interfaz.
    return Column(
      // Lista de widgets que componen esta sección.
      children: [
        // Inserta el buscador de reseñas.
        buscador('Buscar reseña...'),

        // Crea el componente Expanded de la interfaz.
        Expanded(
          // Contiene el widget hijo.
          child: lista.isEmpty
              // Valor que se utiliza cuando la condición es verdadera.
              ? const Center(child: Text('No hay reseñas'))
              // Valor alternativo cuando la condición es falsa.
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
                        leading: const CircleAvatar(child: Icon(Icons.person)),

                        // Define el título visible.
                        title: Text(
                          // Muestra el nombre de la película asociada.
                          nombrePelicula(resena['blog_id']),
                          // Configura la apariencia del texto.
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        // Contenido secundario debajo del título.
                        subtitle: Column(
                          // Alinea los hijos en el eje transversal.
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                color: aprobada ? Colors.green : Colors.orange,
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
                              tooltip: aprobada ? 'Ocultar' : 'Aprobar',

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
                                if (await confirmar('¿Eliminar esta reseña?')) {
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
    );
  }

}