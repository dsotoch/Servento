import 'package:prestaservicios/compartido/conexion.dart';
import 'package:prestaservicios/funcionalidades/servicios/datos/modelos/modeloComenta.dart';
import 'package:prestaservicios/funcionalidades/servicios/datos/modelos/servicioModel.dart';
import 'package:prestaservicios/funcionalidades/servicios/dominipo/casosUso/casoUsoServicio.dart';

class RepositorioServicio implements CasoUsoServicio {
  @override
  Future<Map<String, dynamic>> guardarServicio(ServicioModel servicio) async {
    try {
      final response = await ApiService().POST(
        "apirest.php/servicios",
        servicio.toJson(),
      );

      return response;
    } catch (e) {
      return {'success': false, 'mensaje': 'Error desconocido: $e'};
    }
  }

  @override
  Future<Map<String, dynamic>> listarServicios(String id_usuario) async {
    try {
      final response = await ApiService().GET("apirest.php/servicios", {
        "id": id_usuario,
      });
      return response;
    } catch (e) {
      return {'success': false, 'mensaje': 'Error desconocido: $e'};
    }
  }

  @override
  Future<Map<String, dynamic>> modificarServicio(ServicioModel servicio) async {
    try {
      final response = await ApiService().PUT(
        "apirest.php/servicios",
        servicio.toJson(),
      );

      return response;
    } catch (e) {
      return {'success': false, 'mensaje': 'Error desconocido: $e'};
    }
  }

  @override
  Future<Map<String, dynamic>> eliminarServicio(String id) async {
    try {
      final response = await ApiService().DELETE(
        "apirest.php/servicios",
        {"id": id},
      );

      return response;
    } catch (e) {
      return {'success': false, 'mensaje': 'Error desconocido: $e'};
    }
  }

  @override
  Future<Map<String, dynamic>> editarRegistro(String id, String tipo) async {
    try {
      final response = await ApiService().DELETE(
        "apirest.php/servicios",
        {"id": id, "tipo": tipo},
      );
      return response;
    } catch (e) {
      return {'success': false, 'mensaje': 'Error desconocido: $e'};
    }
  }

  @override
  Future<Map<String, dynamic>> listarServiciosGeneral(
    String offset,
    String limit,
    String lat,
    String long,
    String radio,
  ) async {
    try {
      final response = await ApiService().GET("apirest.php/servicios", {
        "tipo": "todos",
        "offset": offset,
        "limit": limit,
        "lat":lat,
        "long":long,
        "radio":radio
      });
      return response;
    } catch (e) {
      return {'success': false, 'mensaje': 'Error desconocido: $e'};
    }
  }

  @override
  Future<Map<String, dynamic>> listarServiciosFiltro(String filtro) async {
    try {
      final response = await ApiService().GET("apirest.php/servicios", {
        "tipo": filtro,
      });
      return response;
    } catch (e) {
      return {'success': false, 'mensaje': 'Error desconocido: $e'};
    }
  }

  @override
  Future<Map<String, dynamic>> listarComentarios(
    String filtro,
    String id,
  ) async {
    try {
      final response = await ApiService().GET("apirest.php/servicios", {
        "tipo": filtro,
        "id": id,
      });
      return response;
    } catch (e) {
      return {'success': false, 'mensaje': 'Error desconocido: $e'};
    }
  }

  @override
  Future<Map<String, dynamic>> guardarComentario(ModeloComenta modelo) async {
    try {
      final response = await ApiService().POST(
        "apirest.php/comentario",
        modelo.toJson(),
      );

      return response;
    } catch (e) {
      return {'success': false, 'mensaje': 'Error desconocido: $e'};
    }
  }

  @override
  Future<Map<String, dynamic>> eliminarFavoritos(
    String usuarioid,
    String servicioid,
  ) async {
    try {
      final response = await ApiService().DELETE(
        "apirest.php/favoritos",
        {"usuario_id": usuarioid, "servicio_id": servicioid},
      );

      return response;
    } catch (e) {
      return {'success': false, 'mensaje': 'Error desconocido: $e'};
    }
  }

  @override
  Future<Map<String, dynamic>> guardarFavoritos(
    String usuarioid,
    String servicioid,
  ) async {
    try {
      final response = await ApiService().POST("apirest.php/favoritos", {
        "usuario_id": usuarioid,
        "servicio_id": servicioid,
      });

      return response;
    } catch (e) {
      return {'success': false, 'mensaje': 'Error desconocido: $e'};
    }
  }

  @override
  Future<Map<String, dynamic>> listarFavoritos(String usuarioid) async {
    try {
      final response = await ApiService().GET("apirest.php/favoritos", {
        "usuario_id": usuarioid,
      });

      return response;
    } catch (e) {
      return {'success': false, 'mensaje': 'Error desconocido: $e'};
    }
  }
}
