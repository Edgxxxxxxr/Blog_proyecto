import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/post_model.dart';

class PostService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  Future<PostModel> agregarPost({
    required String titulo,
    required String descripcion,
    required Uint8List imagenBytes,
    required String nombreArchivo,
    String? tags,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/blog'),
    );

    request.headers['Accept'] = 'application/json';
    request.fields['titulo'] = titulo.trim();
    request.fields['descripcion'] = descripcion.trim();

    if (tags != null && tags.trim().isNotEmpty) {
      request.fields['tags'] = tags.trim();
    }

    request.files.add(
      http.MultipartFile.fromBytes(
        'imagen',
        imagenBytes,
        filename: nombreArchivo,
      ),
    );

    final streamedResponse = await request
        .send()
        .timeout(const Duration(seconds: 20));
    final respuesta = await http.Response.fromStream(streamedResponse);

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

    throw Exception(
      'No se pudo guardar la publicación (HTTP ${respuesta.statusCode})',
    );
  }

  Future<List<PostModel>> obtenerPosts() async {
    final respuesta = await http.get(
      Uri.parse('$baseUrl/blog'),
    );

    if (respuesta.statusCode != 200) {
      throw Exception('Error al consultar publicaciones');
    }

    final List<dynamic> datos = jsonDecode(respuesta.body);

    return datos
        .map(
          (json) => PostModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}
