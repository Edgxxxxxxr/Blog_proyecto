/// Archivo: view_model.dart.
/// Proporciona notificaciones seguras para ViewModels que pueden cerrarse durante una solicitud.

import 'package:flutter/foundation.dart';

/// Notifier base que ignora notificaciones si una petición termina tras cerrar la vista.
abstract class ViewModel extends ChangeNotifier {
  bool _disposed = false;

  /// Notifica cambios únicamente mientras el ViewModel sigue activo.
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  /// Marca el ViewModel como cerrado y libera el notificador base.
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
