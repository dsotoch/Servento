import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:location/location.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/dominio/entidades/usuario.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/ui/controladores/autService.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/ui/paginas/chats.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/ui/paginas/login.dart';
import 'package:prestaservicios/funcionalidades/principal/ui/controlador/controladorPrincipal.dart';
import 'package:prestaservicios/funcionalidades/principal/ui/paginas/buscador.dart';
import 'package:prestaservicios/funcionalidades/principal/ui/paginas/filtros.dart';
import 'package:prestaservicios/funcionalidades/principal/ui/paginas/promoBanner.dart';
import 'package:prestaservicios/funcionalidades/principal/ui/paginas/soporte.dart';
import 'package:prestaservicios/funcionalidades/promociones_mensajes/datos/repositorios/repositorioPromociones.dart';
import 'package:prestaservicios/funcionalidades/promociones_mensajes/ui/controladores/controladorPromocion.dart';
import 'package:prestaservicios/funcionalidades/promociones_mensajes/ui/paginas/mensajes.dart';
import 'package:prestaservicios/funcionalidades/promociones_mensajes/ui/paginas/pagosPrincipal.dart';
import 'package:prestaservicios/funcionalidades/usuario/ui/paginas/perfil.dart';
import 'package:prestaservicios/funcionalidades/usuario/ui/paginas/servicios.dart';
import 'package:prestaservicios/funcionalidades/promociones_mensajes/ui/widgets/todasPromociones.dart';
import 'package:prestaservicios/nucleo/env.dart';

class PantallaPrincipalGrid extends StatefulWidget {
  final dynamic usuario;
  final LocationData location;

  const PantallaPrincipalGrid({
    super.key,
    required this.usuario,
    required this.location,
  });

  @override
  _PantallaPrincipalGridState createState() => _PantallaPrincipalGridState();
}

class _PantallaPrincipalGridState extends State<PantallaPrincipalGrid> {
  // Ejemplo de datos para soporte
  late String wsp; // WhatsApp México
  late String tel; // Teléfono México
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  late List<Map<String, dynamic>> botones;
  late ControladorPrincipal controladorPrincipal;
  late ControladorPromocion controladorPromocion;

