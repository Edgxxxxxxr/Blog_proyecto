import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {

  final Widget child;

  const AuthBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      decoration: const BoxDecoration(

        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,

          colors: [
            Color(0xFFE6F6FF),
            Color(0xFFBFD9FF),
            Color(0xFFD9D1FF),
            Color(0xFFE8DFFF),
          ],
        ),
      ),

      child: child,
    );
  }
}