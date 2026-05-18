class PagoAsignado {
  final int id;
  final int usuarioId;
  final String descripcionPlan;
  final double monto;
  final DateTime fechaAsignada;
  final String estado;
  final String? metodoPago;
  final int pagoId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String codigostripe;

  PagoAsignado({
    required this.id,
    required this.usuarioId,
    required this.descripcionPlan,
    required this.monto,
    required this.fechaAsignada,
    required this.estado,
    this.metodoPago,
    required this.pagoId,
    required this.createdAt,
    required this.updatedAt,
    required this.codigostripe,
  });

  factory PagoAsignado.fromJson(Map<String, dynamic> json) {
    return PagoAsignado(
      id: json['id'] ?? 0,
      usuarioId: json['usuario_id'] ?? 0,
      descripcionPlan: json['descripcion_plan'] ?? "",
      monto: double.tryParse(json['monto'].toString()) ?? 0.0,
      fechaAsignada: DateTime.parse(json['fecha_asignada']),
      estado: json['estado'] ?? "",
      metodoPago: json['metodo_pago'],
      pagoId: json['pago_id'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      codigostripe: json['codigostripe'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "usuario_id": usuarioId,
      "descripcion_plan": descripcionPlan,
      "monto": monto,
      "fecha_asignada": fechaAsignada.toIso8601String(),
      "estado": estado,
      "metodo_pago": metodoPago,
      "pago_id": pagoId,
      "created_at": createdAt.toIso8601String(),
      "updated_at": updatedAt.toIso8601String(),
      "codigostripe": codigostripe,
    };
  }
}
