/// Archivo: my_reviews_view_model.dart.
/// Carga y mantiene las reseñas asociadas al usuario autenticado.

import '../models/resena_model.dart';
import '../repositories/movie_repository.dart';
import 'view_model.dart';

/// Estado de la pantalla Mis calificaciones.
class MyReviewsViewModel extends ViewModel {
  final MovieRepository _repository;
  final String _token;

  MyReviewsViewModel({required String token, MovieRepository? repository})
    : _token = token,
      _repository = repository ?? MovieRepository() {
    cargarResenas();
  }

  List<ResenaModel> resenas = [];
  bool cargando = true;
  String? error;

  /// Carga las calificaciones asociadas al token actual.
  Future<void> cargarResenas() async {
    cargando = true;
    error = null;
    notifyListeners();
    try {
      resenas = await _repository.obtenerMisResenas(_token);
    } catch (exception) {
      error = exception.toString().replaceFirst('Exception: ', '');
    } finally {
      cargando = false;
      notifyListeners();
    }
  }
}
