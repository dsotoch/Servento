import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Funciones {
  Future<void> mostrarMensaje(String tipo, String mensaje) async {
    Fluttertoast.showToast(
      msg: mensaje,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM_RIGHT,
      backgroundColor: tipo == "ok" ? Colors.green : Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
  Future<bool> mostrarConfirmacion({
    required BuildContext context,
    required String titulo,
    required String mensaje,
    String textoConfirmar = "Aceptar",
    String textoCancelar = "Cancelar",
  }) async {
    return await showDialog<bool>(
      context: context, // O el context de tu widget
      barrierDismissible: false, // No cerrar tocando afuera
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(textoCancelar),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(textoConfirmar),
            ),
          ],
        );
      },
    ).then((value) => value ?? false); // Devuelve false si cierra sin responder
  }
  Future<String?> fileToBase64(File? file) async {
    if (file == null) return null;

    try {
      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      print('Error al convertir a Base64: $e');
      return null;
    }
  }
}
