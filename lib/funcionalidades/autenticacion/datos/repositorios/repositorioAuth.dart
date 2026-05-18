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

      final response = await dio.post(
        "https://api.smsmasivos.com.mx/otp/resend",
        data: {
          "phone_number": telefono,
          "country_code": "52",
          "code_length": 6,
          "code_type": "numeric",
          "company": "Cuca la Curra",
        },
        options: Options(
          headers: {
            "apikey": Env.ApiKeySMS,
            "Content-Type": "application/x-www-form-urlencoded",
          },
        ),
      );
      print(response);
      return response.data;
    } catch (e) {
      print(e);
      return {'success': false, 'mensaje': e.toString()};
    }
  }

  @override
  Future<Map<String, dynamic>> enviarCodigo(String telefono) async {
    try {
      final dio = Dio();

      final response = await dio.post(
        "https://api.smsmasivos.com.mx/otp/send",
        data: {
          "phone_number": telefono,
          "country_code": "52",
          "code_length": 6,
          "code_type": "numeric",
          "company": "Cuca la Curra",
        },
        options: Options(
          headers: {
            "apikey": Env.ApiKeySMS,
            "Content-Type": "application/x-www-form-urlencoded",
          },
        ),
      );
      print(response);
      return response.data;
    } catch (e) {
      print(e);
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

      final response = await dio.post(
        "https://api.smsmasivos.com.mx/otp/verify",
        data: {"phone_number": telefono, "verification_code": codigo},
        options: Options(
          headers: {
            "apikey": Env.ApiKeySMS,
            "Content-Type": "application/x-www-form-urlencoded",
          },
        ),
      );
      print(response);
      return response.data;
    } catch (e) {
      print(e);
      return {'success': false, 'mensaje': e.toString()};
    }
  }
}
