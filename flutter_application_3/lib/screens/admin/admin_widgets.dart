/// Archivo: admin_widgets.dart.
/// Reúne componentes visuales reutilizados por las secciones administrativas.

// World of Movies: Campos, buscador, imágenes, estrellas y menú lateral.
// part of permite compartir imports y el estado de la pantalla principal.
part of '../admin_dashboard_page.dart';

// Este mixin aporta funciones al mismo estado; no crea otra pantalla independiente.
mixin _AdminWidgets on _AdminDashboardBase {
  // =====================================
  // CAMPO DE FORMULARIO
  // =====================================

  // Construye un campo de texto reutilizable con validaciones.
  @override
  Widget campo(
    // Controlador que almacena y permite leer lo escrito.
    TextEditingController controlador,
    // Etiqueta que aparece dentro del campo.
    String etiqueta, {
    // Determina si se exige un valor.
    bool obligatorio = true,
    // Permite ocultar el texto, por ejemplo una contraseña.
    bool oculto = false,
    // Número máximo de líneas visibles del campo.
    int lineas = 1,
    // Límite de caracteres, opcional.
    int? maximo,
    // Cantidad mínima de caracteres cuando hay contenido.
    int minimo = 1,
  }) {
    // Crea el componente Padding de la interfaz.
    return Padding(
      // Define el espacio interior del elemento.
      padding: const EdgeInsets.only(bottom: 12),
      // Contiene el widget hijo.
      child: TextFormField(
        // Vincula el campo con su controlador de texto.
        controller: controlador,
        // Oculta o muestra los caracteres del campo.
        obscureText: oculto,
        // Limita el número de líneas del campo.
        maxLines: lineas,
        // Limita el número de caracteres del campo.
        maxLength: maximo,
        // Configura la apariencia visual del elemento.
        decoration: InputDecoration(
          // Etiqueta visible del campo.
          labelText: etiqueta,
          // Define el borde del componente.
          border: const OutlineInputBorder(),
        ),
        // Función que devuelve un mensaje de error o null si es válido.
        validator: (valor) {
          // Elimina espacios exteriores para validar el texto.
          final texto = valor?.trim() ?? '';

          // Comprueba si el campo obligatorio está vacío.
          if (obligatorio && texto.isEmpty) {
            // Devuelve un mensaje de campo obligatorio.
            return 'Completa este campo';
          }

          // Comprueba que el texto alcance la longitud mínima.
          if (texto.isNotEmpty && texto.length < minimo) {
            // Informa cuántos caracteres necesita como mínimo.
            return 'Mínimo $minimo caracteres';
          }

          // Devuelve null cuando no hay error de validación.
          return null;
        },
      ),
    );
  }

  // =====================================
  // BUSCADOR
  // =====================================

  // Construye el buscador reutilizable de las secciones.
  /// Construye el campo reutilizable para filtrar una lista.
  @override
  Widget buscador(String texto) {
    // Crea el componente Padding de la interfaz.
    return Padding(
      // Define el espacio interior del elemento.
      padding: const EdgeInsets.all(15),

      // Contiene el widget hijo.
      child: TextField(
        // Utiliza el índice de página como clave del campo.
        key: ValueKey(pagina),

        // Se ejecuta cuando cambia el valor del control.
        onChanged: (valor) {
          // Notifica a Flutter que debe reconstruir la pantalla con el estado nuevo.
          setState(() {
            // Actualiza el filtro con el texto que escribe el administrador.
            busqueda = valor;
          });
        },

        // Configura la apariencia visual del elemento.
        decoration: InputDecoration(
          // Texto de ayuda cuando el campo está vacío.
          hintText: texto,
          // Icono que aparece al principio del campo.
          prefixIcon: const Icon(Icons.search),

          // Define el borde del componente.
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // =====================================
  // IMÁGENES DE LAS PELÍCULAS
  // =====================================

  // Muestra una imagen de película o un icono alternativo.
  /// Carga la imagen de catálogo o presenta una alternativa visual.
  @override
  Widget fotoPelicula(dynamic imagen) {
    // Normaliza la ruta de la imagen a una cadena de texto.
    String ruta = imagen?.toString().trim() ?? '';

    // Comprueba si no hay una imagen registrada.
    if (ruta.isEmpty) {
      // Crea el componente Icon de la interfaz.
      return const Icon(Icons.movie_outlined, size: 42);
    }

    // Si la ruta comienza con /, añade la dirección base de la API.
    if (ruta.startsWith('/')) {
      // Añade la dirección base a la ruta existente.
      ruta = '${AdminService.baseUrl}$ruta';
    // Distingue una ruta relativa de una URL completa.
    } else if (!ruta.startsWith('http://') && !ruta.startsWith('https://')) {
      // Reconoce las carpetas de imágenes y uploads.
      if (ruta.startsWith('imagenes/') || ruta.startsWith('uploads/')) {
        // Añade la URL base a la ruta relativa.
        ruta = '${AdminService.baseUrl}/$ruta';
      // Alternativa cuando no se cumple la condición anterior.
      } else {
        // Para un nombre suelto, busca en /imagenes.
        ruta = '${AdminService.baseUrl}/imagenes/$ruta';
      }
    }

    // Crea el componente ClipRRect de la interfaz.
    return ClipRRect(
      // Redondea las esquinas.
      borderRadius: BorderRadius.circular(6),
      // Contiene el widget hijo.
      child: Image.network(
        // URL que se utiliza para cargar la imagen.
        ruta,
        // Define el ancho del elemento.
        width: 55,
        // Define la altura o el espacio vertical.
        height: 65,
        // Controla cómo se ajusta la imagen al espacio disponible.
        fit: BoxFit.cover,

        // Si falla la carga de la imagen, muestra un icono alternativo.
        errorBuilder: (context, error, stack) {
          // Crea el componente Icon de la interfaz.
          return const Icon(Icons.movie_outlined, size: 40);
        },
      ),
    );
  }

  // =====================================
  // MOSTRAR ESTRELLAS
  // =====================================

  // Representa una calificación con estrellas y un número decimal.
  /// Presenta la puntuación como estrellas y su valor numérico.
  @override
  Widget estrellas(dynamic valor) {
    // Intenta interpretar el valor como un número decimal.
    final double? calificacion = double.tryParse(valor.toString());

    // Detecta la ausencia de calificación o valores fuera del rango.
    if (calificacion == null || calificacion < 1 || calificacion > 5) {
      // Crea el componente Text de la interfaz.
      return const Text(
        // Texto que indica ausencia de una valoración válida.
        'Sin calificación',
        // Configura la apariencia del texto.
        style: TextStyle(color: Colors.grey, fontSize: 13),
      );
    }

    // Crea el componente Wrap de la interfaz.
    return Wrap(
      // Alinea los hijos en el eje transversal.
      crossAxisAlignment: WrapCrossAlignment.center,
      // Separación entre los elementos.
      spacing: 3,

      // Lista de widgets que componen esta sección.
      children: [
        // Genera cinco posiciones para los iconos de estrella.
        ...List.generate(5, (index) {
          // Declara el icono que se usará para esta posición.
          IconData icono;

          // Comprueba si corresponde una estrella completa.
          if (calificacion >= index + 1) {
            // Selecciona una estrella rellena.
            icono = Icons.star;
          // Comprueba si alcanza al menos media estrella.
          } else if (calificacion >= index + 0.5) {
            // Selecciona una media estrella.
            icono = Icons.star_half;
          // Alternativa cuando no se cumple la condición anterior.
          } else {
            // Selecciona una estrella vacía.
            icono = Icons.star_border;
          }

          // Crea el componente Icon de la interfaz.
          return Icon(icono, color: const Color(0xFFC9A227), size: 19);
        }),

        // Crea el componente Text de la interfaz.
        Text(
          // Muestra la calificación redondeada a un decimal, sobre cinco.
          '${calificacion.toStringAsFixed(1)}/5',
          // Configura la apariencia del texto.
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // =====================================
  // MENÚ LATERAL
  // =====================================

  // Construye el menú lateral de navegación.
  /// Construye el menú y conecta sus opciones con la navegación del panel.
  @override
  Widget menuLateral() {
    // Crea el componente Drawer de la interfaz.
    return Drawer(
      // Contiene el widget hijo.
      child: Column(
        // Lista de widgets que componen esta sección.
        children: [
          // Crea el componente UserAccountsDrawerHeader de la interfaz.
          UserAccountsDrawerHeader(
            // Configura la apariencia visual del elemento.
            decoration: const BoxDecoration(color: Color(0xFF08245C)),

            // Nombre de la cuenta en el menú.
            accountName: Text(administrador['nom_usr'] ?? 'Administrador'),

            // Correo de la cuenta en el menú.
            accountEmail: Text(administrador['mail'] ?? ''),

            // Imagen o icono de la cuenta actual.
            currentAccountPicture: const CircleAvatar(
              // Establece el color de fondo.
              backgroundColor: Colors.white,

              // Contiene el widget hijo.
              child: Icon(
                // Selecciona el icono visual indicado.
                Icons.movie_creation_outlined,
                // Establece el color del elemento.
                color: Color(0xFF08245C),
                // Define el tamaño del icono.
                size: 40,
              ),
            ),
          ),

          // Genera una opción por cada título del menú.
          for (int i = 0; i < titulos.length; i++)
            // Crea el componente ListTile de la interfaz.
            ListTile(
              // Utiliza el icono que corresponde a esta sección.
              leading: Icon(iconos[i]),
              // Utiliza el título que corresponde a esta sección.
              title: Text(titulos[i]),
              // Resalta la sección actualmente seleccionada.
              selected: pagina == i,

              // Define qué sucede al tocar el elemento.
              onTap: () {
                // Cierra el menú lateral antes de cambiar la sección.
                Navigator.pop(context);
                // Actualiza la sección visible.
                cambiarPagina(i);
              },
            ),

          // Ocupa el espacio libre y desplaza los elementos restantes.
          const Spacer(),
          // Añade una línea de separación visual.
          const Divider(),

          // Crea el componente ListTile de la interfaz.
          ListTile(
            // Contenido situado al inicio de la fila.
            leading: const Icon(Icons.logout, color: Colors.red),

            // Define el título visible.
            title: const Text('Cerrar sesión'),

            // Define qué sucede al tocar el elemento.
            onTap: () {
              // Cierra el menú lateral.
              Navigator.pop(context);
              // Solicita el cierre de sesión.
              cerrarSesion();
            },
          ),

          // Añade un espacio fijo entre los componentes.
          const SizedBox(height: 10),
        ],
      ),
    );
  }

}
