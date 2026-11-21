/// Archivo: user_service.dart.
/// Consulta, crea, actualiza y elimina cuentas mediante los endpoints de la API.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

/// Centraliza las solicitudes de perfil y administración de usuarios.
class UserService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  /// Consulta el perfil que corresponde al token, sin recibir un ID del cliente.
  Future<UserModel> obtenerMiPerfil(String token) async {
    final respuesta = await http
        .get(
          Uri.parse('$baseUrl/usuarios/me'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 10));

    if (respuesta.statusCode == 200) {
      return UserModel.fromJson(
        jsonDecode(respuesta.body) as Map<String, dynamic>,
      );
    }
    throw Exception(_mensajeError(respuesta));
  }

  /// Actualiza los datos del perfil autenticado; el rol no viaja en la petición.
  Future<UserModel> actualizarMiPerfil({
    required String token,
    required String nombre,
    required String correo,
    String? direccion,
  }) async {
    final respuesta = await http
        .put(
          Uri.parse('$baseUrl/usuarios/me'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'nom_usr': nombre.trim(),
            'mail': correo.trim().toLowerCase(),
            'dir_usr': direccion?.trim(),
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (respuesta.statusCode == 200) {
      return UserModel.fromJson(
        jsonDecode(respuesta.body) as Map<String, dynamic>,
      );
    }
    throw Exception(_mensajeError(respuesta));
  }

  Future<List<UserModel>> obtenerUsuarios() async {
    final respuesta = await http
        .get(Uri.parse('$baseUrl/usuarios'))
        .timeout(const Duration(seconds: 10));

    if (respuesta.statusCode != 200) {
      throw Exception(
        'Error al consultar usuarios: ${respuesta.statusCode}',
      );
    }

    final List<dynamic> datos = jsonDecode(respuesta.body);

    return datos
        // Convierte cada elemento de la colección al tipo que consume la interfaz.
        .map(
          (json) => UserModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  /// Envía los datos de una cuenta nueva y convierte la respuesta al modelo local.
  Future<UserModel> agregarUsuario(UserModel usuario) async {
    final respuesta = await http
        .post(
          Uri.parse('$baseUrl/usuarios'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(usuario.toJsonCrear()),
        )
        .timeout(const Duration(seconds: 10));

    if (respuesta.statusCode == 201) {
      return UserModel.fromJson(
        jsonDecode(respuesta.body) as Map<String, dynamic>,
      );
    }

    throw Exception(_mensajeError(respuesta));
  }

  /// Valida y guarda los cambios de actualizarUsuario.
  Future<UserModel> actualizarUsuario(UserModel usuario) async {
    final respuesta = await http
        .put(
          Uri.parse('$baseUrl/usuarios/${usuario.id}'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'nom_usr': usuario.nombre,
            'mail': usuario.correo,
            'dir_usr': usuario.direccion,
            'tip_usu': usuario.tipoUsuario,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (respuesta.statusCode == 200) {
      return UserModel.fromJson(
        jsonDecode(respuesta.body) as Map<String, dynamic>,
      );
    }

    throw Exception(_mensajeError(respuesta));
  }

  /// Confirma y ejecuta la eliminación de eliminarUsuario.
  Future<void> eliminarUsuario(int id) async {
    final respuesta = await http
        .delete(Uri.parse('$baseUrl/usuarios/$id'))
        .timeout(const Duration(seconds: 10));

    if (respuesta.statusCode != 200 &&
        respuesta.statusCode != 204) {
      throw Exception(_mensajeError(respuesta));
    }
  }

  /// Extrae el detalle de error del servidor o genera un mensaje HTTP genérico.
  String _mensajeError(http.Response respuesta) {
    try {
      final datos = jsonDecode(respuesta.body);

      if (datos is Map && datos['detail'] != null) {
        return datos['detail'].toString();
      }
    } catch (_) {
      // La respuesta no contiene JSON.
    }

    return 'Error HTTP ${respuesta.statusCode}: ${respuesta.body}';
  }
}
