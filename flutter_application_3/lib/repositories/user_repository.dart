/// Archivo: user_repository.dart.
/// Agrupa las operaciones de perfil y evita que la vista dependa del servicio HTTP.

import '../models/user_model.dart';
import '../services/user_service.dart';

/// Encapsula las operaciones de perfil que usan las vistas del usuario.
class UserRepository {
  final UserService _service;

  UserRepository({UserService? service}) : _service = service ?? UserService();

  /// Valida y guarda los cambios de actualizarPerfil.
  Future<UserModel> actualizarPerfil({
    required String token,
    required String nombre,
    required String correo,
    String? direccion,
  }) {
    return _service.actualizarMiPerfil(
      token: token,
      nombre: nombre,
      correo: correo,
      direccion: direccion,
    );
  }
}
