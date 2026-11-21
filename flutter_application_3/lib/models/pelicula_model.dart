/// Archivo: pelicula_model.dart.
/// Representa una película del catálogo e interpreta sus datos y etiquetas para las vistas.

/// Guarda los datos de catálogo y expone año y duración derivados de sus etiquetas.
class PeliculaModel {
  final int id;
  final String titulo;
  final String descripcion;
  final String imagen;
  final String etiquetas;
  final double calificacionPromedio;
  final int totalResenas;
  final bool esFavorita;

  /// Construye una película con sus datos de catálogo y calificación agregada.
  const PeliculaModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.imagen,
    required this.etiquetas,
    required this.calificacionPromedio,
    required this.totalResenas,
    required this.esFavorita,
  });

  /// Convierte la respuesta JSON del backend a datos que usa Flutter.
  factory PeliculaModel.fromJson(Map<String, dynamic> json) {
    return PeliculaModel(
      id: (json['id_blog'] as num).toInt(),
      titulo: json['titulo']?.toString() ?? 'Sin título',
      descripcion: json['descripcion']?.toString() ?? '',
      imagen: json['img']?.toString() ?? '',
      etiquetas: json['tags']?.toString() ?? '',
      calificacionPromedio:
          (json['calificacion_promedio'] as num?)?.toDouble() ?? 0,
      totalResenas: (json['total_resenas'] as num?)?.toInt() ?? 0,
      esFavorita: json['es_favorita'] == true,
    );
  }

  /// Obtiene el año cuando el campo de etiquetas comienza con un año.
  String? get anio {
    final coincidencia = RegExp(r'\b(?:19|20)\d{2}\b').firstMatch(etiquetas);
    return coincidencia?.group(0);
  }

  /// Interpreta duraciones existentes como “3h 14min” o “2h 49min”.
  String? get duracion {
    final coincidencia = RegExp(
      r'(\d+)\s*h(?:\s*(\d+)\s*min)?',
      caseSensitive: false,
    ).firstMatch(etiquetas);

    if (coincidencia == null) return null;

    final horas = int.tryParse(coincidencia.group(1) ?? '') ?? 0;
    final minutos = int.tryParse(coincidencia.group(2) ?? '') ?? 0;
    if (horas == 0) return '$minutos min';
    if (minutos == 0) return '${horas}h';
    return '${horas}h ${minutos}min';
  }
}
