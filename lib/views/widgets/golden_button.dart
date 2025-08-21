import 'package:flutter/material.dart';

import '../../models/const_model.dart';

class GoldenButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;

  const GoldenButton({
    super.key,
    required this.child,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Constants.primaryGold,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0), // Rounded corners
        ),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}
