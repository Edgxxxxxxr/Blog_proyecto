/// Archivo: favorites_view_model.dart.
/// Mantiene el estado de favoritos y coordina su carga y eliminación.

import '../models/pelicula_model.dart';
import '../repositories/movie_repository.dart';
import 'view_model.dart';

/// Estado y operaciones de la lista de favoritos del usuario.
class FavoritesViewModel extends ViewModel {
  final MovieRepository _repository;
  final String _token;

  FavoritesViewModel({required String token, MovieRepository? repository})
    : _token = token,
      _repository = repository ?? MovieRepository() {
    cargarFavoritos();
  }

  List<PeliculaModel> favoritos = [];
  bool cargando = true;
  String? error;

  /// Lee la lista persistida en la API.
  Future<void> cargarFavoritos() async {
    cargando = true;
    error = null;
    notifyListeners();

    try {
      favoritos = await _repository.obtenerFavoritos(_token);
    } catch (exception) {
      error = exception.toString().replaceFirst('Exception: ', '');
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  /// Quita una película y vuelve a consultar la lista actualizada.
  Future<void> quitar(PeliculaModel pelicula) async {
    await _repository.cambiarFavorito(
      peliculaId: pelicula.id,
      token: _token,
      agregar: false,
    );
    await cargarFavoritos();
  }
}
