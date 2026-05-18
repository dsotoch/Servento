
class Datosmodel {
  final String id;
  final String img1;
  final String img2;
  final String img3;
  final String? telefono;
  final String? wsp;

  const Datosmodel({
    required this.id,
    required this.img1,
    required this.img2,
    required this.img3,
    this.telefono,
    this.wsp,
  });

  /// 🔹 Convierte JSON a Datosmodel
  factory Datosmodel.fromJson(Map<String, dynamic> json) {
    return Datosmodel(
      id: json["id"] ?? '',
      img1: json['img1'] ?? '',
      img2: json['img2'] ?? '',
      img3: json['img3'] ?? '',
      telefono: json['telefono'],
      wsp: json['wsp'],
    );
  }

  /// 🔹 Convierte Datosmodel a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'img1': img1,
      'img2': img2,
      'img3': img3,
      'telefono': telefono,
      'wsp': wsp,
    };
  }
}
