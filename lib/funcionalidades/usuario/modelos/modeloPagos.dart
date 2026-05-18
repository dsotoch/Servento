class AsignacionPago {
  final int? idAsignacion;
  final int? usuarioId;
  final double? montoAsignado;
  final String? fechaAsignacion;
  final String? descripcion;
  final String? estado;

  AsignacionPago({
    this.idAsignacion,
    this.usuarioId,
    this.montoAsignado,
    this.fechaAsignacion,
    this.descripcion,
    this.estado
  });

  // ✅ Constructor desde JSON
  factory AsignacionPago.fromJson(Map<String, dynamic> json) {
    return AsignacionPago(
      idAsignacion: json['id'] ?? json['ap.id'],
      usuarioId: json['usuario_id'],
      montoAsignado: double.tryParse(json['monto']?.toString() ?? ''),
      fechaAsignacion: json['fecha_asignada'],
      descripcion: json["descripcion_plan"],
      estado: json["estado"]
    );
  }
}
