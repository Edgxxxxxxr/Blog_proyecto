/// Archivo: comentario_model.dart.
/// Representa un comentario y define su conversión con la API.

class ComentarioModel {
  final int id;
  final String comentario;
  final String fecha;
  final int estatus;
  final int usuarioId;
  final int blogId;

  /// Construye un comentario con sus identificadores y fecha de publicación.
  ComentarioModel({
    required this.id,
    required this.comentario,
    required this.fecha,
    required this.estatus,
    required this.usuarioId,
    required this.blogId,
  });

  factory ComentarioModel.fromJson(Map<String, dynamic> json) {
    return ComentarioModel(
      id: json['id_com'] as int,
      comentario: json['comentario'] as String,
      fecha: json['fecha'] as String,
      estatus: json['estatus'] as int,
      usuarioId: json['usr_id'] as int,
      blogId: json['blog_id'] as int,
    );
  }

  /// Convierte los datos del modelo al formato JSON que espera la API.
  Map<String, dynamic> toJsonCrear() {
    return {
      'comentario': comentario,
      'usr_id': usuarioId,
      'blog_id': blogId,
    };
  }
}
