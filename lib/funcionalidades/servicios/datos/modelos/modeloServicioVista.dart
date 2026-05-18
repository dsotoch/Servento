class Modeloserviciovista {
  final int id;
  final String titulo;
  final String descripcion;
  final double precio;
  final String ubicacion;
  final String categoria;
  final String estado;
  final int usuarioId;
  final String fechaCreacion;
  final String nombrePublicador;
  final double? promedioUsuario;
  final int totalComentarios;
  final double promedioEstrellas;
  final String imagen1,
      imagen2,
      imagen3,
      contacto,
      wsp,
      direccion,
      foto,
      lat,
      long,
      subcategoria;

  Modeloserviciovista({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.precio,
    required this.ubicacion,
    required this.categoria,
    required this.estado,
    required this.usuarioId,
    required this.fechaCreacion,
    required this.nombrePublicador,
    this.promedioUsuario,
    required this.totalComentarios,
    required this.promedioEstrellas,
    required this.direccion,
    required this.foto,
    required this.imagen1,
    required this.imagen2,
    required this.imagen3,
    required this.contacto,
    required this.wsp,
    required this.lat,
    required this.long,
    required this.subcategoria,
  });

  factory Modeloserviciovista.fromJson(Map<String, dynamic> json) {
    return Modeloserviciovista(
      id: int.parse(json['id'].toString()),
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      precio: double.tryParse(json['precio'].toString()) ?? 0.0,
      ubicacion: json['ubicacion'] ?? '',
      categoria: json['categoria'] ?? '',
      estado: json['estado'] ?? '',
      usuarioId: int.parse(json['usuario_id'].toString()),
      fechaCreacion: json['fecha_creacion'] ?? '',
      nombrePublicador: json['nombre_publicador'] ?? '',
      promedioUsuario: json['promedio_usuario'] != null
          ? double.tryParse(json['promedio_usuario'].toString())
          : null,
      totalComentarios: int.tryParse(json['total_comentarios'].toString()) ?? 0,
      promedioEstrellas:
          (json['promedio_estrellas'] != null &&
              json['promedio_estrellas'].toString().isNotEmpty)
          ? double.tryParse(json['promedio_estrellas'].toString()) ?? 0.0
          : 0.0,
      imagen1: json['imagen1'] ?? '',
      imagen2: json['imagen2'] ?? '',
      imagen3: json['imagen3'] ?? '',
      contacto: json["contacto"] ?? '',
      wsp: json["wsp"] ?? '',
      direccion: json['direccion'] ?? '',
      foto: json['foto'] ?? '',
      lat: json["lat"] ?? '',
      long: json["long"] ?? '',
      subcategoria: json["subcategoria"] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'precio': precio,
      'ubicacion': ubicacion,
      'categoria': categoria,
      'subcategoria': subcategoria,
      'estado': estado,
      'usuario_id': usuarioId,
      'fecha_creacion': fechaCreacion,
      'nombre_publicador': nombrePublicador,
      'promedio_usuario': promedioUsuario,
      'total_comentarios': totalComentarios,
      'promedio_estrellas': promedioEstrellas,
    };
  }
}
