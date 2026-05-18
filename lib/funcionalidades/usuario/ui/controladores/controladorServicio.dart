import 'package:prestaservicios/funcionalidades/servicios/datos/modelos/modeloComenta.dart';
import 'package:prestaservicios/funcionalidades/servicios/datos/modelos/servicioModel.dart';
import 'package:prestaservicios/funcionalidades/servicios/dominipo/casosUso/casoUsoServicio.dart';

class ControladorServicio {
  final CasoUsoServicio casoUsoServicio;
  ControladorServicio({required this.casoUsoServicio});

  Future<Map<String, dynamic>> guardarServicio(ServicioModel servicio) async {
    return await casoUsoServicio.guardarServicio(servicio);
  }

  Future<Map<String, dynamic>> listarServicios(String id_usuario) async {
    return await casoUsoServicio.listarServicios(id_usuario);
  }

  Future<Map<String, dynamic>> modificarServicio(ServicioModel servicio) async {
    return await casoUsoServicio.modificarServicio(servicio);
  }

  Future<Map<String, dynamic>> eliminarServicio(String id) async {
    return await casoUsoServicio.eliminarServicio(id);
  }

  Future<Map<String, dynamic>> editarRegistro(String id, String tipo) async {
    return await casoUsoServicio.editarRegistro(id, tipo);
  }

  Future<Map<String, dynamic>> listarServiciosGeneral(
    String offset,
    String limit,
    String lat,
    String long,
    String radio,
  ) async {
    return await casoUsoServicio.listarServiciosGeneral(
      offset,
      limit,
      lat,
      long,
      radio,
    );
  }

  Future<Map<String, dynamic>> listarServiciosFiltro(String filtro) async {
    return await casoUsoServicio.listarServiciosFiltro(filtro);
  }

  Future<Map<String, dynamic>> listarComentarios(
    String filtro,
    String id,
  ) async {
    return await casoUsoServicio.listarComentarios(filtro, id);
  }

  Future<Map<String, dynamic>> guardarComentario(ModeloComenta modelo) async {
    return await casoUsoServicio.guardarComentario(modelo);
  }

  Future<Map<String, dynamic>> guardarFavoritos(
    String usuarioid,
    String servicioid,
  ) async {
    return await casoUsoServicio.guardarFavoritos(usuarioid, servicioid);
  }

  Future<Map<String, dynamic>> listarFavoritos(String usuarioid) async {
    return await casoUsoServicio.listarFavoritos(usuarioid);
  }

  Future<Map<String, dynamic>> eliminarFavoritos(
    String usuarioid,
    String servicioid,
  ) async {
    return await casoUsoServicio.eliminarFavoritos(usuarioid, servicioid);
  }
}
