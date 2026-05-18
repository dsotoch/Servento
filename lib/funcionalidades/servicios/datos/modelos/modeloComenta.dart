class ModeloComenta {
  final String comentario;
  final String estrellas;
  final String usuarioId;
  final String servicioId;

  ModeloComenta({
    required this.comentario,
    required this.estrellas,
    required this.usuarioId,
    required this.servicioId
  });

  // (Opcional) Para enviar fácilmente al backend en formato JSON
  Map<String, dynamic> toJson() => {
    'comentario': comentario,
    'estrellas': estrellas,
    'usuario_id': usuarioId,
    'servicio_id':servicioId
  };
}
