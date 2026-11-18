import 'package:flutter/material.dart';

class AuthCard extends StatelessWidget {

  final Widget child;

  const AuthCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {

    return Card(

      elevation: 10,

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(14),
      ),

      child: Padding(
        padding:
            const EdgeInsets.all(24),

        child: SizedBox(
          width: 340,
          child: child,
        ),
      ),
    );
  }
}