import 'package:prestaservicios/funcionalidades/promociones_mensajes/dominio/casosUso/casoUsoPromocionesMensajes.dart';

class ControladorPromocion {
  final casoUsoPromociones casopromo;
  ControladorPromocion({required this.casopromo});
  Future<Map<String, dynamic>> getpromociones(String usuario_id)async {
    return await casopromo.getpromociones(usuario_id);
  }

  Future<Map<String, dynamic>> getMensajes(String id) async {
    return await casopromo.getMensajes(id);
  }

  Future<Map<String, dynamic>> getMensajesNuevos(
    String id,
    int cantidad,
  ) async {
    return await casopromo.getMensajesNuevos(id, cantidad);
  }

  Future<Map<String, dynamic>> getMensajesNuevosChat(
    String id,
    int cantidad,
  ) async {
    return await casopromo.getMensajesNuevosChat(id, cantidad);
  }

  Future<Map<String, dynamic>> getPagos(String tipo, String id_usuario) async {
    return await casopromo.getPagos(tipo, id_usuario);
  }

  Future<Map<String, dynamic>> getPagosTodos(String id_usuario) async {
    return await casopromo.getPagosTodos(id_usuario);
  }

  Future<Map<String, dynamic>> paymentSecret(String id_usuario) async {
    return await casopromo.paymentSecret(id_usuario);
  }

  Future<Map<String, dynamic>> asignarPromocion(
    String id_promocion,
    String usuario_id,
  ) async {
    return await casopromo.asignarPromocion(id_promocion, usuario_id);
  }

  Future<Map<String, dynamic>> validarCupon(
    String cupon,
    String paymentid,
  ) async {
    return await casopromo.validarCupon(cupon, paymentid);
  }

  Future<Map<String, dynamic>> validarCodigo(String codigo,String usuario_id) async {
    return await casopromo.validarCodigo(codigo,usuario_id);
  }
}
