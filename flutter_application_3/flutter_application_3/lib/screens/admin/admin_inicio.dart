// World of Movies: Tarjetas y contadores de la pantalla inicial.
// part of permite compartir imports y el estado de la pantalla principal.
part of '../admin_dashboard_page.dart';

// Este mixin aporta funciones al mismo estado; no crea otra pantalla independiente.
mixin _AdminInicio on _AdminDashboardBase {
  // =====================================
  // DASHBOARD PRINCIPAL
  // =====================================

  // Construye la pantalla inicial con sus contadores.
  @override
  Widget inicio() {
    // Crea el componente ListView de la interfaz.
    return ListView(
      // Define el espacio interior del elemento.
      padding: const EdgeInsets.all(20),
      // Lista de widgets que componen esta sección.
      children: [
        // Crea el componente Text de la interfaz.
        Text(
          // Saluda al administrador utilizando el nombre del login.
          'Bienvenido, ${administrador['nom_usr'] ?? 'Administrador'}',
          // Configura la apariencia del texto.
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),

        // Añade un espacio fijo entre los componentes.
        const SizedBox(height: 8),

        // Crea el componente Text de la interfaz.
        const Text('Panel de administración de World of Movies'),

        // Añade un espacio fijo entre los componentes.
        const SizedBox(height: 25),

        // Crea una cuadrícula de tarjetas que se adapta al ancho.
        GridView.extent(
          // Limita el ancho aproximado de cada tarjeta.
          maxCrossAxisExtent: 280,
          // Mantiene la altura de las tarjetas en 170.
          mainAxisExtent: 170,
          // Ajusta la cuadrícula al tamaño de sus elementos.
          shrinkWrap: true,
          // Deja que la lista exterior gestione el desplazamiento.
          physics: const NeverScrollableScrollPhysics(),
          // Espacio entre filas de la cuadrícula.
          mainAxisSpacing: 15,
          // Espacio entre columnas de la cuadrícula.
          crossAxisSpacing: 15,

          // Lista de widgets que componen esta sección.
          children: [
            // Crea la tarjeta de películas.
            tarjetaInicio(
              // Etiqueta de la tarjeta de películas.
              'Películas',
              // Muestra la cantidad de películas de la lista cargada.
              peliculas.length.toString(),
              // Selecciona el icono visual indicado.
              Icons.movie_outlined,
              // Destino 1: sección de películas.
              1,
            ),

            // Crea la tarjeta de usuarios.
            tarjetaInicio(
              // Etiqueta de la tarjeta de usuarios.
              'Usuarios',
              // Muestra la cantidad de usuarios de la lista cargada.
              usuarios.length.toString(),
              // Selecciona el icono visual indicado.
              Icons.people_outline,
              // Destino 2: sección de usuarios.
              2,
            ),

            // Crea la tarjeta de reseñas.
            tarjetaInicio(
              // Etiqueta de la tarjeta de reseñas.
              'Reseñas',
              // Muestra la cantidad de reseñas de la lista cargada.
              resenas.length.toString(),
              // Selecciona el icono visual indicado.
              Icons.star_border,
              // Destino 3: sección de reseñas.
              3,
            ),

            // Crea la tarjeta de configuración sin contador, con destino 4.
            tarjetaInicio('Configuración', '', Icons.settings_outlined, 4),
          ],
        ),
      ],
    );
  }

  // Construye una tarjeta de acceso a una sección.
  Widget tarjetaInicio(
    // Recibe el título de la tarjeta.
    String titulo,
    // Recibe el contador que se mostrará.
    String cantidad,
    // Recibe el icono de la sección.
    IconData icono,
    // Recibe el índice de navegación al pulsar la tarjeta.
    int destino,
  ) {
    // Crea el componente Card de la interfaz.
    return Card(
      // Establece el color del elemento.
      color: Colors.white,
      // Define la elevación visual de la tarjeta.
      elevation: 2,
      // Recorta el contenido según la forma del componente.
      clipBehavior: Clip.antiAlias,

      // Contiene el widget hijo.
      child: InkWell(
        // Define qué sucede al tocar el elemento.
        onTap: () => cambiarPagina(destino),

        // Contiene el widget hijo.
        child: Column(
          // Alinea los hijos a lo largo del eje principal.
          mainAxisAlignment: MainAxisAlignment.center,

          // Lista de widgets que componen esta sección.
          children: [
            // Crea el componente Icon de la interfaz.
            Icon(icono, color: const Color(0xFFC9A227), size: 45),

            // Añade un espacio fijo entre los componentes.
            const SizedBox(height: 12),

            // Crea el componente Text de la interfaz.
            Text(
              // Texto del título de la tarjeta.
              titulo,
              // Configura la apariencia del texto.
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            // Muestra el contador solo si no está vacío.
            if (cantidad.isNotEmpty)
              // Crea el componente Text de la interfaz.
              Text(cantidad, style: const TextStyle(fontSize: 22)),
          ],
        ),
      ),
    );
  }

}