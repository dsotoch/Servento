import 'package:prestaservicios/funcionalidades/autenticacion/datos/modelos/DatosModel.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/datos/modelos/usuarioModel.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/dominio/entidades/usuario.dart';

abstract class casoUsoAuth {
  Future<Map<String, dynamic>> loguearse(String user, String pass);
  Future<Map<String, dynamic>> registrarse(
    String email,
    String pass,
    String usuario,
    String telefono,
  );
  Future<Map<String, dynamic>> actualizar(Usuario usuario);
  Future<Map<String, dynamic>> cambiarPass(UsuarioModel usuario);
  Future<Map<String, dynamic>> passFirebase(UsuarioModel usuario);
  Future<Map<String, dynamic>> actualizarDatos(Datosmodel usuario);
  Future<Map<String, dynamic>> enviarCodigo(String usuario);
  Future<Map<String, dynamic>> validarCodigo(String telefono, String codigo);
  Future<Map<String, dynamic>> reenviarCodigo(String usuario);
}
