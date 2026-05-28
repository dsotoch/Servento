abstract class casoUsoPromociones {
  Future<Map<String, dynamic>> getpromociones(String usuario_id);
  Future<Map<String, dynamic>> getMensajes(String id);
  Future<Map<String, dynamic>> getMensajesNuevos(String id, int cantidad);
  Future<Map<String, dynamic>> getPagos(String tipo, String id_usuario);
  Future<Map<String, dynamic>> getPagosTodos(String id_usuario);
  Future<Map<String, dynamic>> paymentSecret(String id_usuario);
  Future<Map<String, dynamic>> getMensajesNuevosChat(String id, int cantidad);
  Future<Map<String, dynamic>> asignarPromocion(String id_promocion,String usuario_id);
  Future<Map<String, dynamic>> validarCupon(String cupon,String paymentid);
  Future<Map<String, dynamic>> validarCodigo(String codigo,String usuario_id);

}
