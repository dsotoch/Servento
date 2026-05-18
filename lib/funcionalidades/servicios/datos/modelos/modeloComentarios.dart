import 'package:intl/intl.dart';

class ComentarioModel {
  final int idComentario;
  final int idServicio;
  final int usuarioId;
  final String nombreCalificador;
  final String comentario;
  final double estrellas;
  final DateTime fechaCreacion;

  ComentarioModel({
    required this.idComentario,
    required this.idServicio,
    required this.usuarioId,
    required this.nombreCalificador,
    required this.comentario,
    required this.estrellas,
    required this.fechaCreacion,
  });

  factory ComentarioModel.fromJson(Map<String, dynamic> json) {
    return ComentarioModel(
      idComentario: int.parse(json['id_comentario'].toString()),
      idServicio: int.parse(json['id_servicio'].toString()),
      usuarioId: int.parse(json['usuario_id'].toString()),
      nombreCalificador: json['nombre_calificador'] ?? '',
      comentario: json['comentario'] ?? '',
      estrellas: double.tryParse(json['estrellas'].toString()) ?? 0.0,
      fechaCreacion: DateTime.tryParse(json['fecha_creacion'].toString()) ?? DateTime.now(),

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_comentario': idComentario,
      'id_servicio': idServicio,
      'usuario_id': usuarioId,
      'nombre_calificador': nombreCalificador,
      'comentario': comentario,
      'estrellas': estrellas,
      'fecha_creacion': fechaCreacion.toIso8601String(),
    };
  }
}
