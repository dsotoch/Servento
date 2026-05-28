import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:location/location.dart';
import 'package:prestaservicios/compartido/colores.dart';
import 'package:prestaservicios/compartido/funciones.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/datos/modelos/usuarioModel.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/datos/repositorios/repositorioAuth.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/dominio/entidades/usuario.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/ui/controladores/controladorAuth.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/ui/paginas/perfil.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/ui/paginas/registro.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/ui/paginas/resetpass.dart';
import 'package:prestaservicios/funcionalidades/principal/ui/paginas/principal.dart';
import 'package:prestaservicios/funcionalidades/servicios/datos/repositorios/repositorioServicio.dart';
import 'package:prestaservicios/funcionalidades/usuario/ui/controladores/controladorServicio.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

const List<String> scopes = <String>['email', 'profile'];

GoogleSignIn _googleSignIn = GoogleSignIn(scopes: scopes);
final FirebaseAuth _auth = FirebaseAuth.instance;

class _PantallaLoginState extends State<PantallaLogin> {
  late final ControladorAuth controladorAuth;
  late final ControladorServicio controladorServicio;
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  bool cargando = false;
  LocationData? locationData;
  User? _usuarioFirebase;
  bool recordarPassword = false;
  bool verPassword = false;
  @override
  void initState() {
    super.initState();
    final usoAuth = RepositorioAuth();
    final usoServicio = RepositorioServicio();
    controladorServicio = ControladorServicio(casoUsoServicio: usoServicio);
    controladorAuth = ControladorAuth(usoAuth: usoAuth);
    _googleSignIn.onCurrentUserChanged.listen(
      (GoogleSignInAccount? cuenta) async {},
    );
    cargarCredenciales();
    _googleSignIn.signInSilently();
  }

  Future<bool> activarGPS() async {
    Location location = Location();

    bool servicioHabilitado = await location.serviceEnabled();
    if (!servicioHabilitado) {
      servicioHabilitado = await location.requestService();
      if (!servicioHabilitado) {
        Funciones().mostrarMensaje(
          "error",
          "Es Necesario activar el gps para correcto funcionamiento de la Aplicación",
        );
        exit(0);
      }
    }

    PermissionStatus permiso = await location.hasPermission();
    if (permiso == PermissionStatus.denied) {
      permiso = await location.requestPermission();
      if (permiso != PermissionStatus.granted) {
        Funciones().mostrarMensaje(
          "error",
          "Es Necesario activar el gps para correcto funcionamiento de la Aplicación",
        );
        exit(0);
      }
    }
    final ubicacion = await location.getLocation();
    setState(() {
      locationData = ubicacion;
    });
    return true;
  }

  Future<void> _iniciarSesion() async {
    final user = userController.text.trim();
    final pass = passController.text.trim();

    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa usuario y contraseña'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (!kIsWeb) {
      if (!await activarGPS()) {
        return;
      }
    }

    setState(() => cargando = true);

