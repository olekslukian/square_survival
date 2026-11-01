import 'package:flutter/material.dart';

class CloseButton extends StatelessWidget {
  const CloseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: () {
        Navigator.of(context).pop();
      },
      icon: const Icon(Icons.close),
    );
  }
}
