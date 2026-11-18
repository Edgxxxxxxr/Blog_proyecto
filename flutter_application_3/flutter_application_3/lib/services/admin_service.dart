
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'dart:typed_data';

class AdminService {

// =====================================
// SUBIR IMAGEN
// =====================================

Future<String> subirImagen({
  required Uint8List bytes,
  required String nombre,
}) async {
  final peticion = http.MultipartRequest(
    'POST',
    Uri.parse('$baseUrl/admin/imagenes'),
  );

  peticion.headers['Authorization'] =
      'Bearer $token';

  peticion.headers['Accept'] =
      'application/json';

  peticion.files.add(
    http.MultipartFile.fromBytes(
      'imagen',
      bytes,
      filename: nombre,
    ),
  );

  final respuesta = await http.Response.fromStream(
    await peticion.send(),
  ).timeout(const Duration(seconds: 30));

  final datos = jsonDecode(
    utf8.decode(respuesta.bodyBytes),
  );

  if (respuesta.statusCode == 201) {
    return datos['img'].toString();
  }

  throw Exception(
    datos['detail'] ?? 'Error al subir la imagen',
  );
}


  static const String baseUrl = AuthService.baseUrl;

  final String token;

  AdminService(this.token);

  Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // Realizar solicitudes a FastAPI
  Future<dynamic> solicitud(
    String metodo,
    String ruta, {
    Map<String, dynamic>? datos,
  }) async {
    final peticion = http.Request(
      metodo,
      Uri.parse('$baseUrl$ruta'),
    );

    peticion.headers.addAll(headers);

    if (datos != null) {
      peticion.body = jsonEncode(datos);
    }

    final respuesta = await http.Response.fromStream(
      await peticion.send(),
    ).timeout(const Duration(seconds: 15));

    final contenido = utf8.decode(respuesta.bodyBytes);

    dynamic resultado;

    try {
      resultado = jsonDecode(contenido);
    } catch (_) {
      resultado = contenido;
    }

    if (respuesta.statusCode >= 200 &&
        respuesta.statusCode < 300) {
      return resultado;
    }

    if (respuesta.statusCode == 401) {
      throw Exception(
        'La sesión venció. Inicia sesión nuevamente.',
      );
    }

    if (respuesta.statusCode == 403) {
      throw Exception(
        'No tienes permisos de administrador.',
      );
    }

    if (resultado is Map &&
        resultado['detail'] != null) {
      throw Exception(resultado['detail'].toString());
    }

    throw Exception(
      'Error HTTP ${respuesta.statusCode}',
    );
  }

  // ESTADÍSTICAS
  Future<Map<String, dynamic>> obtenerEstadisticas() async {
    final datos = await solicitud(
      'GET',
      '/admin/estadisticas',
    );

    return Map<String, dynamic>.from(datos);
  }

  // PELÍCULAS
  Future<List<Map<String, dynamic>>> obtenerPeliculas() async {
    final datos = await solicitud(
      'GET',
      '/admin/peliculas',
    );

    return List<Map<String, dynamic>>.from(datos);
  }

  Future<void> agregarPelicula(
    Map<String, dynamic> datos,
  ) async {
    await solicitud(
      'POST',
      '/admin/peliculas',
      datos: datos,
    );
  }

  Future<void> editarPelicula(
    int id,
    Map<String, dynamic> datos,
  ) async {
    await solicitud(
      'PUT',
      '/admin/peliculas/$id',
      datos: datos,
    );
  }

  Future<void> eliminarPelicula(int id) async {
    await solicitud(
      'DELETE',
      '/admin/peliculas/$id',
    );
  }

  // USUARIOS
  Future<List<Map<String, dynamic>>> obtenerUsuarios() async {
    final datos = await solicitud(
      'GET',
      '/admin/usuarios',
    );

    return List<Map<String, dynamic>>.from(datos);
  }

  Future<void> agregarUsuario(
    Map<String, dynamic> datos,
  ) async {
    await solicitud(
      'POST',
      '/admin/usuarios',
      datos: datos,
    );
  }

  Future<void> editarUsuario(
    int id,
    Map<String, dynamic> datos,
  ) async {
    await solicitud(
      'PUT',
      '/admin/usuarios/$id',
      datos: datos,
    );
  }

  Future<void> eliminarUsuario(int id) async {
    await solicitud(
      'DELETE',
      '/admin/usuarios/$id',
    );
  }

  // RESEÑAS
  Future<List<Map<String, dynamic>>> obtenerResenas() async {
    final datos = await solicitud(
      'GET',
      '/admin/resenas',
    );

    return List<Map<String, dynamic>>.from(datos);
  }

  Future<void> moderarResena(
    int id,
    int estatus,
  ) async {
    await solicitud(
      'PUT',
      '/admin/resenas/$id',
      datos: {'estatus': estatus},
    );
  }

  Future<void> eliminarResena(int id) async {
    await solicitud(
      'DELETE',
      '/admin/resenas/$id',
    );
  }
}
