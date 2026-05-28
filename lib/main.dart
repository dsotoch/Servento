import 'package:flutter/material.dart';
import 'package:prestaservicios/compartido/colores.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/ui/paginas/inicio.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF00BFA6),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor:  Colores.color_secundario,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white, // fondo del input
          hintStyle: TextStyle(color: Colors.grey[600]), // hint text
          labelStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight(500),
          ), // label text
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF00BFA6), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.redAccent, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00BFA6), // color de fondo
            foregroundColor: Colors.white, // color del texto
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: const Color(0xFF00BFA6), // color de fondo
          foregroundColor: Colors.white, // color del icono
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF00BFA6), // color del texto
          ),
        ),
        primaryColor: const Color(0xFF00BFA6),
        appBarTheme:  AppBarTheme(
          centerTitle: true,
          color: Colores.color_primario,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20, // 👈 cambia el tamaño aquí
            fontWeight: FontWeight.bold, // opcional: más grosor
          ),
          iconTheme: IconThemeData(
            color: Colors.white, // 👈 cambia el color de los íconos también
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF00BFA6),
            side: const BorderSide(color: Color(0xFF00BFA6)),
          ),
        ),
      ),
      home: Inicio(),
    );
  }
}
