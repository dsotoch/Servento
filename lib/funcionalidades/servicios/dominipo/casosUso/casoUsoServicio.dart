import 'package:prestaservicios/funcionalidades/servicios/datos/modelos/modeloComenta.dart';
import 'package:prestaservicios/funcionalidades/servicios/datos/modelos/servicioModel.dart';

abstract class CasoUsoServicio{
  Future<Map<String,dynamic>> guardarServicio(ServicioModel servicio);
  Future<Map<String,dynamic>> modificarServicio(ServicioModel servicio);

  Future<Map<String,dynamic>> listarServicios(String id_usuario);
  Future<Map<String,dynamic>> eliminarServicio(String id);
  Future<Map<String,dynamic>> editarRegistro(String id,String tipo);
  Future<Map<String,dynamic>> listarServiciosGeneral(String offset,String limit,String lat,String long,String radio);
  Future<Map<String,dynamic>> listarServiciosFiltro(String filtro);
  Future<Map<String,dynamic>> listarComentarios(String filtro,String id);
  Future<Map<String,dynamic>> guardarComentario(ModeloComenta modelo);
  Future<Map<String,dynamic>> listarFavoritos(String usuarioid);
  Future<Map<String,dynamic>> guardarFavoritos(String usuarioid,String servicioid);
  Future<Map<String,dynamic>> eliminarFavoritos(String usuarioid,String servicioid);

}