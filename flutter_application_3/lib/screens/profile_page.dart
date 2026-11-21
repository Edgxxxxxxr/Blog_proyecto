/// Archivo: profile_page.dart.
/// Presenta y actualiza los datos del perfil de una cuenta.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/admin_drawer.dart';

/// Permite revisar y guardar los datos del perfil.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

/// Controla los campos del perfil y guarda los cambios enviados por la persona.
class _ProfilePageState extends State<ProfilePage> {
  static const String baseUrl = 'http://127.0.0.1:8000';
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _direccion = TextEditingController();
  Map<String, dynamic> _usuario = {};
  bool _cargando = false;
  bool _inicializado = false;

  /// Actualiza los datos que dependen del contexto de la aplicación.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inicializado) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _usuario = Map<String, dynamic>.from(args);
    }

    debugPrint('DATOS RECIBIDOS EN PERFIL: $_usuario');
    debugPrint('ID DEL USUARIO: ${_usuario['id_usr']}');

    _nombre.text = _usuario['nom_usr']?.toString() ?? '';
    _correo.text = _usuario['mail']?.toString() ?? '';
    _direccion.text = _usuario['dir_usr']?.toString() ?? '';
    _inicializado = true;
  }

  /// Marca el ViewModel como cerrado y libera el notificador base.
  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _direccion.dispose();
    super.dispose();
  }

  /// Valida el formulario y envía los cambios de la publicación o perfil.
  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final id = _usuario['id_usr'];
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se recibió el identificador del usuario. Vuelve a iniciar sesión.')),
      );
      return;
    }
    setState(() => _cargando = true);
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/usuarios/$id'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'nom_usr': _nombre.text.trim(),
          'mail': _correo.text.trim().toLowerCase(),
          'dir_usr': _direccion.text.trim().isEmpty ? null : _direccion.text.trim(),
          'tip_usu': (_usuario['tip_usu'] as num?)?.toInt() ?? 1,
        }),
      ).timeout(const Duration(seconds: 10));

      final dynamic data = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      if (response.statusCode != 200) {
        final detail = data is Map ? data['detail'] : null;
        throw Exception(detail?.toString() ?? 'Error HTTP ${response.statusCode}');
      }
      if (data is Map<String, dynamic>) _usuario = Map<String, dynamic>.from(data);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar el perfil: $e')),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  /// Presenta los campos de perfil y la acción para guardar modificaciones.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      drawer: AdminDrawer(usuario: _usuario, rutaActual: '/profile'),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const CircleAvatar(
                        radius: 38,
                        child: Icon(Icons.person, size: 42),
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _nombre,
                        decoration: const InputDecoration(
                          labelText: 'Nombre completo',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.trim().length < 2
                            ? 'Ingresa un nombre válido' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _correo,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || !v.contains('@')
                            ? 'Ingresa un correo válido' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _direccion,
                        decoration: const InputDecoration(
                          labelText: 'Dirección',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _cargando ? null : _guardar,
                        icon: const Icon(Icons.save),
                        label: Text(_cargando ? 'Guardando...' : 'Guardar cambios'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
