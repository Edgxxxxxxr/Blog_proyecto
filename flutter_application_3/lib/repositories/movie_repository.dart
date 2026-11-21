/// Archivo: movie_repository.dart.
/// Agrupa el acceso a películas, reseñas y favoritos detrás de una interfaz estable.

import '../models/pelicula_model.dart';
import '../models/resena_model.dart';
import '../services/movie_service.dart';

/// Reúne el acceso a los datos de películas detrás de una interfaz estable.
class MovieRepository {
  final MovieService _service;

  MovieRepository({MovieService? service})
    : _service = service ?? MovieService();

  Future<List<PeliculaModel>> obtenerPeliculas({
    required String token,
    String consulta = '',
  }) {
    // Delega la consulta y el filtro de título a la capa de servicio.
    return _service.obtenerPeliculas(token: token, consulta: consulta);
  }

  /// Solicita los datos y las calificaciones agregadas de una película.
  Future<PeliculaModel> obtenerPelicula({
    required int peliculaId,
    required String token,
  }) {
    return _service.obtenerPelicula(peliculaId: peliculaId, token: token);
  }

  Future<List<ResenaModel>> obtenerResenas({
    required int peliculaId,
    required String token,
  }) {
    return _service.obtenerResenas(peliculaId: peliculaId, token: token);
  }

  Future<List<ResenaModel>> obtenerMisResenas(String token) {
    return _service.obtenerMisResenas(token);
  }

  Future<List<PeliculaModel>> obtenerFavoritos(String token) {
    return _service.obtenerFavoritos(token);
  }

  /// Envía la operación de favorito y sincroniza el detalle.
  Future<void> cambiarFavorito({
    required int peliculaId,
    required String token,
    required bool agregar,
  }) {
    return _service.cambiarFavorito(
      peliculaId: peliculaId,
      token: token,
      agregar: agregar,
    );
  }

  /// Delega la publicación de una reseña y devuelve el registro creado.
  Future<ResenaModel> publicarResena({
    required int peliculaId,
    required String token,
    required int calificacion,
    required String comentario,
  }) {
    return _service.publicarResena(
      peliculaId: peliculaId,
      token: token,
      calificacion: calificacion,
      comentario: comentario,
    );
  }

  /// Delega el reporte de una reseña para que el administrador lo revise.
  Future<void> reportarResena({required int resenaId, required String token}) {
    return _service.reportarResena(resenaId: resenaId, token: token);
  }
}
