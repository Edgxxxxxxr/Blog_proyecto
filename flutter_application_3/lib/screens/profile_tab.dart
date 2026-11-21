/// Archivo: profile_tab.dart.
/// Presenta el perfil del usuario, su configuración y los accesos a sus listas personales.

import 'package:flutter/material.dart';

import '../viewmodels/profile_view_model.dart';
import '../widgets/movie_theme.dart';
import 'my_reviews_page.dart';

/// Perfil: la pantalla presenta datos y delega cambios al ProfileViewModel.
class ProfileTab extends StatefulWidget {
  final String token;
  final Map<String, dynamic> usuario;
  final VoidCallback onOpenFavorites;

  /// Crea el componente ProfileTab con los valores que necesita para funcionar.
  const ProfileTab({
    super.key,
    required this.token,
    required this.usuario,
    required this.onOpenFavorites,
  });

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

/// Lee el perfil del ViewModel y coordina las opciones disponibles al usuario.
class _ProfileTabState extends State<ProfileTab> {
  late final ProfileViewModel _viewModel;
  late final TextEditingController _nombre;
  late final TextEditingController _correo;
  late final TextEditingController _direccion;
  bool _mostrarConfiguracion = false;

  /// Inicializa el estado y los recursos que necesita la pantalla.
  @override
  void initState() {
    super.initState();
    _viewModel = ProfileViewModel(
      token: widget.token,
      usuarioInicial: widget.usuario,
    );
    _nombre = TextEditingController(text: _viewModel.perfil.nombre);
    _correo = TextEditingController(text: _viewModel.perfil.correo);
    _direccion = TextEditingController(text: _viewModel.perfil.direccion ?? '');
  }

  /// Marca el ViewModel como cerrado y libera el notificador base.
  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _direccion.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  /// Valida los campos del perfil, guarda cambios y muestra la respuesta.
  Future<void> _guardarPerfil() async {
    try {
      await _viewModel.guardarPerfil(
        nombre: _nombre.text,
        correo: _correo.text,
        direccion: _direccion.text,
      );
      if (!mounted) return;
      _nombre.text = _viewModel.perfil.nombre;
      _correo.text = _viewModel.perfil.correo;
      _direccion.text = _viewModel.perfil.direccion ?? '';
      _aviso('Perfil actualizado.');
    } catch (error) {
      if (mounted) {
        _aviso(error.toString().replaceFirst('FormatException: ', ''));
      }
    }
  }

  /// Muestra un mensaje breve de confirmación o error.
  void _aviso(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  /// Construye un campo etiquetado para editar los datos del perfil.
  Widget _campo({
    required String etiqueta,
    required TextEditingController controller,
    TextInputType? tipo,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: tipo,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: etiqueta,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF1F2937),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  /// Construye una fila accesible que ejecuta una acción del perfil.
  Widget _opcion(IconData icono, String texto, VoidCallback accion) {
    return Card(
      color: const Color(0xFF1F2937),
      child: ListTile(
        leading: Icon(icono, color: movieGold),
        title: Text(texto, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white70),
        onTap: accion,
      ),
    );
  }

  /// Muestra el resumen del perfil y accesos a las opciones personales.
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) => ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const SizedBox(height: 10),
          const CircleAvatar(
            radius: 40,
            backgroundColor: movieSurface,
            child: Icon(Icons.person, color: movieGold, size: 46),
          ),
          const SizedBox(height: 10),
          Text(
            _viewModel.perfil.nombre,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _viewModel.perfil.correo,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 18),
          _opcion(
            Icons.settings_outlined,
            _mostrarConfiguracion ? 'Ocultar configuración' : 'Configuración',
            () => setState(() {
              _mostrarConfiguracion = !_mostrarConfiguracion;
            }),
          ),
          if (_mostrarConfiguracion) ...[
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Datos personales',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _campo(etiqueta: 'Nombre', controller: _nombre),
            _campo(
              etiqueta: 'Correo electrónico',
              controller: _correo,
              tipo: TextInputType.emailAddress,
            ),
            _campo(etiqueta: 'Dirección', controller: _direccion),
            FilledButton(
              onPressed: _viewModel.guardando ? null : _guardarPerfil,
              child: Text(
                _viewModel.guardando ? 'Guardando...' : 'Guardar cambios',
              ),
            ),
            const SizedBox(height: 12),
          ],
          _opcion(Icons.star_outline, 'Mis calificaciones', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MyReviewsPage(token: widget.token),
              ),
            );
          }),
          _opcion(
            Icons.favorite_border,
            'Mis favoritos',
            widget.onOpenFavorites,
          ),
          _opcion(
            Icons.logout,
            'Cerrar sesión',
            () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            ),
          ),
        ],
      ),
    );
  }
}
