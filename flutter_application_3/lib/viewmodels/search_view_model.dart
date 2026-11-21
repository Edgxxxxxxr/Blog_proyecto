/// Archivo: search_view_model.dart.
/// Mantiene el estado de búsqueda y descarta respuestas atrasadas.

import '../models/pelicula_model.dart';
import '../repositories/movie_repository.dart';
import 'view_model.dart';

/// Estado y búsqueda del catálogo por título.
class SearchViewModel extends ViewModel {
  final MovieRepository _repository;
  final String _token;
  int _requestId = 0;

  SearchViewModel({required String token, MovieRepository? repository})
    : _token = token,
      _repository = repository ?? MovieRepository();

  List<PeliculaModel> resultados = [];
  bool cargando = false;
  String? error;

  /// Ignora respuestas antiguas cuando la persona sigue escribiendo.
  Future<void> buscar(String texto) async {
    final requestId = ++_requestId;
    cargando = true;
    error = null;
    notifyListeners();

    try {
      final peliculas = await _repository.obtenerPeliculas(
        token: _token,
        consulta: texto,
      );
      if (requestId != _requestId) return;
      resultados = peliculas;
    } catch (exception) {
      if (requestId != _requestId) return;
      error = exception.toString().replaceFirst('Exception: ', '');
    } finally {
      if (requestId == _requestId) {
        cargando = false;
        notifyListeners();
      }
    }
  }
}
