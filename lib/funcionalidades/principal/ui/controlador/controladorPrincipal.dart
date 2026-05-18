import 'package:prestaservicios/compartido/conexion.dart';

class ControladorPrincipal {
  Future<Map<String, dynamic>> getCategorias() async {
    try {
      final response = await ApiService().GET("apirest.php/categorias");
      return response;
    } catch (e) {
      return {'success': false, 'mensaje': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getConf() async {
    try {
      final response = await ApiService().GET("apirest.php/config");
      return response;
    } catch (e) {
      return {'success': false, 'mensaje': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getMensajes(
    String remitente,
    String destinatario,
  ) async {
    try {
      final response = await ApiService().GET("apirest.php/chat", {
        "remitente": remitente,
        "destinatario": destinatario,
      });
      return response;
    } catch (e) {
      return {'success': false, 'mensaje': e.toString()};
    }
  }

  Future<Map<String, dynamic>> enviarMensaje(
    String remitente,
    String destinatario,
    String mensaje,
  ) async {
    try {
      final response = await ApiService().POST("apirest.php/chat", {
        "remitente": remitente,
        "destinatario": destinatario,
        "mensaje": mensaje,
      });

      // Retorna la respuesta del servidor
      return response;
    } catch (e) {
      return {'success': false, 'mensaje': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getClientes(String remitente) async {
    try {
      final response = await ApiService().GET("apirest.php/chat", {
        "usuario_id": remitente,
      });
      return response;
    } catch (e) {
      return {'success': false, 'mensaje': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getClientesNuevos(String remitente) async {
    try {
      final response = await ApiService().GET("apirest.php/chat", {
        "usuario_id": remitente,
        "tipo": "nuevos",
      });
      return response;
    } catch (e) {
      return {'success': false, 'mensaje': e.toString()};
    }
  }
}
