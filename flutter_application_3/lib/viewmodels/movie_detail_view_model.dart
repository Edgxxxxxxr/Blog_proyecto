/// Archivo: movie_detail_view_model.dart.
/// Mantiene el detalle, las reseñas y las acciones de una película.

import '../models/pelicula_model.dart';
import '../models/resena_model.dart';
import '../repositories/movie_repository.dart';
import 'view_model.dart';

/// Estado y acciones de detalle, favoritos, reseñas y reportes.
class MovieDetailViewModel extends ViewModel {
  final MovieRepository _repository;
  final String _token;
  final int peliculaId;

  /// Crea el componente MovieDetailViewModel con los valores que necesita para funcionar.
  MovieDetailViewModel({
    required String token,
    required this.peliculaId,
    required PeliculaModel peliculaInicial,
    MovieRepository? repository,
  }) : _token = token,
       _repository = repository ?? MovieRepository(),
       pelicula = peliculaInicial {
    cargarDetalle();
  }

  PeliculaModel pelicula;
  List<ResenaModel> resenas = [];
  bool cargando = true;
  bool actualizandoFavorito = false;
  bool publicandoResena = false;
  String? error;

  /// Actualiza el detalle y las reseñas en una sola carga.
  Future<void> cargarDetalle() async {
    cargando = true;
    error = null;
    notifyListeners();

    try {
      final resultados = await Future.wait<Object>([
        _repository.obtenerPelicula(peliculaId: peliculaId, token: _token),
        _repository.obtenerResenas(peliculaId: peliculaId, token: _token),
      ]);
      pelicula = resultados[0] as PeliculaModel;
      resenas = resultados[1] as List<ResenaModel>;
    } catch (exception) {
      error = exception.toString().replaceFirst('Exception: ', '');
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  /// Guarda o quita el favorito y actualiza el detalle.
  Future<void> cambiarFavorito() async {
    if (actualizandoFavorito) return;
    actualizandoFavorito = true;
    notifyListeners();
    try {
      await _repository.cambiarFavorito(
        peliculaId: peliculaId,
        token: _token,
        agregar: !pelicula.esFavorita,
      );
      await cargarDetalle();
    } finally {
      actualizandoFavorito = false;
      notifyListeners();
    }
  }

  /// Publica la calificación y recupera el promedio y la reseña nueva.
  Future<void> publicarResena({
    required int calificacion,
    required String comentario,
  }) async {
    publicandoResena = true;
    notifyListeners();
    try {
      await _repository.publicarResena(
        peliculaId: peliculaId,
        token: _token,
        calificacion: calificacion,
        comentario: comentario,
      );
      await cargarDetalle();
    } finally {
      publicandoResena = false;
      notifyListeners();
    }
  }

  /// Envía una reseña a la bandeja de moderación administrativa.
  Future<void> reportarResena(int resenaId) {
    return _repository.reportarResena(resenaId: resenaId, token: _token);
  }
}
