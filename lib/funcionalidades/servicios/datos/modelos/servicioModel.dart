import 'dart:convert';
import 'dart:io';

class ServicioModel {
  final int id;
  final String titulo;
  final String descripcion;
  final double precio;
  final String ubicacion;
  final String categoria;
  final String? imagen1;
  final String? imagen2;
  final String? imagen3;
  final String estado;
  final int usuarioId;
  final DateTime? fechaCreacion;
  final String lat;
  final String long;
  final String? sub;

  ServicioModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.precio,
    required this.ubicacion,
    required this.categoria,
    this.imagen1,
    this.imagen2,
    this.imagen3,
    required this.estado,
    required this.usuarioId,
    this.fechaCreacion,
    required this.lat,
    required this.long,
    required this.sub
  });

  /// 🔹 Crear un ServicioModel desde JSON
  factory ServicioModel.fromJson(Map<String, dynamic> json) {
    return ServicioModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      precio: double.tryParse(json['precio'].toString()) ?? 0.0,
      ubicacion: json['ubicacion'] ?? '',
      categoria: json['categoria'] ?? '',
      imagen1: json['imagen1'],
      imagen2: json['imagen2'],
      imagen3: json['imagen3'],
      estado: json['estado'] ?? 'activo',
      sub: json['subcategoria']??'',
      usuarioId: int.tryParse(json['usuario_id'].toString()) ?? 0,
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.tryParse(json['fecha_creacion'])
          : null,
      lat: json["lat"]??'',
      long: json["long"]??''
    );
  }

  /// 🔹 Convertir a JSON (para enviar al backend)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'precio': precio,
      'ubicacion': ubicacion,
      'categoria': categoria,
      'imagen1': imagen1,
      'imagen2': imagen2,
      'imagen3': imagen3,
      'estado': estado,
      'usuario_id': usuarioId,
      'fecha_creacion': fechaCreacion?.toIso8601String(),
      'lat':lat,
      'long':long,
      'subcategoria':sub
    };
  }

  /// 🔹 Codificar imágenes en base64 (si son locales)
  static Future<String?> convertirA64(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return null;
    try {
      final bytes = await File(imagePath).readAsBytes();
      return 'data:image/png;base64,${base64Encode(bytes)}';
    } catch (e) {
      print("Error al convertir imagen a base64: $e");
      return null;
    }
  }
}
