import 'package:flutter/material.dart';
import 'package:prestaservicios/compartido/colores.dart';
import 'package:prestaservicios/compartido/funciones.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/datos/repositorios/repositorioAuth.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/ui/controladores/controladorAuth.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/ui/paginas/login.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/ui/paginas/verificacion.dart';
import 'package:prestaservicios/funcionalidades/principal/ui/paginas/buscador.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  late final ControladorAuth controladorAuth;
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();

  bool cargando = false;
  bool codigoValido = false;

  @override
  void initState() {
    super.initState();
    final usoAuth = RepositorioAuth();
    controladorAuth = ControladorAuth(usoAuth: usoAuth);
  }

  Future<void> _registrarse() async {
    final user = userController.text.trim();
    final pass = passController.text.trim();
    final usuario = usuarioController.text.trim();
    final telefono = telefonoController.text.trim();

    if (user.isEmpty || pass.isEmpty || usuario.isEmpty || telefono.isEmpty) {
      _mostrarSnackbar('Por favor, ingresa todos los datos', Colors.redAccent);
      return;
    }

    if (telefono.length < 9) {
      _mostrarSnackbar('Teléfono inválido', Colors.redAccent);
      return;
    }

    setState(() => cargando = true);

    try {
      final validar = await controladorAuth.validarEmailAndTelefono(
        user,
        telefono,
      );
      if (validar["success"] == false) {
        setState(() => cargando = false);
        await Funciones().mostrarMensaje("error", validar["mensaje"] ?? "");
        return;
      }
      final registroResponse = await controladorAuth.registrarse(
        user,
        pass,
        usuario,
        telefono,
      );

      if (registroResponse['success'] == true) {
        _mostrarSnackbar(
          registroResponse['mensaje'] ?? 'Registro exitoso',
          Colors.green,
        );
      } else {
        _mostrarSnackbar(
          registroResponse['mensaje'] ?? 'Error en el registro',
          Colors.orange,
        );
        return;
      }
      _mostrarSnackbar('Solicitando verificacion...', Colors.blue);
      await controladorAuth.enviarCodigo(user);
      await Funciones().mostrarMensaje(
        "ok",
        "Revisa tu correo para activar tu cuenta. Si no lo ves, revisa la carpeta de spam.",
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PantallaLogin()),
      );
    } catch (e) {
      _mostrarSnackbar('Error: $e', Colors.redAccent);
    } finally {
      setState(() => cargando = false);
    }
  }

  Future<bool> _verificarOtpConIntentos(String telefono) async {
    const maxIntentos = 3;

    for (int i = 0; i < maxIntentos; i++) {
      final otpCode = await _mostrarPantallaOtp(telefono);

      if (otpCode == null) {
        _mostrarSnackbar('Verificación cancelada', Colors.orange);
        return false;
      }

      final valido = await verificarCodigo(telefono, otpCode);

      if (valido) {
        return true;
      }

      _mostrarSnackbar(
        'Código incorrecto. Intento ${i + 1} de $maxIntentos',
        Colors.redAccent,
      );
    }

    _mostrarSnackbar('Demasiados intentos fallidos', Colors.redAccent);
    return false;
  }

  Future<bool> verificarCodigo(String telefono, String otpCode) async {
    // 3. Verificar OTP
    setState(() => cargando = true);
    _mostrarSnackbar('Verificando código...', Colors.blue);

    final verificarOtpResponse = await controladorAuth.verificarOtp(
      telefono,
      otpCode,
    );
    print(verificarOtpResponse);
    if (verificarOtpResponse['success'] != true) {
      _mostrarSnackbar(
        verificarOtpResponse['message'] ?? 'Código incorrecto',
        Colors.redAccent,
      );

      setState(() => cargando = false);
      return false;
    }
    return true;
  }

  // Helper para mostrar snackbar
  void _mostrarSnackbar(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Helper para mostrar pantalla OTP
  Future<String?> _mostrarPantallaOtp(String numero) async {
    return await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => OtpAutoReadWidget(
          onCodeReceived: (String code) {
            Navigator.pop(context, code);
          },
          reenviarCodigo: () async {
            final casoUsoAuth = RepositorioAuth();
            ControladorAuth controladorAuth = ControladorAuth(
              usoAuth: casoUsoAuth,
            );
            final rs = await controladorAuth.reenviarCodigo(numero);
            if (rs["success"] != true) {
              await Funciones().mostrarMensaje("error", rs["message"]);
            } else {
              await Funciones().mostrarMensaje("success", rs["message"]);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(5),
          child: Container(
            padding: const EdgeInsets.all(25),
            margin: const EdgeInsets.symmetric(horizontal: 25),
            decoration: BoxDecoration(
              color: Colores.color_secundario,
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
                 Icon(
                  Icons.person_add_alt_1,
                  size: 70,
                  color: Colores.color_primario,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Crear cuenta',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00695C),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Regístrate para continuar',
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
                const SizedBox(height: 30),

                // Nombre
                TextField(
                  controller: usuarioController,
                  decoration: InputDecoration(
                    hintText: 'Nombre completo',
                    prefixIcon: const Icon(
                      Icons.badge_outlined,
                      color: Color(0xFF00BFA6),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF1FDFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Email
                TextField(
                  controller: userController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Correo electrónico',
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: Color(0xFF00BFA6),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF1FDFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Contraseña
                TextField(
                  controller: passController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Contraseña',
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Color(0xFF00BFA6),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF1FDFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Contraseña
                TextField(
                  controller: telefonoController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Telefono',
                    prefixIcon: const Icon(
                      Icons.phone,
                      color: Color(0xFF00BFA6),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF1FDFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Botón de registro
                ElevatedButton(
                  onPressed: cargando ? null : () => _registrarse(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFA6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 80,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    elevation: 6,
                  ),
                  child: Text(
                    cargando ? 'Procesando...' : 'Registrarme',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Ir a login
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PantallaLogin(),)),
                  child: const Text(
                    '¿Ya tienes cuenta? Inicia sesión',
                    style: TextStyle(
                      color: Color(0xFF009688),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline
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
