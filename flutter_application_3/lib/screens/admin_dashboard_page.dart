/// Archivo: admin_dashboard_page.dart.
/// Construye el panel administrativo, carga sus datos y coordina las secciones de administración.

// Importa los componentes visuales de Material Design.
import 'package:flutter/material.dart';

// Permite trabajar con los bytes de una imagen mediante Uint8List.
import 'dart:typed_data';

// Importa el selector de imágenes de la galería o computadora.
import 'package:image_picker/image_picker.dart';

// Importa el servicio que comunica el administrador con FastAPI.
import '../services/admin_service.dart';

// Part: Permite conectar diferentes archivos Dart con el archivo principal.
part 'admin/admin_inicio.dart';
part 'admin/admin_pelicula_form.dart'; // Conecta el formulario de películas.
part 'admin/admin_peliculas_page.dart'; // Conecta el módulo de películas.
part 'admin/admin_usuario_form.dart';
part 'admin/admin_usuarios_page.dart'; // Conecta el módulo de usuarios.
part 'admin/admin_resenas_page.dart';
part 'admin/admin_perfil_page.dart';
part 'admin/admin_widgets.dart';

// Define la pantalla principal como un widget con estado mutable.
/// Coordina los datos de sesión, navegación y contenido del panel administrativo.
class AdminDashboardPage extends StatefulWidget {
  // Constructor de la pantalla; acepta una clave opcional de Flutter.
  const AdminDashboardPage({super.key});

  // Indica que se implementa un método heredado.
  @override
  // Crea el objeto que administra el estado y la interfaz de la pantalla.
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

// Clase base: conserva los datos, la sesión y las funciones comunes.
// Los módulos implementan los métodos abstractos declarados al final.
/// Comparte el estado, las dependencias y las acciones entre secciones del panel.
abstract class _AdminDashboardBase extends State<AdminDashboardPage> {
  // Servicio de la API; permanece nulo hasta autenticar al administrador.
  AdminService? servicio;

  // Mapa con los datos del administrador y su token de acceso.
  Map<String, dynamic> administrador = {};

  // Índice de la sección actual: 0 es Inicio.
  int pagina = 0;
  // Texto utilizado para filtrar los listados.
  String busqueda = '';
  // Mensaje de error opcional; null significa que no hay error.
  String? error;
  // Indica si se está cargando información.
  bool cargando = true;
  // Evita iniciar la carga más de una vez.
  bool iniciado = false;

  // Lista de películas devueltas por FastAPI.
  List<Map<String, dynamic>> peliculas = [];
  // Lista de usuarios devueltos por FastAPI.
  List<Map<String, dynamic>> usuarios = [];
  // Lista de reseñas devueltas por FastAPI.
  List<Map<String, dynamic>> resenas = [];
  // Reportes que usuarios enviaron sobre reseñas.
  List<Map<String, dynamic>> reportes = [];
  // Alterna entre moderación general y la bandeja de reportes.
  bool mostrarReportes = false;

  // Nombres de las secciones, en el orden de navegación.
  final titulos = [
    // Índice 0: pantalla de inicio.
    'Inicio',
    // Índice 1: administración de películas.
    'Películas',
    // Índice 2: administración de usuarios.
    'Usuarios',
    // Índice 3: moderación de reseñas.
    'Reseñas',
    // Índice 4: perfil y configuración.
    'Configuración',
  ];

  // Iconos correspondientes a los títulos anteriores.
  final iconos = [
    // Selecciona el icono visual indicado.
    Icons.home_outlined,
    // Selecciona el icono visual indicado.
    Icons.movie_outlined,
    // Selecciona el icono visual indicado.
    Icons.people_outline,
    // Selecciona el icono visual indicado.
    Icons.star_border,
    // Selecciona el icono visual indicado.
    Icons.settings_outlined,
  ];

  // =====================================
  // RECIBIR DATOS DEL LOGIN
  // =====================================

