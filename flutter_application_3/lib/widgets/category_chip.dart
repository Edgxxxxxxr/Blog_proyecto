/// Archivo: category_chip.dart.
/// Representa una categoría como una etiqueta visual seleccionable.

import 'package:flutter/material.dart';

/// Representa una categoría con estados visuales de selección.
class CategoryChip extends StatelessWidget {

  final String text;
  final bool selected;
  final VoidCallback onTap;

  /// Crea el componente CategoryChip con los valores que necesita para funcionar.
  const CategoryChip({
    super.key,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  /// Dibuja la etiqueta de categoría y distingue si está seleccionada.
  @override
  Widget build(BuildContext context) {

    return GestureDetector(

      onTap: onTap,

      child: Container(

        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 9,
        ),

        decoration: BoxDecoration(

          color: selected
              ? const Color(0xFF2196F3)
              : Colors.grey.shade200,

          borderRadius:
              BorderRadius.circular(20),
        ),

        child: Text(

          text,

          style: TextStyle(

            color: selected
                ? Colors.white
                : Colors.black87,

            fontWeight:
                FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
