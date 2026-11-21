/// Archivo: movie_service.dart.
/// Realiza las solicitudes HTTP del catálogo, las reseñas y los favoritos del usuario.

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pelicula_model.dart';
import '../models/resena_model.dart';
import 'auth_service.dart';

/// Centraliza las llamadas HTTP de las vistas del usuario.
class MovieService {
  static const String _baseUrl = AuthService.baseUrl;

  /// Crea las cabeceras JSON y de autenticación para las peticiones protegidas.
  Map<String, String> _headers(String token) => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  /// Convierte errores de FastAPI a mensajes que puede mostrar la interfaz.
  Exception _error(http.Response response) {
    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      if (body is Map && body['detail'] != null) {
        return Exception(body['detail'].toString());
      }
    } catch (_) {
      // La respuesta no contenía JSON.
    }
    return Exception('Error HTTP ${response.statusCode}');
  }

  /// Consulta el catálogo y opcionalmente filtra por título.
  Future<List<PeliculaModel>> obtenerPeliculas({
    required String token,
    String consulta = '',
  }) async {
    final uri = Uri.parse('$_baseUrl/peliculas').replace(
      queryParameters: consulta.trim().isEmpty ? null : {'q': consulta.trim()},
    );
    final response = await http
        .get(uri, headers: _headers(token))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) throw _error(response);
    final datos = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return datos
        // Convierte cada elemento de la colección al tipo que consume la interfaz.
        .map(
          (item) =>
              PeliculaModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  /// Obtiene una película y sus datos agregados de calificación.
  Future<PeliculaModel> obtenerPelicula({
    required int peliculaId,
    required String token,
  }) async {
    final response = await http
        .get(
          Uri.parse('$_baseUrl/peliculas/$peliculaId'),
          headers: _headers(token),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) throw _error(response);
    return PeliculaModel.fromJson(
      Map<String, dynamic>.from(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map,
      ),
    );
  }

  /// Recupera únicamente las reseñas publicadas de una película.
  Future<List<ResenaModel>> obtenerResenas({
    required int peliculaId,
    required String token,
  }) async {
    final response = await http
        .get(
          Uri.parse('$_baseUrl/peliculas/$peliculaId/resenas'),
          headers: _headers(token),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) throw _error(response);
    final datos = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return datos
        // Convierte cada elemento de la colección al tipo que consume la interfaz.
        .map(
          (item) =>
              ResenaModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  /// Consulta las reseñas del usuario para la sección de calificaciones.
  Future<List<ResenaModel>> obtenerMisResenas(String token) async {
    final response = await http
        .get(
          Uri.parse('$_baseUrl/usuarios/me/resenas'),
          headers: _headers(token),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) throw _error(response);
    final datos = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return datos
        // Convierte cada elemento de la colección al tipo que consume la interfaz.
        .map(
          (item) =>
              ResenaModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  /// Obtiene favoritos guardados por el usuario conectado.
  Future<List<PeliculaModel>> obtenerFavoritos(String token) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/favoritos'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) throw _error(response);
    final datos = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return datos
        // Convierte cada elemento de la colección al tipo que consume la interfaz.
        .map(
          (item) =>
              PeliculaModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  /// Agrega o quita un favorito mediante la misma operación autenticada.
  Future<void> cambiarFavorito({
    required int peliculaId,
    required String token,
    required bool agregar,
  }) async {
    final uri = Uri.parse('$_baseUrl/favoritos/$peliculaId');
    final response = agregar
        ? await http.put(uri, headers: _headers(token))
        : await http.delete(uri, headers: _headers(token));

    if (response.statusCode != 204) throw _error(response);
  }

  /// Publica la calificación y el comentario opcional.
  Future<ResenaModel> publicarResena({
    required int peliculaId,
    required String token,
    required int calificacion,
    required String comentario,
  }) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/peliculas/$peliculaId/resenas'),
          headers: _headers(token),
          body: jsonEncode({
            'calificacion': calificacion,
            'comentario': comentario.trim(),
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 201) throw _error(response);
    return ResenaModel.fromJson(
      Map<String, dynamic>.from(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map,
      ),
    );
  }

  /// Envía el reporte de una reseña para revisión administrativa.
  Future<void> reportarResena({
    required int resenaId,
    required String token,
  }) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/resenas/$resenaId/reportes'),
          headers: _headers(token),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 201) throw _error(response);
  }
}
