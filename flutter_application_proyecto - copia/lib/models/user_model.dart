class UserModel {
  final int id;
  final String nombre;
  final String correo;
  final String? password;
  final String? direccion;
  final int tipoUsuario;

  UserModel({
    required this.id,
    required this.nombre,
    required this.correo,
    this.password,
    this.direccion,
    this.tipoUsuario = 1,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id_usr'] as int,
      nombre: json['nom_usr'] as String,
      correo: json['mail'] as String,
      direccion: json['dir_usr'] as String?,
      tipoUsuario: json['tip_usr'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJsonCrear() {
  return {
    'nom_usr': nombre,
    'mail': correo,
    'password': password,
    'dir_usr': direccion,
    'tip_usu': tipoUsuario,
  };
}
}