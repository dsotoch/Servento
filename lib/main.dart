import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/ui/paginas/inicio.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/ui/paginas/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      'pk_live_51Q7s4F2LsYRcAOwZ3hJmAOQMBqZkTd7Z1GykD8L06EqByvqnT8WmculzMYV36rbKTALHkRdaF3Ar6DaiWqOpLvz300VRBuKltY';
  await Stripe.instance.applySettings();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
            borderSide: BorderSide(color: Color(0xFF8E24AA), width: 2),
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
        primaryColor: Colors.purple,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          color: Colors.purple,
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
      home: Inicio()
    );
  }
}
