import 'package:flutter/material.dart';

class ImagenPantallaCompleta extends StatelessWidget {
  final String imagenUrl;

  const ImagenPantallaCompleta({super.key, required this.imagenUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              child: Image.network(
                imagenUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Botón de cerrar
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 32),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
