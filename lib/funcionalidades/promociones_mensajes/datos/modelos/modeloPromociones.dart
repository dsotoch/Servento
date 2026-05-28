class Promocion {
  final int? id;
  final String titulo;
  final String? descripcion;
  final int? descuento;
  final String? tipo; // general, nuevo_usuario, categoria
  final String? categoria;
  final String? estado; // activo, inactivo, pendiente
  final DateTime? fechaRegistro;
  final String? diasVigencia;

  Promocion({
    this.id,
    required this.titulo,
    this.descripcion,
    this.descuento,
    this.tipo,
    this.categoria,
    this.estado,
    this.fechaRegistro,
    this.diasVigencia
  });

  /// 🔹 Constructor para crear una instancia desde JSON
  factory Promocion.fromJson(Map<String, dynamic> json) {
    return Promocion(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'],
      descuento: json['costo'] != null
          ? int.tryParse(json['costo'].toString())
          : null,

      tipo: json['tipo'],
      categoria: json['categoria'],
      estado: json['estado'],
      fechaRegistro: json['fecha'] != null
          ? DateTime.tryParse(json['fecha'])
          : null,
          diasVigencia: json["dias_vigencia"].toString()
    );
  }

  /// 🔹 Convertir el modelo a JSON (para enviar a una API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'descuento': descuento,
      'tipo': tipo,
      'categoria': categoria,
      'estado': estado,
      'fecha': fechaRegistro?.toIso8601String(),
    };
  }

  /// 🔹 Método útil para clonar y modificar campos
  Promocion copyWith({
    int? id,
    String? titulo,
    String? descripcion,
    int? descuento,

    String? tipo,
    String? categoria,
    String? estado,
    DateTime? fechaRegistro,
  }) {
    return Promocion(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      descuento: descuento ?? this.descuento,
      tipo: tipo ?? this.tipo,
      categoria: categoria ?? this.categoria,
      estado: estado ?? this.estado,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }
}
