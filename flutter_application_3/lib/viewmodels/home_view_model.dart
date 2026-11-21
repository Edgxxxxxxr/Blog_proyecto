/// Archivo: home_view_model.dart.
/// Mantiene el catálogo de inicio y la selección actual del carrusel.

import '../models/pelicula_model.dart';
import '../repositories/movie_repository.dart';
import 'view_model.dart';

/// Estado y acciones del catálogo que se muestra en Inicio.
class HomeViewModel extends ViewModel {
  final MovieRepository _repository;
  final String _token;

  HomeViewModel({required String token, MovieRepository? repository})
    : _token = token,
      _repository = repository ?? MovieRepository() {
    cargarPeliculas();
  }

  List<PeliculaModel> peliculas = [];
  int indiceDestacado = 0;
  bool cargando = true;
  String? error;

  /// Recupera el catálogo y reinicia el índice si cambió su tamaño.
  Future<void> cargarPeliculas() async {
    cargando = true;
    error = null;
    notifyListeners();

    try {
      peliculas = await _repository.obtenerPeliculas(token: _token);
      if (indiceDestacado >= peliculas.take(5).length) {
        indiceDestacado = 0;
      }
    } catch (exception) {
      error = exception.toString().replaceFirst('Exception: ', '');
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  /// Cambia el elemento destacado del carrusel.
  void seleccionarDestacada(int indice) {
    if (indice < 0 || indice >= peliculas.take(5).length) return;
    indiceDestacado = indice;
    notifyListeners();
  }
}
