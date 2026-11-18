import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/post_model.dart';

class PostService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  // Método anterior: se conserva para que el resto del proyecto siga funcionando.
  Future<PostModel> agregarPost({
    required String titulo,
    required String descripcion,
    String? imagen,
    String? tags,
  }) async {
    final respuesta = await http.post(
      Uri.parse('$baseUrl/blog'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'titulo': titulo.trim(),
        'descripcion': descripcion.trim(),
        'img': (imagen ?? '').trim().isEmpty ? null : imagen!.trim(),
        'tags': (tags ?? '').trim().isEmpty ? null : tags!.trim(),
      }),
    ).timeout(const Duration(seconds: 10));

    final dynamic resultado = respuesta.body.isNotEmpty
        ? jsonDecode(respuesta.body)
        : null;

    if ((respuesta.statusCode == 200 || respuesta.statusCode == 201) &&
        resultado is Map<String, dynamic>) {
      return PostModel.fromJson(resultado);
    }
    if (resultado is Map && resultado['detail'] != null) {
      throw Exception(resultado['detail'].toString());
    }
    throw Exception('No se pudo guardar la publicación (HTTP ${respuesta.statusCode})');
  }

  // Nuevo método: manda título, descripción y foto en un solo multipart/form-data.
  Future<PostModel> agregarPostConFoto({
    required String titulo,
    required String descripcion,
    required Uint8List imagenBytes,
    required String nombreArchivo,
    String? tags,
  }) async {
    final peticion = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/blog/foto'),
    );
    peticion.fields['titulo'] = titulo.trim();
    peticion.fields['descripcion'] = descripcion.trim();
    if (tags != null && tags.trim().isNotEmpty) {
      peticion.fields['tags'] = tags.trim();
    }
    peticion.files.add(http.MultipartFile.fromBytes(
      'imagen',
      imagenBytes,
      filename: nombreArchivo,
    ));

    final respuestaStreaming = await peticion.send()
        .timeout(const Duration(seconds: 30));
    final respuesta = await http.Response.fromStream(respuestaStreaming);
    final dynamic resultado = respuesta.body.isNotEmpty
        ? jsonDecode(respuesta.body)
        : null;

    if ((respuesta.statusCode == 200 || respuesta.statusCode == 201) &&
        resultado is Map<String, dynamic>) {
      return PostModel.fromJson(resultado);
    }
    if (resultado is Map && resultado['detail'] != null) {
      throw Exception(resultado['detail'].toString());
    }
    throw Exception('No se pudo guardar la foto (HTTP ${respuesta.statusCode})');
  }

  Future<List<PostModel>> obtenerPosts() async {
    final respuesta = await http.get(Uri.parse('$baseUrl/blog'));
    if (respuesta.statusCode != 200) {
      throw Exception('Error al consultar publicaciones');
    }
    final List<dynamic> datos = jsonDecode(respuesta.body);
    return datos
        .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
