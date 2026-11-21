/// Archivo: search_tab.dart.
/// Busca películas por título y presenta carga, resultados, errores o estado vacío.

import 'package:flutter/material.dart';

import '../models/pelicula_model.dart';
import '../viewmodels/search_view_model.dart';
import '../widgets/movie_card.dart';
import '../widgets/movie_theme.dart';

/// Búsqueda por título; el estado de resultados vive en SearchViewModel.
class SearchTab extends StatefulWidget {
  final String token;
  final ValueChanged<PeliculaModel> onOpenMovie;

  const SearchTab({super.key, required this.token, required this.onOpenMovie});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

/// Envía búsquedas al ViewModel y conserva el texto introducido.
class _SearchTabState extends State<SearchTab> {
  late final SearchViewModel _viewModel;
  final TextEditingController _busqueda = TextEditingController();

  /// Inicializa el estado y los recursos que necesita la pantalla.
  @override
  void initState() {
    super.initState();
    _viewModel = SearchViewModel(token: widget.token);
    _viewModel.buscar('');
  }

  /// Marca el ViewModel como cerrado y libera el notificador base.
  @override
  void dispose() {
    _busqueda.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  /// Muestra el campo de búsqueda y los resultados o estados informativos.
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
            child: TextField(
              controller: _busqueda,
              onChanged: _viewModel.buscar,
              cursorColor: movieGold,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Buscar película',
                labelStyle: const TextStyle(color: Colors.white70),
                hintText: 'Título de película',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: movieGold),
                suffixIcon: _busqueda.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Borrar búsqueda',
                        onPressed: () {
                          _busqueda.clear();
                          _viewModel.buscar('');
                        },
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                filled: true,
                fillColor: const Color(0xFF1F2937),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.white38),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.white38),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: movieGold, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 17),
              ),
            ),
          ),
          Expanded(child: _resultados()),
        ],
      ),
    );
  }

  /// Presenta carga, error, estado vacío o resultados del ViewModel.
  Widget _resultados() {
    if (_viewModel.cargando) {
      return const Center(child: CircularProgressIndicator(color: movieGold));
    }
    if (_viewModel.error != null) {
      return Center(
        child: Text(
          'No se pudo buscar: ${_viewModel.error}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70),
        ),
      );
    }
    if (_viewModel.resultados.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.movie_filter_outlined,
                color: Colors.white54,
                size: 48,
              ),
              SizedBox(height: 12),
              Text(
                'No se encontraron resultados',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      children: _viewModel.resultados
          // Convierte cada elemento de la colección al tipo que consume la interfaz.
          .map(
            (pelicula) => MovieCard(
              pelicula: pelicula,
              onTap: () => widget.onOpenMovie(pelicula),
            ),
          )
          .toList(),
    );
  }
}
