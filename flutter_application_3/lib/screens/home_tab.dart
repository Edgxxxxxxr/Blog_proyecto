/// Archivo: home_tab.dart.
/// Presenta el inicio, el carrusel de películas destacadas y el catálogo popular.

import 'package:flutter/material.dart';

import '../models/pelicula_model.dart';
import '../viewmodels/home_view_model.dart';
import '../widgets/movie_card.dart';
import '../widgets/movie_poster.dart';
import '../widgets/movie_theme.dart';

/// Inicio: presenta el catálogo y envía las acciones al HomeViewModel.
class HomeTab extends StatefulWidget {
  final String token;
  final String nombreUsuario;
  final ValueChanged<PeliculaModel> onOpenMovie;

  /// Crea el componente HomeTab con los valores que necesita para funcionar.
  const HomeTab({
    super.key,
    required this.token,
    required this.nombreUsuario,
    required this.onOpenMovie,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

/// Gestiona la carga del catálogo inicial y las acciones del carrusel.
class _HomeTabState extends State<HomeTab> {
  late final HomeViewModel _viewModel;
  final PageController _pageController = PageController();

  /// Inicializa el estado y los recursos que necesita la pantalla.
  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel(token: widget.token);
  }

  /// Marca el ViewModel como cerrado y libera el notificador base.
  @override
  void dispose() {
    _pageController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  /// Presenta el carrusel destacado y el catálogo inicial de películas.
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        if (_viewModel.cargando) {
          return const Center(
            child: CircularProgressIndicator(color: movieGold),
          );
        }
        if (_viewModel.error != null) {
          return _mensaje(
            'No se pudo cargar el catálogo.',
            detalle: _viewModel.error,
            accion: _viewModel.cargarPeliculas,
          );
        }

        final peliculas = _viewModel.peliculas;
        if (peliculas.isEmpty) {
          return _mensaje('Aún no hay películas publicadas.');
        }

        // El carrusel usa hasta cinco películas para mantener los puntos legibles.
        final destacadas = peliculas.take(5).toList();
        return RefreshIndicator(
          onRefresh: _viewModel.cargarPeliculas,
          color: movieGold,
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Text(
                'Hola, ${widget.nombreUsuario}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Descubre qué ver hoy',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 22),
              const Text(
                'Película destacada',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 205,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: destacadas.length,
                  onPageChanged: _viewModel.seleccionarDestacada,
                  itemBuilder: (context, indice) =>
                      _destacada(destacadas[indice]),
                ),
              ),
              if (destacadas.length > 1) ...[
                const SizedBox(height: 10),
                _indicadoresCarrusel(destacadas.length),
              ],
              const SizedBox(height: 24),
              const Text(
                'Películas populares',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              // Convierte cada película cargada en una tarjeta del catálogo.
              ...peliculas.map(
                (pelicula) => MovieCard(
                  pelicula: pelicula,
                  onTap: () => widget.onOpenMovie(pelicula),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Puntos táctiles que muestran y cambian la película destacada.
  Widget _indicadoresCarrusel(int cantidad) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      // Genera un control por cada elemento solicitado para la interfaz.
      children: List.generate(cantidad, (indice) {
        final seleccionado = indice == _viewModel.indiceDestacado;
        void onSeleccionar() {
          _pageController.animateToPage(
            indice,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
          );
        }

        return Semantics(
          button: true,
          selected: seleccionado,
          label: 'Película destacada ${indice + 1} de $cantidad',
          onTap: onSeleccionar,
          child: SizedBox(
            width: 48,
            height: 48,
            child: InkWell(
              excludeFromSemantics: true,
              borderRadius: BorderRadius.circular(24),
              onTap: onSeleccionar,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: seleccionado ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: seleccionado ? movieGold : Colors.white54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  /// Construye la tarjeta visual de la película destacada.
  Widget _destacada(PeliculaModel pelicula) {
    return InkWell(
      onTap: () => widget.onOpenMovie(pelicula),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 205,
        decoration: BoxDecoration(
          color: movieSurface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            MoviePoster(
              imagePath: pelicula.imagen,
              semanticLabel: 'Cartel de ${pelicula.titulo}',
              width: double.infinity,
              height: 205,
              borderRadius: BorderRadius.circular(18),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xE6000000)],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pelicula.titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      if (pelicula.anio != null) pelicula.anio!,
                      if (pelicula.duracion != null) pelicula.duracion!,
                    ].join(' · '),
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '★ ${pelicula.calificacionPromedio.toStringAsFixed(1)}',
                    style: const TextStyle(color: movieGold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mensaje(
    String mensaje, {
    String? detalle,
    // Acción opcional que se ofrece junto al mensaje de estado.
    Future<void> Function()? accion,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.movie_filter_outlined, color: movieGold, size: 48),
            const SizedBox(height: 10),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
            if (detalle != null) ...[
              const SizedBox(height: 8),
              Text(
                detalle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
            if (accion != null) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: accion,
                child: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
