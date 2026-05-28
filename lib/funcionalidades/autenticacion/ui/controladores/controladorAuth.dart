import 'package:prestaservicios/funcionalidades/autenticacion/datos/modelos/DatosModel.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/datos/modelos/usuarioModel.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/dominio/casosUso/casoUsoAuth.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/dominio/entidades/usuario.dart';

class ControladorAuth {
  final casoUsoAuth usoAuth;
  ControladorAuth({required this.usoAuth});
  Future<Map<String, dynamic>> loguearse(String user, String pass) async {
    return await usoAuth.loguearse(user, pass);
  }

  Future<Map<String, dynamic>> resetPass(String email) async {
    return await usoAuth.resetPass(email);
  }

  Future<Map<String, dynamic>> registrarse(
    String email,
    String pass,
    String usuario,
    String telefono,
  ) async {
    return await usoAuth.registrarse(email, pass, usuario, telefono);
  }

  Future<Map<String, dynamic>> validarEmailAndTelefono(
    String email,
    String telefono,
  ) async {
    return await usoAuth.validarEmailAndTelefono(email, telefono);
  }

  Future<Map<String, dynamic>> actualizar(Usuario usuario) async {
    return await usoAuth.actualizar(usuario);
  }

  Future<Map<String, dynamic>> cambiarPass(UsuarioModel usuario) async {
    return await usoAuth.cambiarPass(usuario);
  }

  Future<Map<String, dynamic>> actualizarDatos(Datosmodel usuario) async {
    return await usoAuth.actualizarDatos(usuario);
  }

  Future<Map<String, dynamic>> passFirebase(UsuarioModel usuario) async {
    return await usoAuth.cambiarPass(usuario);
  }

  Future<Map<String, dynamic>> enviarCodigo(String telefono) async {
    return await usoAuth.enviarCodigo(telefono);
  }

  Future<Map<String, dynamic>> verificarOtp(String telefono, String s) async {
    return await usoAuth.validarCodigo(telefono, s);
  }

  Future<Map<String, dynamic>> reenviarCodigo(String telefono) async {
    return await usoAuth.reenviarCodigo(telefono);
  }
}