  // Indica que se implementa un método declarado en la clase base.
  @override
  // Recibe los argumentos de navegación cuando las dependencias están disponibles.
  /// Actualiza los datos que dependen del contexto de la aplicación.
  void didChangeDependencies() {
    // Ejecuta primero el comportamiento heredado de Flutter.
    super.didChangeDependencies();

    // Sale si ya se procesó el inicio de sesión.
    if (iniciado) return;
    // Marca la inicialización como realizada.
    iniciado = true;

    // Recupera los datos enviados desde la pantalla de login.
    final argumentos = ModalRoute.of(context)?.settings.arguments;

    // Comprueba que los argumentos recibidos sean un mapa.
    if (argumentos is Map) {
      // Copia los argumentos a un mapa con claves de texto.
      administrador = Map<String, dynamic>.from(argumentos);

      // Obtiene el token de acceso; usa texto vacío si falta.
      final token = administrador['access_token']?.toString() ?? '';

      // Convierte el rol a texto para compararlo.
      final rol = administrador['tip_usu']?.toString();

      // Solo habilita el servicio si hay token y el rol es 1 (administrador).
      if (token.isNotEmpty && rol == '1') {
        // Crea el servicio con el token para las solicitudes protegidas.
        servicio = AdminService(token);
        // Inicia la consulta de datos del administrador.
        cargarDatos();
        // Termina la inicialización exitosa.
        return;
      }
    }

    // Desactiva la carga porque faltan credenciales válidas.
    cargando = false;
    // Establece el mensaje que verá quien no tenga sesión administrativa.
    error = 'Debes iniciar sesión como administrador.';
  }

  // =====================================
  // CARGAR DATOS REALES DE MYSQL
  // =====================================

  // Consulta y actualiza las tres listas que usa el panel.
  /// Consulta los datos necesarios para construir las secciones del panel.
  Future<void> cargarDatos() async {
    // No realiza peticiones si no existe un servicio autenticado.
    if (servicio == null) return;

    // Notifica a Flutter que debe reconstruir la pantalla con el estado nuevo.
    setState(() {
      // Activa el indicador de carga.
      cargando = true;
      // Limpia un error previo antes de reintentar.
      error = null;
    });

    // Inicia un bloque de instrucciones que pueden producir un error.
    try {
      // Consulta las películas mediante el servicio.
      final listaPeliculas = await servicio!.obtenerPeliculas();

      // Consulta los usuarios mediante el servicio.
      final listaUsuarios = await servicio!.obtenerUsuarios();

      // Consulta las reseñas mediante el servicio.
      final listaResenas = await servicio!.obtenerResenas();

      // Consulta los reportes para presentarlos en la moderación.
      final listaReportes = await servicio!.obtenerReportes();

      // Evita utilizar el estado si la pantalla ya fue desmontada.
      if (!mounted) return;

      // Notifica a Flutter que debe reconstruir la pantalla con el estado nuevo.
      setState(() {
        // Reemplaza las películas locales con los datos recibidos.
        peliculas = listaPeliculas;
        // Reemplaza los usuarios locales con los datos recibidos.
        usuarios = listaUsuarios;
        // Reemplaza las reseñas locales con los datos recibidos.
        resenas = listaResenas;
        // Reemplaza la bandeja local con los reportes recibidos.
        reportes = listaReportes;
      });
      // Captura una excepción para gestionar el error.
    } catch (e) {
      // Comprueba que el widget sigue montado antes de utilizar su contexto.
      if (!mounted) return;

      // Notifica a Flutter que debe reconstruir la pantalla con el estado nuevo.
      setState(() {
        // Guarda el mensaje de error sin el prefijo Exception.
        error = e.toString().replaceFirst('Exception: ', '');
      });
      // Ejecuta esta sección al terminar, incluso si hubo una excepción.
    } finally {
      // Comprueba que el widget permanece montado.
      if (mounted) {
        // Notifica a Flutter que debe reconstruir la pantalla con el estado nuevo.
        setState(() {
          // Desactiva el indicador de carga al terminar.
          cargando = false;
        });
      }
    }
  }

  // =====================================
  // FUNCIONES GENERALES
  // =====================================

