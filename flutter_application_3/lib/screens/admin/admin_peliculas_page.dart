// World of Movies: Listado, búsqueda, promedio y operaciones de películas.
// part of permite compartir imports y el estado de la pantalla principal.
part of '../admin_dashboard_page.dart';

// Este mixin aporta funciones al mismo estado; no crea otra pantalla independiente.
mixin _AdminPeliculas on _AdminDashboardBase {
  // =====================================
  // PROMEDIO DE CALIFICACIONES
  // =====================================

  // Calcula el promedio de las calificaciones aprobadas de una película.
  double? promedioPelicula(dynamic idPelicula) {
    // Parte de las reseñas descargadas desde la API.
    final calificaciones = resenas
        // Filtra las reseñas que cumplen las condiciones.
        .where((resena) {
          // Obtiene el valor de la calificación de cada reseña.
          final valor = resena['calificacion'];

          // Considera únicamente reseñas de la película consultada.
          return resena['blog_id'] == idPelicula &&
              // Exige que la reseña tenga estatus 1 (aprobada).
              resena['estatus'] == 1 &&
              // Comprueba que la calificación sea numérica.
              valor is num &&
              // Verifica el límite inferior de 1 estrella.
              valor >= 1 &&
              // Verifica el límite superior de 5 estrellas.
              valor <= 5;
        })
        // Convierte cada calificación válida a double.
        .map((resena) => (resena['calificacion'] as num).toDouble())
        // Materializa los valores filtrados en una lista.
        .toList();

    // Comprueba si no existen calificaciones válidas.
    if (calificaciones.isEmpty) {
      // Devuelve null para representar ausencia de calificación.
      return null;
    }

    // Suma las calificaciones de la lista.
    final suma = calificaciones.reduce((a, b) => a + b);

    // Divide la suma entre la cantidad de calificaciones.
    return suma / calificaciones.length;
  }

  // =====================================
  // LISTADO DE PELÍCULAS
  // =====================================

  // Construye el listado de películas con búsqueda y acciones.
  @override
  Widget pantallaPeliculas() {
    // Filtra las películas según el texto del buscador.
    final lista = peliculas.where((p) {
      // Busca conjuntamente en el título y los tags sin distinguir mayúsculas.
      return '${p['titulo']} ${p['tags'] ?? ''}'.toLowerCase().contains(
        // Compara con el texto buscado en minúsculas.
        busqueda.toLowerCase(),
      );
    // Convierte las películas filtradas en una lista.
    }).toList();

    // Crea el componente Column de la interfaz.
    return Column(
      // Lista de widgets que componen esta sección.
      children: [
        // Inserta el buscador de películas.
        buscador('Buscar película...'),

        // Crea el componente Expanded de la interfaz.
        Expanded(
          // Contiene el widget hijo.
          child: lista.isEmpty
              // Valor que se utiliza cuando la condición es verdadera.
              ? const Center(child: Text('No hay películas'))
              // Valor alternativo cuando la condición es falsa.
              : ListView.builder(
                  // Número de registros que tendrá la lista.
                  itemCount: lista.length,

                  // Construye cada fila utilizando su índice.
                  itemBuilder: (context, index) {
                    // Obtiene la película correspondiente a esta posición.
                    final pelicula = lista[index];

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
                        // Define el espacio interior de la fila.
                        contentPadding: const EdgeInsets.all(12),

                        // Contenido situado al inicio de la fila.
                        leading: fotoPelicula(pelicula['img']),

                        // Define el título visible.
                        title: Text(
                          // Muestra el título de la película o texto vacío.
                          pelicula['titulo'] ?? '',
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
                            Text(pelicula['tags'] ?? 'Sin categoría'),

                            // Añade un espacio fijo entre los componentes.
                            const SizedBox(height: 5),

                            // Calcula y muestra su promedio de reseñas aprobadas.
                            estrellas(promedioPelicula(pelicula['id_blog'])),
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
                              tooltip: 'Editar',
                              // Icono que representa la acción.
                              icon: const Icon(Icons.edit),
                              // Abre el formulario con los datos de esta película.
                              onPressed: () => formularioPelicula(pelicula),
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
                                  // Texto de confirmación antes de eliminar la película.
                                  '¿Eliminar esta película?',
                                )) {
                                  // Ejecuta la acción remota y actualiza la información del panel.
                                  await ejecutarOperacion(
                                    // Solicita a FastAPI eliminar la película por su identificador.
                                    () => servicio!.eliminarPelicula(
                                      // Identificador de la película que se eliminará.
                                      pelicula['id_blog'],
                                    ),
                                    // Mensaje de éxito de eliminación.
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

}
