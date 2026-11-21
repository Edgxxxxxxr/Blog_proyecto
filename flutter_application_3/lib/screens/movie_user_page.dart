/// Archivo: movie_user_page.dart.
/// Coordina la navegación principal del usuario entre inicio, búsqueda, favoritos y perfil.

import 'package:flutter/material.dart';

import '../models/pelicula_model.dart';
import 'favorites_tab.dart';
import 'home_tab.dart';
import 'movie_detail_page.dart';
import 'profile_tab.dart';
import 'search_tab.dart';
import '../widgets/movie_theme.dart';

/// Contenedor de navegación del usuario; las vistas están en archivos separados.
class MovieUserPage extends StatefulWidget {
  final Map<String, dynamic> usuario;

  /// Crea el componente MovieUserPage con los valores que necesita para funcionar.
  const MovieUserPage({
    super.key,
    required this.usuario,
  });

  @override
  State<MovieUserPage> createState() => _MovieUserPageState();
}

/// Conserva la pestaña seleccionada y cambia entre secciones del usuario.
class _MovieUserPageState extends State<MovieUserPage> {
  int _indice = 0;
  int _actualizacionFavoritos = 0;

  /// Devuelve el valor calculado de  token para la interfaz.
  String get _token => widget.usuario['access_token']?.toString() ?? '';
  /// Devuelve el valor calculado de  usuarioId para la interfaz.
  int get _usuarioId => (widget.usuario['id_usr'] as num?)?.toInt() ?? 0;

  /// Abre el detalle de película y refresca los favoritos al volver.
  Future<void> _abrirDetalle(PeliculaModel pelicula) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => MovieDetailPage(
          pelicula: pelicula,
          token: _token,
          usuarioId: _usuarioId,
        ),
      ),
    );
    if (mounted) {
      setState(() => _actualizacionFavoritos++);
    }
  }

  /// Devuelve el valor calculado de  titulo para la interfaz.
  String get _titulo {
    switch (_indice) {
      case 1:
        return 'Buscar';
      case 2:
        return 'Favoritos';
      case 3:
        return 'Mi perfil';
      default:
        return 'World of Movies';
    }
  }

  /// Dibuja la navegación inferior y el contenido de la pestaña seleccionada.
  @override
  Widget build(BuildContext context) {
    if (_token.isEmpty) {
      return const Scaffold(
        backgroundColor: movieBackground,
        body: Center(
          child: Text(
            'La sesión no contiene un token. Inicia sesión de nuevo.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: movieBackground,
      appBar: AppBar(
        backgroundColor: movieBackground,
        foregroundColor: Colors.white,
        title: Text(_titulo),
      ),
      body: IndexedStack(
        index: _indice,
        children: [
          HomeTab(
            token: _token,
            nombreUsuario: widget.usuario['nom_usr']?.toString() ?? 'Usuario',
            onOpenMovie: _abrirDetalle,
          ),
          SearchTab(token: _token, onOpenMovie: _abrirDetalle),
          FavoritesTab(
            token: _token,
            refreshSignal: _actualizacionFavoritos,
            onExplore: () => setState(() => _indice = 1),
            onOpenMovie: _abrirDetalle,
          ),
          ProfileTab(
            token: _token,
            usuario: widget.usuario,
            onOpenFavorites: () => setState(() => _indice = 2),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBarTheme(
        // El tema aplica los colores sin depender de parámetros del widget.
        data: NavigationBarThemeData(
          backgroundColor: movieSurface,
          indicatorColor: movieGold.withValues(alpha: 0.22),
          iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? movieGold
                  : Colors.white70,
            ),
          ),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              color: states.contains(WidgetState.selected)
                  ? Colors.white
                  : Colors.white70,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _indice,
          onDestinationSelected: (indice) => setState(() => _indice = indice),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.search),
              label: 'Buscar',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: 'Favoritos',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