    try {
      final respuesta = await controladorAuth.loguearse(user, pass);

      if (respuesta['success'] == true) {
        await guardarCredenciales();
        if (respuesta["mensaje"] == "Correo no verificado") {
          await Funciones().mostrarMensaje(
            "error",
            "Correo no verificado.Revisa tu bandeja de Entrada o Spam",
          );
          return;
        }
        if (respuesta["mensaje"] == "Cuentanoverificada") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PantallaRegistroContinuacion(
                id: respuesta["data"].toString(),
                telefono: respuesta["telefono"] ?? "",
              ),
            ),
          );
          return;
        }
        final Usuario usuario = UsuarioModel.fromJson(respuesta["data"]);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PantallaPrincipalGrid(
              usuario: usuario,
              location:
                  locationData ??
                  LocationData.fromMap({
                    "latitude": -12.0464,
                    "longitude": -77.0428,
                  }),
            ),
          ),
        );
      } else {
        RegExp exp = RegExp(r'\[([^\]]+)\]');
        var match = exp.firstMatch(respuesta["mensaje"]);
        if (match != null) {
          String contenido = match.group(1)!;
          print(contenido);
          String mensaje = "";
          switch (contenido) {
            case 'firebase_auth/invalid-credential':
              mensaje = 'Contraseña incorrecta.';
              break;
            case 'firebase_auth/too-many-requests':
              mensaje = 'Correo no Verificado.';
              break;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(mensaje), backgroundColor: Colors.redAccent),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(respuesta['mensaje'] ?? 'Error desconocido'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() => cargando = false);
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      setState(() => cargando = true);

      if (!await activarGPS()) {
        return;
      }
      final GoogleSignInAccount? cuentaGoogle = await _googleSignIn.signIn();
      if (cuentaGoogle == null) return;

      final GoogleSignInAuthentication googleAuth =
          await cuentaGoogle.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      setState(() {
        _usuarioFirebase = userCredential.user;
      });

      if (_usuarioFirebase == null) {
        setState(() => cargando = false);
        Funciones().mostrarMensaje(
          "error",
          "No se pudo obtener el usuario de Firebase",
        );
        return;
      }

      await controladorAuth.registrarse(
        userCredential.user!.email!,
        "123456",
        userCredential.user!.displayName!,
        "",
      );

      Funciones().mostrarMensaje(
        "ok",
        "BIENVENIDO ${_usuarioFirebase?.displayName}",
      );
      final respuesta = await controladorAuth.loguearse(
        userCredential.user!.email!,
        "123456",
      );
      setState(() => cargando = false);
      if (respuesta['success'] == true) {
        if (respuesta["mensaje"] == "CuentanoVerificada") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PantallaRegistroContinuacion(
                id: respuesta["data"].toString(),
                telefono: '',
              ),
            ),
          );
          return;
        }
        final Usuario usuario = UsuarioModel.fromJson(respuesta["data"]);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PantallaPrincipalGrid(
              usuario: usuario,
              location: locationData!,
            ),
          ),
        );
      } else {
        Funciones().mostrarMensaje("error", respuesta["mensaje"]);
      }
    } catch (e) {
      debugPrint('Error en Google Sign-In: $e');
    }
  }

  Future<void> guardarCredenciales() async {
    final prefs = await SharedPreferences.getInstance();

    if (recordarPassword) {
      await prefs.setString('email', userController.text);
      await prefs.setString('password', passController.text);
      await prefs.setBool('recordar', true);
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
      await prefs.setBool('recordar', false);
    }
  }

  Future<void> cargarCredenciales() async {
    final prefs = await SharedPreferences.getInstance();

    bool recordar = prefs.getBool('recordar') ?? false;

    if (recordar) {
      userController.text = prefs.getString('email') ?? '';
      passController.text = prefs.getString('password') ?? '';

      setState(() {
        recordarPassword = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // Fondo degradado de toda la pantalla
          gradient: LinearGradient(
            colors: [Colores.color_primario, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(30),
              margin: const EdgeInsets.symmetric(horizontal: 25),
              decoration: BoxDecoration(
                color: Colores.color_secundario,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
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
                    Icons.lock_outline,
                    size: 70,
                    color: Colores.color_primario,
                  ),

                  const SizedBox(height: 8),
                  const Text(
                    'Inicia sesión para continuar',
                    style: TextStyle(color: Colors.black87, fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    height: 180,
                    width: 200, // importante que sea cuadrado
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, // esto hace el avatar
                      image: const DecorationImage(
                        image: AssetImage("assets/images/cuca.png"),
                        fit: BoxFit.contain, // cubrir todo el círculo
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Campo usuario
                  TextField(
                    controller: userController,
                    decoration: InputDecoration(
                      hintText: 'Correo',
                      prefixIcon: const Icon(
                        Icons.email,
                        color: Color(0xFF00BFA6),
                      ),
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
                  ),
                  const SizedBox(height: 20),

                  // Campo contraseña
                  TextField(
                    controller: passController,
                    obscureText: !verPassword,
                    decoration: InputDecoration(
                      hintText: 'Contraseña',
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Color(0xFF00BFA6),
                      ),

                      // OJO PARA MOSTRAR / OCULTAR
                      suffixIcon: IconButton(
                        icon: Icon(
                          verPassword ? Icons.visibility : Icons.visibility_off,
                          color: const Color(0xFF00BFA6),
                        ),
                        onPressed: () {
                          setState(() {
                            verPassword = !verPassword;
                          });
                        },
                      ),

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
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Checkbox(
                        value: recordarPassword,
                        onChanged: (value) {
                          setState(() {
                            recordarPassword = value!;
                          });
                        },
                      ),
                      const Text("Guardar contraseña"),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Botón iniciar sesión
                  ElevatedButton(
                    onPressed: cargando ? null : _iniciarSesion,
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
                    child: cargando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const PantallaRecuperarContrasena(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(10),
                    splashColor: const Color(0xFF00BFA6).withOpacity(0.2),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 12.0,
                      ),
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          color: Color(0xFF009688),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  // Enlace registro
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PantallaRegistro(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(10),
                    splashColor: const Color(0xFF00BFA6).withOpacity(0.2),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 12.0,
                      ),
                      child: Text(
                        '¿No tienes una cuenta? Regístrate',
                        style: TextStyle(
                          color: Color(0xFF009688),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  /*  ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFA6),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: FaIcon(
                    FontAwesomeIcons.google,
                    color: Colors.white, // Color del icono
                  ),
                  label: Text(
                    cargando ? "Procesando..." : 'Continuar con Google',
                  ),
                  onPressed: cargando ? null : () => signInWithGoogle(),
                ),*/
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
