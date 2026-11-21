/// Archivo: resena_model.dart.
/// Representa una reseña de película con autor, puntuación, comentario y fecha.

/// Reseña pública asociada a una película y a su autor.
class ResenaModel {
  final int id;
  final int usuarioId;
  final int peliculaId;
  final String nombreUsuario;
  final String? tituloPelicula;
  final String comentario;
  final DateTime? fecha;
  final int calificacion;

  /// Construye una reseña local con su autor, película, texto y calificación.
  const ResenaModel({
    required this.id,
    required this.usuarioId,
    required this.peliculaId,
    required this.nombreUsuario,
    this.tituloPelicula,
    required this.comentario,
    required this.fecha,
    required this.calificacion,
  });

  /// Lee una reseña devuelta por la API de usuario.
  factory ResenaModel.fromJson(Map<String, dynamic> json) {
    return ResenaModel(
      id: (json['id_com'] as num).toInt(),
      usuarioId: (json['usr_id'] as num?)?.toInt() ?? 0,
      peliculaId: (json['blog_id'] as num).toInt(),
      nombreUsuario: json['nombre_usuario']?.toString() ?? 'Tú',
      tituloPelicula: json['titulo_pelicula']?.toString(),
      comentario: json['comentario']?.toString() ?? '',
      fecha: DateTime.tryParse(json['fecha']?.toString() ?? ''),
      calificacion: (json['calificacion'] as num?)?.toInt() ?? 0,
    );
  }
}
