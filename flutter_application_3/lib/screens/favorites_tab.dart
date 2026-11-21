/// Archivo: favorites_tab.dart.
/// Presenta los favoritos del usuario y permite abrirlos, quitarlos o volver al catálogo.

import 'package:flutter/material.dart';

import '../models/pelicula_model.dart';
import '../viewmodels/favorites_view_model.dart';
import '../widgets/movie_card.dart';
import '../widgets/movie_theme.dart';

/// Lista persistente de películas favoritas del usuario actual.
class FavoritesTab extends StatefulWidget {
  final String token;
  final int refreshSignal;
  final VoidCallback onExplore;
  final Future<void> Function(PeliculaModel) onOpenMovie;

  /// Crea el componente FavoritesTab con los valores que necesita para funcionar.
  const FavoritesTab({
    super.key,
    required this.token,
    required this.refreshSignal,
    required this.onExplore,
    required this.onOpenMovie,
  });

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

/// Carga los favoritos y coordina su apertura o eliminación.
class _FavoritesTabState extends State<FavoritesTab> {
  late final FavoritesViewModel _viewModel;

  /// Inicializa el estado y los recursos que necesita la pantalla.
  @override
  void initState() {
    super.initState();
    _viewModel = FavoritesViewModel(token: widget.token);
  }

  /// Responde a cambios en las propiedades recibidas por el widget.
  @override
  void didUpdateWidget(covariant FavoritesTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshSignal != widget.refreshSignal) {
      _viewModel.cargarFavoritos();
    }
  }

  /// Marca el ViewModel como cerrado y libera el notificador base.
  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  /// Vuelve a consultar la lista después de una acción del usuario.
  Future<void> _recargar() {
    return _viewModel.cargarFavoritos();
  }

  /// Pide confirmación y elimina la película de favoritos si se acepta.
  Future<void> _quitar(PeliculaModel pelicula) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF374151),
        title: const Text(
          '¿Quitar de favoritos?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Se quitará ${pelicula.titulo} de tu lista.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;
    try {
      await _viewModel.quitar(pelicula);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo quitar el favorito: $error')),
      );
    }
  }

  /// Muestra estados de carga, error, lista de favoritos o lista vacía.
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        if (_viewModel.cargando) {
          return const Center(
            child: CircularProgressIndicator(color: movieGold),
          );
        }
        if (_viewModel.error != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'No se pudieron cargar tus favoritos: ${_viewModel.error!}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _recargar,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }
        final peliculas = _viewModel.favoritos;
        if (peliculas.isEmpty) return _estadoVacio();

        return RefreshIndicator(
          onRefresh: _recargar,
          color: movieGold,
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const Text(
                'Mis favoritos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              // Genera una tarjeta por cada película guardada como favorita.
              ...peliculas.map(
                (pelicula) => MovieCard(
                  pelicula: pelicula,
                  onTap: () async {
                    await widget.onOpenMovie(pelicula);
                    if (mounted) _recargar();
                  },
                  trailing: IconButton(
                    tooltip: 'Quitar de favoritos',
                    onPressed: () => _quitar(pelicula),
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Presenta el contenido alternativo cuando la lista no tiene elementos.
  Widget _estadoVacio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite, color: movieGold, size: 54),
            const SizedBox(height: 14),
            const Text(
              'Aún no tienes favoritos',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Explora las películas y guarda aquí las que te interesen.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: widget.onExplore,
              child: const Text('Explorar películas'),
            ),
          ],
        ),
      ),
    );
  }
}
