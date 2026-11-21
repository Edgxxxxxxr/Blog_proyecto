/// Archivo: my_reviews_page.dart.
/// Presenta las calificaciones y reseñas creadas por la persona usuaria.

import 'package:flutter/material.dart';

import '../viewmodels/my_reviews_view_model.dart';
import '../widgets/movie_theme.dart';

/// Calificaciones propias; la pantalla solo representa el estado del ViewModel.
class MyReviewsPage extends StatefulWidget {
  final String token;

  const MyReviewsPage({super.key, required this.token});

  @override
  State<MyReviewsPage> createState() => _MyReviewsPageState();
}

/// Solicita las reseñas propias y actualiza la vista según su resultado.
class _MyReviewsPageState extends State<MyReviewsPage> {
  late final MyReviewsViewModel _viewModel;

  /// Inicializa el estado y los recursos que necesita la pantalla.
  @override
  void initState() {
    super.initState();
    _viewModel = MyReviewsViewModel(token: widget.token);
  }

  /// Marca el ViewModel como cerrado y libera el notificador base.
  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  /// Presenta las reseñas propias con sus películas y calificaciones.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: movieBackground,
      appBar: AppBar(
        backgroundColor: movieBackground,
        foregroundColor: Colors.white,
        title: const Text('Mis calificaciones'),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          if (_viewModel.cargando) {
            return const Center(
              child: CircularProgressIndicator(color: movieGold),
            );
          }
          if (_viewModel.error != null) {
            return Center(
              child: Text(
                'No se pudieron cargar tus calificaciones: ${_viewModel.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            );
          }
          if (_viewModel.resenas.isEmpty) {
            return const Center(
              child: Text(
                'Todavía no has calificado películas.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: _viewModel.resenas.length,
            itemBuilder: (context, index) {
              final resena = _viewModel.resenas[index];
              return Card(
                color: const Color(0xFF1F2937),
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(
                    resena.tituloPelicula ?? 'Película',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    resena.comentario.isEmpty
                        ? 'Sin comentario'
                        : resena.comentario,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: Text(
                    '★ ${resena.calificacion}/5',
                    semanticsLabel:
                        'Calificación: ${resena.calificacion} de 5 estrellas',
                    style: const TextStyle(color: movieGold),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
