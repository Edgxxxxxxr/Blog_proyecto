/// Archivo: profile_view_model.dart.
/// Valida y guarda los datos personales del usuario.

import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import 'view_model.dart';

/// Estado y validación de los datos personales del usuario.
class ProfileViewModel extends ViewModel {
  final UserRepository _repository;
  final String _token;

  /// Crea el componente ProfileViewModel con los valores que necesita para funcionar.
  ProfileViewModel({
    required String token,
    required Map<String, dynamic> usuarioInicial,
    UserRepository? repository,
  }) : _token = token,
       _repository = repository ?? UserRepository(),
       perfil = UserModel(
         id: (usuarioInicial['id_usr'] as num?)?.toInt() ?? 0,
         nombre: usuarioInicial['nom_usr']?.toString() ?? 'Usuario',
         correo: usuarioInicial['mail']?.toString() ?? '',
         direccion: usuarioInicial['dir_usr']?.toString(),
         tipoUsuario: (usuarioInicial['tip_usu'] as num?)?.toInt() ?? 2,
       );

  UserModel perfil;
  bool guardando = false;
  String? error;

  /// Valida y persiste los datos del perfil autenticado.
  Future<void> guardarPerfil({
    required String nombre,
    required String correo,
    String? direccion,
  }) async {
    final nombreLimpio = nombre.trim();
    final correoLimpio = correo.trim();
    if (nombreLimpio.length < 2 || !correoLimpio.contains('@')) {
      throw FormatException('Revisa tu nombre y correo electrónico.');
    }

    guardando = true;
    error = null;
    notifyListeners();
    try {
      perfil = await _repository.actualizarPerfil(
        token: _token,
        nombre: nombreLimpio,
        correo: correoLimpio,
        direccion: direccion,
      );
    } catch (exception) {
      error = exception.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      guardando = false;
      notifyListeners();
    }
  }
}
