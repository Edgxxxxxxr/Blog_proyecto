/// Archivo: movie_detail_page.dart.
/// Presenta el detalle de una película y las acciones de favorito, reseña y reporte.

import 'package:flutter/material.dart';

import '../models/pelicula_model.dart';
import '../models/resena_model.dart';
import '../viewmodels/movie_detail_view_model.dart';
import '../widgets/movie_poster.dart';
import '../widgets/movie_theme.dart';
import '../widgets/review_card.dart';
import 'review_form_dialog.dart';

/// Detalle visual de una película; los datos y acciones viven en su ViewModel.
class MovieDetailPage extends StatefulWidget {
  final PeliculaModel pelicula;
  final String token;
  final int usuarioId;

  /// Crea el componente MovieDetailPage con los valores que necesita para funcionar.
  const MovieDetailPage({
    super.key,
    required this.pelicula,
    required this.token,
    required this.usuarioId,
  });

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

/// Coordina carga y acciones de reseñas, favoritos y reportes de esta película.
class _MovieDetailPageState extends State<MovieDetailPage> {
  late final MovieDetailViewModel _viewModel;

  /// Inicializa el estado y los recursos que necesita la pantalla.
  @override
  void initState() {
    super.initState();
    _viewModel = MovieDetailViewModel(
      token: widget.token,
      peliculaId: widget.pelicula.id,
      peliculaInicial: widget.pelicula,
    );
  }

  /// Marca el ViewModel como cerrado y libera el notificador base.
  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  /// Abre el formulario de puntuación y publica la reseña confirmada.
  Future<void> _calificar() async {
    final datos = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const ReviewFormDialog(),
    );
    if (datos == null) return;

    try {
      await _viewModel.publicarResena(
        calificacion: datos['calificacion'] as int,
        comentario: datos['comentario'] as String,
      );
      if (mounted) _aviso('Tu calificación se publicó.');
    } catch (error) {
      if (mounted) _aviso('No se pudo publicar: $error');
    }
  }

  /// Guarda o quita la película de favoritos y muestra el resultado.
  Future<void> _alternarFavorito() async {
    final eraFavorita = _viewModel.pelicula.esFavorita;
    try {
      await _viewModel.cambiarFavorito();
      if (mounted) {
        _aviso(
          eraFavorita ? 'Se quitó de favoritos.' : 'Se agregó a favoritos.',
        );
      }
    } catch (error) {
      if (mounted) _aviso('No se pudo actualizar favoritos: $error');
    }
  }

  /// Confirma el reporte de reseña y notifica si se envió a moderación.
  Future<void> _reportar(ResenaModel resena) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: movieSurface,
        title: const Text(
          'Reportar reseña',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Quieres enviar esta reseña al equipo para que la revise?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reportar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    try {
      await _viewModel.reportarResena(resena.id);
      if (mounted) _aviso('Reporte enviado para revisión.');
    } catch (error) {
      if (mounted) _aviso('No se pudo enviar el reporte: $error');
    }
  }

  /// Muestra un mensaje breve de confirmación o error.
  void _aviso(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  /// Presenta los datos de la película, las reseñas y sus acciones disponibles.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: movieBackground,
      appBar: AppBar(
        backgroundColor: movieBackground,
        foregroundColor: Colors.white,
        title: const Text('Detalle de película'),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          if (_viewModel.cargando) {
            return const Center(
              child: CircularProgressIndicator(color: movieGold),
            );
          }
          if (_viewModel.error != null) return _error(_viewModel.error!);

          final pelicula = _viewModel.pelicula;
          return RefreshIndicator(
            onRefresh: _viewModel.cargarDetalle,
            color: movieGold,
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Center(
                  child: MoviePoster(
                    imagePath: pelicula.imagen,
                    semanticLabel: 'Cartel de ${pelicula.titulo}',
                    width: 210,
                    height: 300,
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  pelicula.titulo,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  [
                    if (pelicula.anio != null) pelicula.anio!,
                    if (pelicula.duracion != null) pelicula.duracion!,
                  ].join(' · '),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    pelicula.totalResenas == 0
                        ? 'Aún sin calificaciones'
                        : '★ ${pelicula.calificacionPromedio.toStringAsFixed(1)} '
                              '(${pelicula.totalResenas} calificaciones)',
                    style: const TextStyle(color: movieGold, fontSize: 17),
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: _viewModel.actualizandoFavorito
                      ? null
                      : _alternarFavorito,
                  icon: Icon(
                    pelicula.esFavorita
                        ? Icons.favorite
                        : Icons.favorite_border,
                  ),
                  label: Text(
                    pelicula.esFavorita
                        ? 'Quitar favorito'
                        : 'Agregar a favoritos',
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Sinopsis',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  pelicula.descripcion.isEmpty
                      ? 'No hay sinopsis disponible.'
                      : pelicula.descripcion,
                  style: const TextStyle(color: Colors.white70, height: 1.45),
                ),
                const SizedBox(height: 23),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Reseñas de usuarios',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _viewModel.publicandoResena
                          ? null
                          : _calificar,
                      icon: const Icon(Icons.star_outline),
                      label: Text(
                        _viewModel.publicandoResena
                            ? 'Publicando...'
                            : 'Calificar',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _listaResenas(),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Presenta reseñas y acciones usando únicamente el estado del ViewModel.
  Widget _listaResenas() {
    if (_viewModel.resenas.isEmpty) {
      return const Text(
        'Sé la primera persona en calificar esta película.',
        style: TextStyle(color: Colors.white70),
      );
    }
    return Column(
      children: _viewModel.resenas
          // Convierte cada elemento de la colección al tipo que consume la interfaz.
          .map(
            (resena) => ReviewCard(
              resena: resena,
              canReport: resena.usuarioId != widget.usuarioId,
              onReport: () => _reportar(resena),
            ),
          )
          .toList(),
    );
  }

  /// Presenta el error de carga y la acción para volver a intentarlo.
  Widget _error(String detalle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No se pudo cargar la película: $detalle',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _viewModel.cargarDetalle,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