  // Muestra un aviso breve en la parte inferior de la pantalla.
  /// Muestra una confirmación o error breve en la pantalla actual.
  void aviso(String mensaje) {
    // Comprueba que el widget sigue montado antes de utilizar su contexto.
    if (!mounted) return;

    // Obtiene el ScaffoldMessenger asociado al contexto.
    ScaffoldMessenger.of(context)
    // Muestra el mensaje mediante un SnackBar.
    .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  // Cambia la sección visible del administrador.
  /// Actualiza la sección seleccionada del panel administrativo.
  void cambiarPagina(int destino) {
    // Notifica a Flutter que debe reconstruir la pantalla con el estado nuevo.
    setState(() {
      // Actualiza el índice de la sección seleccionada.
      pagina = destino;
      // Limpia la búsqueda al cambiar de sección.
      busqueda = '';
    });
  }

  // Abre una confirmación y devuelve true si se acepta.
  /// Solicita confirmación y devuelve la decisión elegida por el administrador.
  Future<bool> confirmar(String mensaje) async {
    // Abre el diálogo de confirmación y espera un booleano.
    return await showDialog<bool>(
          // Contexto que se utiliza para construir o navegar entre widgets.
          context: context,
          // Función que construye el contenido cuando Flutter lo necesita.
          builder: (context) => AlertDialog(
            // Define el título visible.
            title: const Text('Confirmar'),
            // Define el contenido principal del diálogo.
            content: Text(mensaje),
            // Define los botones o acciones disponibles.
            actions: [
              // Crea el componente TextButton de la interfaz.
              TextButton(
                // Define qué sucede al pulsar el botón.
                onPressed: () => Navigator.pop(context, false),
                // Contiene el widget hijo.
                child: const Text('Cancelar'),
              ),
              // Crea el componente FilledButton de la interfaz.
              FilledButton(
                // Define qué sucede al pulsar el botón.
                onPressed: () => Navigator.pop(context, true),
                // Contiene el widget hijo.
                child: const Text('Aceptar'),
              ),
            ],
          ),
          // Si el diálogo no devuelve un valor, utiliza la alternativa siguiente.
        ) ??
        // Considera la confirmación cancelada si el resultado es nulo.
        false;
  }

  // Ejecuta una operación de escritura y recarga los datos.
  Future<void> ejecutarOperacion(
    // Recibe una función asíncrona que realiza la operación de la API.
    // Callback asíncrono que ejecuta el cambio solicitado en la API.
    Future<void> Function() operacion,
    // Recibe el texto que se mostrará cuando termine correctamente.
    String mensaje,
  ) async {
    // Evita operaciones simultáneas o sin sesión.
    if (cargando || servicio == null) return;

    // Notifica a Flutter que debe reconstruir la pantalla con el estado nuevo.
    setState(() {
      // Activa la carga mientras se ejecuta la operación.
      cargando = true;
    });

    // Inicia un bloque de instrucciones que pueden producir un error.
    try {
      // Espera a que la operación remota termine.
      await operacion();

      // Comprueba que el widget sigue montado antes de utilizar su contexto.
      if (!mounted) return;

      // Muestra el aviso de éxito.
      aviso(mensaje);
      // Vuelve a consultar los registros para reflejar los cambios.
      await cargarDatos();
      // Captura una excepción para gestionar el error.
    } catch (e) {
      // Comprueba que el widget sigue montado antes de utilizar su contexto.
      if (!mounted) return;

      // Informa del error devuelto por la operación.
      aviso(e.toString().replaceFirst('Exception: ', ''));
      // Ejecuta esta sección al terminar, incluso si hubo una excepción.
    } finally {
      // Comprueba que el widget permanece montado.
      if (mounted) {
        // Notifica a Flutter que debe reconstruir la pantalla con el estado nuevo.
        setState(() {
          // Desactiva la carga al terminar la operación.
          cargando = false;
        });
      }
    }
  }

  // Solicita confirmación y vuelve al login.
  /// Elimina la sesión actual y vuelve a la pantalla de acceso.
  Future<void> cerrarSesion() async {
    // Espera la respuesta del diálogo de cierre de sesión.
    final respuesta = await confirmar('¿Deseas cerrar sesión?');

    // Cancela la salida si no se confirmó o la pantalla ya no existe.
    if (!respuesta || !mounted) return;

    // Limpia los datos de sesión que conserva esta pantalla.
    administrador.clear();
    // Descarta el servicio asociado al token.
    servicio = null;

    // Navega al login y elimina las rutas anteriores de la pila.
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  // =====================================
  // MOSTRAR PANTALLA
  // =====================================

  // Decide qué contenido mostrar en función del estado de la pantalla.
  /// Selecciona y construye la vista asociada a la sección activa.
  Widget contenido() {
    // Comprueba si se están cargando los datos.
    if (cargando) {
      // Crea el componente Center de la interfaz.
      return const Center(child: CircularProgressIndicator());
    }

    // Comprueba si hubo un error durante la carga.
    if (error != null) {
      // Crea el componente Center de la interfaz.
      return Center(
        // Contiene el widget hijo.
        child: Padding(
          // Define el espacio interior del elemento.
          padding: const EdgeInsets.all(20),

          // Contiene el widget hijo.
          child: Column(
            // Controla cuánto espacio ocupa el widget en su eje principal.
            mainAxisSize: MainAxisSize.min,

            // Lista de widgets que componen esta sección.
            children: [
              // Crea el componente Icon de la interfaz.
              const Icon(Icons.error_outline, color: Colors.red, size: 55),

              // Añade un espacio fijo entre los componentes.
              const SizedBox(height: 15),

              // Crea el componente Text de la interfaz.
              Text(error!, textAlign: TextAlign.center),

              // Añade un espacio fijo entre los componentes.
              const SizedBox(height: 15),

              // Solo permite reintentar si ya existe un servicio autenticado.
              if (servicio != null)
                // Crea el componente FilledButton de la interfaz.
                FilledButton(
                  // Ejecuta de nuevo las consultas a la API.
                  onPressed: cargarDatos,
                  // Contiene el widget hijo.
                  child: const Text('Reintentar'),
                ),

              // Crea el componente TextButton de la interfaz.
              TextButton(
                // Permite volver al inicio de sesión.
                onPressed: cerrarSesion,
                // Contiene el widget hijo.
                child: const Text('Volver al login'),
              ),
            ],
          ),
        ),
      );
    }

    // Selecciona la pantalla utilizando el índice de navegación.
    switch (pagina) {
      // Opción del índice de navegación.
      case 1:
        // Muestra el módulo de películas.
        return pantallaPeliculas();

      // Opción del índice de navegación.
      case 2:
        // Muestra el módulo de usuarios.
        return pantallaUsuarios();

      // Opción del índice de navegación.
      case 3:
        // Muestra el módulo de reseñas.
        return pantallaResenas();

      // Opción del índice de navegación.
      case 4:
        // Muestra el módulo de configuración.
        return configuracion();

      // Opción predeterminada del selector.
      default:
        // Muestra el inicio si no corresponde a otra sección.
        return inicio();
    }
  }

  // Indica que se implementa un método declarado en la clase base.
  @override
  // Construye la interfaz principal del administrador.
  /// Presenta el panel, su navegación y la sección administrativa seleccionada.
  Widget build(BuildContext context) {
    // Aplica el tema visual local a esta pantalla.
    return Theme(
      // Construye la configuración del tema de Flutter.
      data: ThemeData(
        // Activa los componentes de Material 3.
        useMaterial3: true,

        // Genera el esquema de colores con el azul del proyecto.
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF08245C)),

        // Define el color de fondo general.
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),

        // Configura el estilo de la barra superior.
        appBarTheme: const AppBarTheme(
          // Establece el color de fondo.
          backgroundColor: Color(0xFF08245C),
          // Establece el color de los elementos delanteros.
          foregroundColor: Colors.white,
          // Centra el título de la barra superior.
          centerTitle: true,
        ),
      ),

      // Contiene el widget hijo.
      child: Scaffold(
        // Barra superior de la pantalla.
        appBar: AppBar(
          // Muestra el nombre del proyecto o el título de la sección.
          title: Text(pagina == 0 ? 'World of Movies' : titulos[pagina]),

          // Define los botones o acciones disponibles.
          actions: [
            // Crea el componente IconButton de la interfaz.
            IconButton(
              // Texto de ayuda de la acción.
              tooltip: 'Actualizar',
              // Deshabilita la recarga mientras haya una carga en curso.
              onPressed: cargando ? null : cargarDatos,
              // Icono que representa la acción.
              icon: const Icon(Icons.refresh),
            ),

            // Crea el componente IconButton de la interfaz.
            IconButton(
              // Texto de ayuda de la acción.
              tooltip: 'Mi perfil',
              // Abre la sección de perfil.
              onPressed: () => cambiarPagina(4),
              // Icono que representa la acción.
              icon: const Icon(Icons.account_circle_outlined),
            ),
          ],
        ),

        // Muestra el menú lateral solo si existe un servicio autenticado.
        drawer: servicio != null ? menuLateral() : null,

        // Contenido principal de la pantalla.
        body: Center(
          // Contiene el widget hijo.
          child: ConstrainedBox(
            // Limita el ancho del contenido para pantallas grandes.
            constraints: const BoxConstraints(maxWidth: 1100),

            // Inserta el contenido seleccionado según el estado.
            child: contenido(),
          ),
        ),

        // Botón flotante para crear registros.
        floatingActionButton:
            // Muestra el botón + solo en películas o usuarios, sin carga ni error.
            !cargando && error == null && (pagina == 1 || pagina == 2)
            // Valor que se utiliza cuando la condición es verdadera.
            ? FloatingActionButton(
                // Establece el color de fondo.
                backgroundColor: const Color(0xFF08245C),

                // Establece el color de los elementos delanteros.
                foregroundColor: Colors.white,

                // Define qué sucede al pulsar el botón.
                onPressed: () {
                  // Comprueba si se está en el módulo de películas.
                  if (pagina == 1) {
                    // Abre el formulario de nueva película.
                    formularioPelicula();
                    // Alternativa cuando no se cumple la condición anterior.
                  } else {
                    // Abre el formulario de nuevo usuario.
                    formularioUsuario();
                  }
                },

                // Contiene el widget hijo.
                child: const Icon(Icons.add),
              )
            // Valor alternativo cuando la condición es falsa.
            : null,
      ),
    );
  }

