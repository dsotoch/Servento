import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prestaservicios/compartido/conexion.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/datos/modelos/DatosModel.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/datos/modelos/usuarioModel.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/dominio/casosUso/casoUsoAuth.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/dominio/entidades/usuario.dart';
import 'package:prestaservicios/nucleo/env.dart';

class RepositorioAuth implements casoUsoAuth {
  @override
  Future<Map<String, dynamic>> loguearse(String user, String pass) async {
    try {
      final response = await ApiService().POST("apirest.php/iniciarsesion", {
        "user": user,
        "pass": pass,
      });
      
      return response;
    } catch (e) {
      return {'success': false, 'mensaje': e.toString()};
    }
  }
  @override
  Future<Map<String, dynamic>> resetPass(String email) async {
    try {
      final response = await ApiService().GET("apirest.php/send_email", {
        "email": email
      });
      return response;
    } catch (e) {
      return {'success': false, 'mensaje': e.toString()};
    }
  }
  @override
  Future<Map<String, dynamic>> registrarse(
    String email,
    String pass,
    String usuario,
    String telefono,
  ) async {
    try {
      final response = await ApiService().POST("apirest.php/usuario", {
        "email": email,
        "pass": pass,
        "usuario": usuario,
      });
      final data = response as Map<String, dynamic>;
      if (data["success"] == false) {
        throw new Exception(data["mensaje"]);
      }
      return response;
    } catch (e) {
      return {'success': false, 'mensaje': e.toString()};
    }
  }

  @override
  Future<Map<String, dynamic>> actualizar(Usuario usuario) async {
    try {
      final response = await ApiService().PUT(
        "apirest.php/usuario",
        usuario.toJson(),
      );
      return response;
    } catch (e) {
      // Captura errores generales
      return {'success': false, 'mensaje': e.toString()};
    }
  }

  @override
  Future<Map<String, dynamic>> cambiarPass(UsuarioModel usuario) async {
    try {
      final response = await ApiService().PUT(
        "apirest.php/usuario",
        usuario.toJson(),
      );

      return response;
    } catch (e) {
      // Captura errores generales
      return {'success': false, 'mensaje': e.toString()};
    }
  }

  @override
  Future<Map<String, dynamic>> passFirebase(UsuarioModel usuario) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: usuario.email);
      return {'success': true, 'mensaje': 'Correo de recuperación enviado'};
    } catch (e) {
      return {'success': false, 'mensaje': e.toString()};
    }
  }

  @override
  Future<Map<String, dynamic>> actualizarDatos(Datosmodel usuario) async {
    try {
      final response = await ApiService().PUT(
        "apirest.php/usuario",
        usuario.toJson(),
      );
      print(response);
      return response;
    } catch (e) {
      print(e);
      return {'success': false, 'mensaje': e.toString()};
    }
  }

  @override
  Future<Map<String, dynamic>> reenviarCodigo(String telefono) async {
    try {
      final dio = Dio();

      String basicAuth =
          'Basic ${base64Encode(utf8.encode('${Env.VERIF_APP_KEY}:${Env.VERIF_APP_SECRET}'))}';

      final response = await dio.post(
        "https://verification.api.sinch.com/verification/v1/verifications",
        data: {
          "identity": {
            "type": "number",
            "endpoint": formatearTelefono(telefono),
          },
          "method": "sms",
        },
        options: Options(
          headers: {
            "Authorization": basicAuth,
            "Content-Type": "application/json",
          },
        ),
      );

      print(response.data);
      return response.data;
    } catch (e) {
      print(e);
      return {'success': false, 'mensaje': e.toString()};
    }
  }

  String formatearTelefono(String telefono) {
    telefono = telefono.trim(); // quita espacios

    // si ya viene con +
    if (telefono.startsWith('+')) {
      return telefono;
    }

    // si viene solo número peruano
    return '+51$telefono';
  }

  @override
  Future<Map<String, dynamic>> validarEmailAndTelefono(
    String email,
    String telefono,
  )async {
     try {
      final response = await ApiService().GET("apirest.php/usuario", {
        "email": email,
        "telefono": telefono,
      });
      final data = response as Map<String, dynamic>;
      if (data["success"] == false) {
        throw new Exception(data["mensaje"]);
      }
      return response;
    } catch (e) {
      return {'success': false, 'mensaje': e.toString()};
    }
  }

  @override
  Future<Map<String, dynamic>> enviarCodigo(String email) async {
     try {
      final response = await ApiService().POST("apirest.php/send_email", {
        "email": email,
      });
      final data = response as Map<String, dynamic>;
      if (data["success"] == false) {
        throw new Exception(data["mensaje"]);
      }
      return response;
    } catch (e) {
      return {'success': false, 'mensaje': e.toString()};
    }

     
  }

  @override
  Future<Map<String, dynamic>> validarCodigo(
    String telefono,
    String codigo,
  ) async {
    try {
      final dio = Dio();

      String basicAuth =
          'Basic ${base64Encode(utf8.encode('${Env.VERIF_APP_KEY}:${Env.VERIF_APP_SECRET}'))}';

      final response = await dio.put(
        "https://verification.api.sinch.com/verification/v1/verifications/number/" +
            formatearTelefono(telefono),
        data: {
          "method": "sms",
          "sms": {"code": codigo},
        },
        options: Options(
          headers: {
            "Authorization": basicAuth,
            "Content-Type": "application/json",
          },
        ),
      );

      print(response.data);
      return response.data;
    } catch (e) {
      print(e);
      return {'success': false, 'mensaje': e.toString()};
    }
  }
}