  int mensajesNuevos = 0;
  int cantidadinicial = 0;
  bool promobanner = false;
  List<Map<String, dynamic>> listabanners = [];
  late dynamic user;
  @override
  void initState() {
    super.initState();
    user = widget.usuario;
    final casopromo = RepositorioPromociones();
    controladorPromocion = ControladorPromocion(casopromo: casopromo);
    botones = [
      {
        "titulo": "Mi Perfil",
        "icono": Icons.person,
        "accion": () async {
          final rs = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PerfilScreen(usuario: user)),
          );
          if (rs != null && rs is Map && rs.containsKey("usuario")) {
            setState(() {
              user = rs["usuario"];
            });
          }
        },
      },
      {
        "titulo": "Publicar Servicios",
        "icono": Icons.add_box,
        "accion": () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MisServiciosScreen(
                servicios: [],
                usuarioId: widget.usuario.id.toString(),
              ),
            ),
          );
        },
      },
      {
        "titulo": "Mis Notificaciones",
        "icono": Icons.sms,
        "accion": () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ListaMensajesAdmin(id: widget.usuario.id.toString()),
            ),
          );
        },
      },
      {
        "titulo": "Mis Pagos",
        "icono": Icons.monetization_on,
        "accion": () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  MovimientosPagosScreen(usuario: widget.usuario.id.toString()),
            ),
          );
        },
      },
      {
        "titulo": "Mis Promociones",
        "icono": Icons.local_offer,
        "accion": () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ListaPromociones(usuario: widget.usuario.id.toString()),
            ),
          );
        },
      },
    ];
    wsp = "";
    tel = "";
    controladorPrincipal = ControladorPrincipal();
    _listarconf();
    initNotifications();
    _verificarMensajesNuevos();
    listarMensajesConImagenes();
  }

  void _listarconf() async {
    final ds = await controladorPrincipal.getConf();
    if (ds["success"] == true) {
      final conf = ds["mensaje"][0];
      setState(() {
        wsp = "${conf["wsp"]}";
        tel = "${conf["telefono"]}";
      });
    }
  }

  void _verificarMensajesNuevos() async {
    await listarMensajesInicial();
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (mounted) {
        await listarMensajes();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> listarMensajesConImagenes() async {
    try {
      final data = await controladorPromocion.getMensajes(
        widget.usuario.id.toString(),
      );

      if (data == null) return;
      if (data["success"] == true) {
        final datas = data["imagenes"];
        setState(() {
          listabanners = (datas as List)
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        });
      }
    } catch (e) {
      // Manejar el error si deseas
    }
  }

  Future<void> listarMensajesInicial() async {
    try {
      final data = await controladorPromocion.getMensajesNuevos(
        widget.usuario.id.toString(),
        0,
      );

      if (data == null) return;

      if (data["success"] == true) {
        final datas = data["mensaje"];
        int cnt = 0;

        if (datas != null && datas.isNotEmpty && datas[0]["total"] != null) {
          cnt = int.tryParse(datas[0]["total"].toString()) ?? 0;
        }

        if (mounted) {
          setState(() {
            cantidadinicial = cnt;
          });
        }
      }
    } catch (e) {
      // Manejar el error si deseas
    }
  }

  Future<void> listarMensajes() async {
    try {
      final data = await controladorPromocion.getMensajesNuevosChat(
        widget.usuario.id.toString(),
        cantidadinicial,
      );

      if (data == null) return;

      if (data["success"] == true) {
        final datas = data["mensaje"];
        int diferencia = 0;

        if (datas.isNotEmpty && datas[0]["total"] != null) {
          diferencia = int.tryParse(datas[0]["total"].toString()) ?? 0;
        }

        if (mounted && diferencia >= cantidadinicial) {
          if (diferencia > cantidadinicial) {
            await flutterLocalNotificationsPlugin.show(
              0,
              '¡Nuevos mensajes!',
              'Tienes mensajes nuevos',
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  'mensajes_channel',
                  'Mensajes',
                  channelDescription: 'Notificaciones de nuevos mensajes',
                  importance: Importance.max,
                  priority: Priority.high,
                ),
              ),
            );
          }

          setState(() {
            mensajesNuevos = diferencia - cantidadinicial;
            cantidadinicial = diferencia;
          });
        }
      }
    } catch (e) {
      // Manejar el error si deseas
    }
  }

  Future<void> initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text("Marketplace Servicios"),
          ),
          body: SafeArea(
            child:
                  MarketplaceScreen(
                      usuario: widget.usuario,
                      locationData: widget.location,
                      cat: "TODOS",
                    ),
          ),
          drawer: Drawer(
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenHeight = constraints.maxHeight;

                  return Column(
                    children: [
                      Expanded(child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            // Header
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(screenHeight * 0.02),
                              decoration: BoxDecoration(

                                  gradient: LinearGradient(colors: [Colors.purple,Colors.black])
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4), // espacio para el borde
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [Colors.white, Color(0xFF00695C)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 10,
                                          offset: Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: screenHeight * 0.07, // tamaño del avatar
                                      backgroundColor: Colors.grey[200], // color de fondo mientras carga la imagen
                                      backgroundImage: NetworkImage("${Env.dominio}${user.foto}"),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.02),
                                  Text(
                                    user.nombres,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: screenHeight * 0.02,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    user.email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: screenHeight * 0.02,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),


                          ],
                        ),
                      )),
                      // Opciones (botones convertidos a ListTile)
                      Expanded(
                        child: ListView(
                          children: botones.map((btn) {
                            return ListTile(
                              leading: Icon(btn["icono"], color: Colors.purple),
                              title: Text(
                                btn["titulo"],
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              onTap: () {
                                Navigator.pop(context); // cerrar drawer
                                btn["accion"]();
                              },
                            );
                          }).toList(),
                        ),
                      ),

                      Divider(),

                      // Soporte técnico
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1.0),
                        child: SoporteWidget(wsp: wsp, telefono: tel),
                      ),

                      Divider(),

                      // Cerrar sesión
                      ListTile(
                        leading: Icon(Icons.logout, color: Colors.red),
                        title: Text(
                          "Cerrar Sesión",
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: () async {
                          await AuthService.cerrarSesion();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => PantallaLogin()),
                          );
                        },
                      ),

                      SizedBox(height: 10),
                    ],
                  );
                },
              ),
            ),
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: () {
              setState(() {
                mensajesNuevos = 0;
              });
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ClientesScreen(usuario: widget.usuario.id.toString()),
                ),
              );
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.chat, color: Colors.white, size: 28),
                if (mensajesNuevos > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (listabanners.isNotEmpty)
          Positioned.fill(
            // Ocupa toda la pantalla
            child: Container(
              color: Colors.black54, // Fondo semi-transparente
              child: PageView.builder(
                itemCount: listabanners.length,
                itemBuilder: (context, index) {
                  final item = listabanners[index];
                  final imageUrl =
                      "${Env.dominio}uploads/promo/${item['imagen']}";
                  return Stack(
                    children: [
                      // Imagen a pantalla completa
                      Positioned.fill(
                        child: Image.network(imageUrl, fit: BoxFit.contain),
                      ),
                      // Botón de cerrar
                      Positioned(
                        top: 40,
                        right: 20,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              listabanners.removeAt(index);
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
