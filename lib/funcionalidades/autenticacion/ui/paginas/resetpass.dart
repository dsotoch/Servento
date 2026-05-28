import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/datos/repositorios/repositorioAuth.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/dominio/casosUso/casoUsoAuth.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/ui/controladores/controladorAuth.dart';

class PantallaRecuperarContrasena extends StatefulWidget {
  const PantallaRecuperarContrasena({super.key});

  @override
  State<PantallaRecuperarContrasena> createState() =>
      _PantallaRecuperarContrasenaState();
}

class _PantallaRecuperarContrasenaState
    extends State<PantallaRecuperarContrasena> {
  final TextEditingController emailController = TextEditingController();
  bool cargando = false;
  late ControladorAuth controladorAuth;
  @override
  void initState() {
    super.initState();
    final casoUsoAuth = RepositorioAuth();
    controladorAuth = ControladorAuth(usoAuth: casoUsoAuth);
  }

  Future<void> _restablecerContrasena() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa tu correo'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => cargando = true);

    try {
      await controladorAuth.resetPass(email);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '✅ Se ha enviado un correo para restablecer tu contraseña. Revisa tu bandeja de entrada.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context); // Volver al login
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => cargando = false);
    }
  }

  Widget _campoCorreo() {
    return TextField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: 'Correo electrónico',
        prefixIcon: const Icon(Icons.email, color: Color(0xFF00BFA6)),
        filled: true,
        fillColor: const Color(0xFFF1FDFB),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F7F4),
      appBar: AppBar(
        title: const Text('Recuperar Contraseña'),
        backgroundColor: const Color(0xFF00BFA6),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Container(
            padding: const EdgeInsets.all(25),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_reset_outlined,
                  size: 70,
                  color: Color(0xFF00BFA6),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Restablece tu contraseña',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00695C),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                _campoCorreo(),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: cargando ? null : _restablecerContrasena,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BFA6),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: cargando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Enviar correo de recuperación',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
