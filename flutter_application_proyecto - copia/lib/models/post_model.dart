class PostModel {
  final int id;
  final String titulo;
  final String descripcion;
  final String imagen;
  final String tags;


  PostModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.imagen,
    required this.tags,
  });


  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id_blog'] as int,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String? ?? '',
      imagen: json['img'] as String? ?? '',
      tags: json['tags'] as String? ?? '',
    );
  }
}