  // Contratos que conectan los módulos sin duplicar el estado.
  // Cada función conserva su implementación en el archivo correspondiente.
  // Pantalla de inicio y contadores.
  Widget inicio();
  // Listado de películas.
  Widget pantallaPeliculas();
  // Listado de usuarios.
  Widget pantallaUsuarios();
  // Listado y moderación de reseñas.
  Widget pantallaResenas();
  // Perfil y configuración.
  Widget configuracion();
  // Menú lateral.
  Widget menuLateral();
  // Formulario de alta o edición de películas.
  Future<void> formularioPelicula([Map<String, dynamic>? pelicula]);
  // Formulario de alta o edición de usuarios.
  Future<void> formularioUsuario([Map<String, dynamic>? usuario]);
  // Vista previa de la imagen.
  Widget fotoPelicula(dynamic imagen);
  // Representación visual de la calificación.
  Widget estrellas(dynamic valor);
  // Campo de búsqueda compartido.
  Widget buscador(String texto);
  // Campo de texto con validación reutilizable.
  Widget campo(
    TextEditingController controlador,
    String etiqueta, {
    bool obligatorio = true,
    bool oculto = false,
    int lineas = 1,
    int? maximo,
    int minimo = 1,
  });
}

// El estado final reúne todos los módulos y conserva un solo conjunto de datos.
/// Carga la información administrativa y comparte el estado con sus secciones.
class _AdminDashboardPageState extends _AdminDashboardBase
    with
        _AdminInicio,
        _AdminPeliculaForm,
        _AdminPeliculas,
        _AdminUsuarioForm,
        _AdminUsuarios,
        _AdminResenas,
        _AdminPerfil,
        _AdminWidgets {}
