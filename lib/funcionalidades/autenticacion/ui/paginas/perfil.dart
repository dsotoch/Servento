import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prestaservicios/compartido/funciones.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/datos/modelos/DatosModel.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/datos/repositorios/repositorioAuth.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/ui/controladores/controladorAuth.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/ui/paginas/login.dart';

class PantallaRegistroContinuacion extends StatefulWidget {
  final String id;
  final String telefono;
  const PantallaRegistroContinuacion({
    super.key,
    required this.id,
    required this.telefono,
  });

  @override
  State<PantallaRegistroContinuacion> createState() =>
      _PantallaRegistroContinuacionState();
}

class _PantallaRegistroContinuacionState
    extends State<PantallaRegistroContinuacion> {
  File? ineFrente;
  File? ineReverso;
  File? selfie;
  late TextEditingController telefonoController;
  final TextEditingController whatsappController = TextEditingController();
  bool aceptarTerminos = false;
  bool cargando = false;
  late ControladorAuth controladorAuth;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final usoAuth = RepositorioAuth();
    controladorAuth = ControladorAuth(usoAuth: usoAuth);
    telefonoController = TextEditingController(text: widget.telefono);
  }

  Future<void> _tomarFoto(String tipo) async {
    final XFile? foto = await _picker.pickImage(source: ImageSource.camera);
    if (foto == null) return;

    setState(() {
      switch (tipo) {
        case 'ineFrente':
          ineFrente = File(foto.path);
          break;
        case 'ineReverso':
          ineReverso = File(foto.path);
          break;
        case 'selfie':
          selfie = File(foto.path);
          break;
      }
    });
  }

  void _continuar() async {
    if (ineFrente == null ||
        ineReverso == null ||
        selfie == null ||
        telefonoController.text.length != 10 ||
        whatsappController.text.length != 10 ||
        !aceptarTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Completa todos los pasos y acepta los términos y condiciones para continuar.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final img1 = await Funciones().fileToBase64(ineFrente);
    final img2 = await Funciones().fileToBase64(ineReverso);
    final img3 = await Funciones().fileToBase64(selfie);
    final usuario = Datosmodel(
      id: widget.id,
      telefono: telefonoController.text,
      wsp: whatsappController.text,
      img1: img1!,
      img2: img2!,
      img3: img3!,
    );
    setState(() {
      cargando = true;
    });
    final res = await controladorAuth.actualizarDatos(usuario);
    setState(() {
      cargando = false;
    });
    if (res["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Registro completado con éxito,inicia sesion para continuar.',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PantallaLogin()),
      );
    } else {
      Funciones().mostrarMensaje("error", res["mensaje"]);
    }
  }

  Widget _fotoWidget(File? foto, String label, String tipo) {
    final double ancho =
        (MediaQuery.of(context).size.width - 80) /
        3; // 80px total de padding/margen
    return GestureDetector(
      onTap: () => _tomarFoto(tipo),
      child: Container(
        height: ancho,
        width: ancho,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF00BFA6), width: 2),
          image: foto != null
              ? DecorationImage(image: FileImage(foto), fit: BoxFit.cover)
              : null,
        ),
        child: foto == null
            ? Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF00BFA6)),
                ),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F7F4),
      appBar: AppBar(
        title: const Text('Registro: Documentos y Contacto'),
        backgroundColor: const Color(0xFF00BFA6),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              'Sube tu INE (frente y reverso) y toma una selfie',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _fotoWidget(ineFrente, 'INE\nFrente', 'ineFrente'),
                _fotoWidget(ineReverso, 'INE\nReverso', 'ineReverso'),
                _fotoWidget(selfie, 'Selfie', 'selfie'),
              ],
            ),
            const SizedBox(height: 25),

            // Número de teléfono
            TextField(
              controller: telefonoController,
              keyboardType: TextInputType.number,
              maxLength: 9,
              decoration: InputDecoration(
                labelText: 'Número de teléfono',
                prefixIcon: const Icon(Icons.phone, color: Color(0xFF00BFA6)),
                filled: true,
                enabled: widget.telefono.isEmpty,
                fillColor: const Color(0xFFF1FDFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // WhatsApp
            TextField(
              controller: whatsappController,
              keyboardType: TextInputType.number,
              maxLength: 9,
              decoration: InputDecoration(
                labelText: 'Número de WhatsApp',
                prefixIcon: const Icon(Icons.message, color: Color(0xFF00BFA6)),
                filled: true,
                fillColor: const Color(0xFFF1FDFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Aceptar términos y condiciones
            Row(
              children: [
                Checkbox(
                  value: aceptarTerminos,
                  activeColor: const Color(0xFF00BFA6),
                  onChanged: (val) =>
                      setState(() => aceptarTerminos = val ?? false),
                ),
                Expanded(
                  child: RichText(
                    text: const TextSpan(
                      text:
                          'Acepto los términos y condiciones y la política de privacidad. ',
                      style: TextStyle(color: Colors.black87),
                      children: [
                        TextSpan(
                          text:
                              '*Si no se hacen todos estos pasos no podrá acceder a los servicios de la app',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // Botón continuar
            ElevatedButton(
              onPressed: cargando ? null : _continuar,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BFA6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 100,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                elevation: 6,
              ),
              child: Text(
                cargando ? 'Procesando...' : 'Continuar',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
