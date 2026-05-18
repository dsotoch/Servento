class Pagos {
  final int? idAsignacion;
  final int? usuarioId;
  final double? montoAsignado;
  final String? fechaAsignacion;
  final String? descripcion;
  final String? metodoPago;
  final String? estado;
  final String? chargeid;

  Pagos({
    this.idAsignacion,
    this.usuarioId,
    this.montoAsignado,
    this.fechaAsignacion,
    this.descripcion,
    this.estado,
    this.chargeid,
    this.metodoPago,
  });

  // ✅ Constructor desde JSON
  factory Pagos.fromJson(Map<String, dynamic> json) {
    return Pagos(
      idAsignacion: json['id'] ?? json['ap.id'],
      usuarioId: json['usuario_id'],
      montoAsignado: double.tryParse(json['monto']?.toString() ?? ''),
      fechaAsignacion: json['fecha_pago'],
      descripcion: json["descripcion"],
      estado: json["estado"],
      chargeid: json["stripe_charge_id"] ?? '-',
      metodoPago: json["metodo_pago"] ?? '-',
    );
  }
}
