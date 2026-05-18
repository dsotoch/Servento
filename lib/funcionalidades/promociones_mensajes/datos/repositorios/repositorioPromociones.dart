import 'package:prestaservicios/compartido/conexion.dart';
import 'package:prestaservicios/funcionalidades/promociones_mensajes/dominio/casosUso/casoUsoPromocionesMensajes.dart';

class RepositorioPromociones implements casoUsoPromociones {
  @override
  Future<Map<String, dynamic>> getpromociones() async {
    try {
      final response = await ApiService().GET("apirest.php/promociones");
      return response;
    } catch (e) {
      // Captura errores generales
      return {'success': false, 'mensaje': e.toString()};
    }
  }

  @override
  Future<Map<String, dynamic>> getMensajes(String id) async {
    try {
      final response = await ApiService().GET("apirest.php/promociones", {
        "tipo": 'msj',
        'id': id,
      });
      return response;
    } catch (e) {
      // Captura errores generales
      return {'success': false, 'mensaje': e.toString()};
    }
  }

  @override
  Future<Map<String, dynamic>> getMensajesNuevos(
    String id,
    int cantidad,
  ) async {
    try {
      final response = await ApiService().GET("apirest.php/promociones", {
        "tipo": 'msjnuevos',
        'viene':'no',
        'cantidad': cantidad,
        'id': id,
      });
      return response;
    } catch (e) {
      // Captura errores generales
      return {'success': false, 'mensaje': e.toString()};
    }
  }

  @override
  Future<Map<String, dynamic>> getMensajesNuevosChat(
    String id,
    int cantidad,
  ) async {
    try {
      final response = await ApiService().GET("apirest.php/promociones", {
        "tipo": 'msjnuevos',
        "viene": 'chat',
        'cantidad': cantidad,
        'id': id,
      });
      return response;
    } catch (e) {
      // Captura errores generales
      return {'success': false, 'mensaje': e.toString()};
    }
  }

  @override
  Future<Map<String, dynamic>> getPagos(String tipo, String id_usuario) async {
    try {
      final response = await ApiService().GET("apirest.php/promociones", {
        "tipo": 'pagos',
        'id': id_usuario,
      });
      return response;
    } catch (e) {
      // Captura errores generales
      return {'success': false, 'mensaje': e.toString()};
    }
  }

  @override
  Future<Map<String, dynamic>> getPagosTodos(String id_usuario) async {
    try {
      final response = await ApiService().GET("apirest.php/promociones", {
        "tipo": 'pagosge',
        'id': id_usuario,
      });
      return response;
    } catch (e) {
      // Captura errores generales
      return {'success': false, 'mensaje': e.toString()};
    }
  }

  @override
  Future<Map<String, dynamic>> paymentSecret(String id_usuario) async {
    try {
      final response = await ApiService().GET("apirest.php/promociones", {
        "tipo": 'secret',
        'id': id_usuario,
      });
      return response;
    } catch (e) {
      // Captura errores generales
      return {'success': false, 'mensaje': e.toString()};
    }
  }

  @override
  Future<Map<String, dynamic>> asignarPromocion(
    String id_promocion,
    String usuario_id,
  ) async {
    try {
      final response = await ApiService().POST("apirest.php/promociones", {
        "usuario_id": usuario_id,
        "id_promocion": id_promocion,
        'tipo': "asignar",
      });
      return response;
    } catch (e) {
      return {'success': false, 'mensaje': e.toString()};
    }
  }

  @override
  Future<Map<String, dynamic>> validarCupon(
    String cupon,
    String paymentid,
  ) async {
    try {
      final response = await ApiService().POST("apirest.php/cupones", {
        "cupon": cupon,
        "paymentid": paymentid,
        'tipo': "validar",
      });
      return response;
    } catch (e) {
      return {'success': false, 'mensaje': e.toString()};
    }
  }

  @override
  Future<Map<String, dynamic>> validarCodigo(String codigo) async {
    try {
      final response = await ApiService().GET("apirest.php/cupones", {
        'codigo': codigo,
      });
      return response;
    } catch (e) {
      // Captura errores generales
      return {'success': false, 'mensaje': e.toString()};
    }
  }
}
