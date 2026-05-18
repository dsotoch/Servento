class Usuario {
  final String id;
  final String nombres;
  final String email;
  final String? telefono;
  final String? direccion;
  final String? foto;
  final String? pass;
  final String? wsp;
  final String? estado;
  final String? img1;
  final String? img2;
  final String? img3;

  // Constructor
  Usuario({
    required this.id,
    required this.nombres,
    required this.email,
    this.telefono,
    this.direccion,
    this.foto,
    this.pass,
    this.wsp,
    this.estado,
    this.img1,
    this.img2,
    this.img3,
  });

  Usuario copyWith({
    String? nombres,
    String? email,
    String? telefono,
    String? direccion,
    String? foto,
    String? pass,
    String? wsp,
    String? estado,
    String? img1,
    String? img2,
    String? img3,
  }) {
    return Usuario(
      id: id,
      nombres: nombres ?? this.nombres,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      foto: foto ?? this.foto,
      pass: pass ?? this.pass,
      wsp: wsp ?? this.wsp,
      estado: estado ?? this.estado,
      img1: img1 ?? this.img1,
      img2: img2 ?? this.img2,
      img3: img3 ?? this.img3,
    );
  }

  // Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombres': nombres,
      'email': email,
      'telefono': telefono,
      'direccion': direccion,
      'foto': foto,
      'pass': pass,
      'wsp': wsp,
      'estado': estado,
      'img1': img1,
      'img2': img2,
      'img3': img3,
    };
  }

  // Convierte JSON a Usuario
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'].toString(),
      nombres: json['nombres'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'],
      direccion: json['direccion'],
      foto: json['foto'],
      pass: json['pass'],
      wsp: json['wsp'],
      estado: json['estado'],
      img1: json['img1'],
      img2: json['img2'],
      img3: json['img3'],
    );
  }
}
