import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/datos/repositorios/repositorioAuth.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/dominio/entidades/usuario.dart';
import 'package:prestaservicios/nucleo/env.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/ui/controladores/controladorAuth.dart';

class PerfilScreen extends StatefulWidget {
  final Usuario usuario;
  const PerfilScreen({super.key, required this.usuario});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  late Usuario usuario;
  late TextEditingController _nombreController;
  late TextEditingController _emailController;
  late TextEditingController _telefonoController;
  late TextEditingController _direccionController;
  late TextEditingController _passwordController;
  late TextEditingController _wspController;

  String? _fotoBase64;
  late final ImagePicker _picker;
  late final ControladorAuth controladorAuth;

  bool cargando = false;

  @override
  void initState() {
    super.initState();
    usuario = widget.usuario;
    _nombreController = TextEditingController(text: usuario.nombres);
    _emailController = TextEditingController(text: usuario.email);
    _telefonoController = TextEditingController(text: usuario.telefono);
    _direccionController = TextEditingController(text: usuario.direccion);
    _passwordController = TextEditingController();
    _wspController = TextEditingController(text: usuario.wsp);
    _picker = ImagePicker();
    final usoAuth = RepositorioAuth();
    controladorAuth = ControladorAuth(usoAuth: usoAuth);
  }

  Future<void> _cambiarFoto() async {
    final XFile? imagen = await _picker.pickImage(source: ImageSource.gallery);
    if (imagen == null) return;
    final bytes = await File(imagen.path).readAsBytes();
    setState(() => _fotoBase64 = base64Encode(bytes));
  }

  Future<void> _pickImage(int index) async {
    final XFile? imagen = await _picker.pickImage(source: ImageSource.gallery);
    if (imagen == null) return;
    final bytes = await File(imagen.path).readAsBytes();
    final base64String = base64Encode(bytes);

    setState(() {
      switch (index) {
        case 1:
          usuario = usuario.copyWith(img1: base64String);
          break;
        case 2:
          usuario = usuario.copyWith(img2: base64String);
          break;
        case 3:
          usuario = usuario.copyWith(img3: base64String);
          break;
      }
    });
  }

  Future<void> cambiarPassword(String nuevaPassword) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(nuevaPassword);
      } else {
        throw Exception("Usuario no autenticado. Debe iniciar sesión primero.");
      }
    } on FirebaseAuthException catch (e) {
      String mensaje;
      switch (e.code) {
        case 'weak-password':
          mensaje = 'La contraseña es demasiado débil.';
          break;
        case 'requires-recent-login':
          mensaje =
              'Debe iniciar sesión nuevamente para cambiar la contraseña.';
          break;
        default:
          mensaje = 'Error al cambiar la contraseña: ${e.message}';
      }
      throw Exception(mensaje);
    } catch (e) {
      throw Exception("Ocurrió un error inesperado: $e");
    }
  }

  Future<void> _actualizarDatos() async {
    setState(() => cargando = true);
    bool isBase64(String? str) {
      if (str == null) return false;
      try {
        base64Decode(str);
        return true;
      } catch (e) {
        return false;
      }
    }

    Usuario updated = usuario.copyWith(
      nombres: _nombreController.text,
      email: _emailController.text,
      telefono: _telefonoController.text,
      direccion: _direccionController.text,
      pass: _passwordController.text,
      wsp: _wspController.text,
      foto: isBase64(_fotoBase64) ? _fotoBase64 : '',
      img1: isBase64(usuario.img1) ? usuario.img1 : '',
      img2: isBase64(usuario.img2) ? usuario.img2 : '',
      img3: isBase64(usuario.img3) ? usuario.img3 : '',
    );

    try {
      if (_passwordController.text != "") {
        await cambiarPassword(_passwordController.text);
      }
      final res = await controladorAuth.actualizar(updated);
      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['mensaje'] ?? 'Actualizado'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, {"usuario": Usuario.fromJson(res["datos"])});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['mensaje'] ?? 'Error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() => cargando = false);
    }
  }

  Widget _imagePicker(String label, String? imgPath, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _pickImage(index),
          child: Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blueAccent),
              image: imgPath != null
                  ? DecorationImage(
                      image:
                          imgPath.startsWith("/9") // base64
                          ? MemoryImage(base64Decode(imgPath)) as ImageProvider
                          : NetworkImage("${Env.dominio}$imgPath"),
                      fit: BoxFit.contain,
                    )
                  : null,
            ),
            child: imgPath == null
                ? const Center(
                    child: Icon(
                      Icons.add_a_photo,
                      size: 40,
                      color: Colors.grey,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final borde = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.blueAccent, width: 1.2),
    );

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Mi Perfil')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Avatar principal
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _fotoBase64 != null
                          ? MemoryImage(base64Decode(_fotoBase64!))
                          : NetworkImage("${Env.dominio}${usuario.foto}")
                                as ImageProvider,
                      backgroundColor: Colors.grey.shade200,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.blue,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.white,
                          ),
                          onPressed: _cambiarFoto,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Form(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: "Nombre completo",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: "Correo electrónico",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _telefonoController,
                      decoration: InputDecoration(
                        labelText: "Teléfono",
                        border: borde,
                        focusedBorder: borde,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _wspController,
                      decoration: InputDecoration(
                        labelText: "Whatsapp",
                        border: borde,
                        focusedBorder: borde,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _direccionController,
                      decoration: const InputDecoration(
                        labelText: "Dirección",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: "Contraseña",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Dejar en blanco si no se desea cambiar",
                      style: TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 20),

                    // Imagenes
                    _imagePicker("INE Frente", usuario.img1, 1),
                    const SizedBox(height: 12),
                    _imagePicker("INE Reverso", usuario.img2, 2),
                    const SizedBox(height: 12),
                    _imagePicker("Selfie", usuario.img3, 3),
                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      onPressed: cargando ? null : _actualizarDatos,
                      icon: const Icon(Icons.save),
                      label: Text(
                        cargando ? "Procesando..." : " Guardar cambios",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
