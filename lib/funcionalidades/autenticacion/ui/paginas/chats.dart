import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:prestaservicios/funcionalidades/principal/ui/controlador/controladorPrincipal.dart';
import 'package:prestaservicios/nucleo/env.dart';

class Cliente {
  final String nombre;
  final String fotoUrl;
  final String tipo; // "wsp" o "chat"
  final String contacto; // ID o número

  Cliente({
    required this.nombre,
    required this.fotoUrl,
    required this.tipo,
    required this.contacto,
  });
}

// Lista de clientes
class ClientesScreen extends StatefulWidget {
  final String usuario;
  const ClientesScreen({super.key, required this.usuario});

  @override
  _ClientesScreenState createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  List<Cliente> clientes = [];
  List<String> clientesNuevos = [];

  late ControladorPrincipal controladorPrincipal;
  late Timer _timer;
  @override
  void initState() {
    super.initState();
    controladorPrincipal = ControladorPrincipal();
    // Aquí puedes cargar tus clientes desde PHP o API
    cargarClientes();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      await cargarClientesNuevos();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> cargarClientesNuevos() async {
    // Ejemplo temporal, luego reemplazar con la llamada a tu API
    final data = await controladorPrincipal.getClientesNuevos(widget.usuario);
    if (data["success"] == true) {
      final rs = data["mensaje"] as List;
      setState(() {
        clientesNuevos = rs.map((e) => e["id"].toString()).toList();
      });
    }
  }

  void cargarClientes() async {
    // Ejemplo temporal, luego reemplazar con la llamada a tu API
    final data = await controladorPrincipal.getClientes(widget.usuario);
    if (data["success"] == true) {
      final rs = data["mensaje"] as List;
      setState(() {
        clientes = rs
            .map(
              (e) => Cliente(
                nombre: e["nombres"] ?? "Sin nombre",
                fotoUrl: e["foto"] ?? "https://i.pravatar.cc/150",
                tipo: "chat",
                contacto: e["id"].toString() ?? "",
              ),
            )
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Clientes"), backgroundColor: Colors.purple),
      body: clientes.isEmpty
          ? Center(child: Text("No se Encontraron Chats."))
          : ListView.separated(
              padding: EdgeInsets.all(12),
              itemCount: clientes.length,
              separatorBuilder: (_, __) => Divider(height: 12),
              itemBuilder: (context, index) {
                final cliente = clientes[index];
                final tieneMensajesNuevos = clientesNuevos.contains(
                  cliente.contacto,
                );
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      '${Env.dominio}${cliente.fotoUrl}',
                    ),
                  ),
                  title: Text(cliente.nombre),
                  subtitle: Text(
                    cliente.tipo == "wsp" ? "WhatsApp" : "Chat interno",
                  ),
                  trailing: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        Icons.chat,
                        color: cliente.tipo == "wsp"
                            ? Colors.green
                            : Colors.teal,
                      ),
                      if (tieneMensajesNuevos)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: 20,
                            height: 15,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      clientesNuevos.remove(cliente.contacto);
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          cliente: cliente,
                          usuarioId: widget.usuario, // tu ID
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

// Chat adaptado tipo WhatsApp
class ChatScreen extends StatefulWidget {
  final Cliente cliente;
  final String usuarioId; // ID del usuario actual

  const ChatScreen({super.key, required this.cliente, required this.usuarioId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> mensajes = [];
  late ControladorPrincipal controladorPrincipal;
  Timer? _timer; // <-- Timer global para cancelar

  @override
  void initState() {
    super.initState();
    controladorPrincipal = ControladorPrincipal();
    cargarMensajes();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      await cargarMensajes();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> cargarMensajes() async {
    final res = await controladorPrincipal.getMensajes(
      widget.cliente.contacto,
      widget.usuarioId,
    );
    if (res["success"] == true && mounted) {
      setState(() {
        mensajes = List<Map<String, dynamic>>.from(res['mensajes']);
      });
      _scrollAlFinal();
    }
  }

  void enviarMensaje() async {
    final texto = _controller.text.trim();
    final phoneRegex = RegExp(r'\+?\d{6,15}');

    if (texto.isEmpty) return;

    if (phoneRegex.hasMatch(texto)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("No se permiten números de teléfono en el mensaje."),
        ),
      );
      return;
    }
    setState(() {
      mensajes.add({"mensaje": texto, "remitente": widget.usuarioId});
    });
    _controller.clear();
    _scrollAlFinal();
    await controladorPrincipal.enviarMensaje(
      widget.usuarioId,
      widget.cliente.contacto,
      texto,
    );
  }

  void _scrollAlFinal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 60,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: (widget.cliente.fotoUrl.isNotEmpty)
                    ? NetworkImage('${Env.dominio}${widget.cliente.fotoUrl}')
                    : null,
                child: (widget.cliente.fotoUrl.isEmpty)
                    ? Icon(Icons.person, color: Colors.white, size: 20)
                    : null,
              ),
              SizedBox(width: 10),
              Text(widget.cliente.nombre),
            ],
          ),
          backgroundColor: Colors.purple,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(12),
                itemCount: mensajes.length,
                itemBuilder: (context, index) {
                  final msg = mensajes[index];
                  final esUsuario =
                      msg['remitente'].toString() ==
                      widget.usuarioId.toString();
                  final fecha = msg['fecha'] ?? '';

                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    alignment: esUsuario
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: esUsuario
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: esUsuario
                                ? Colors.teal
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg['mensaje'],
                                style: TextStyle(
                                  color: esUsuario
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                fecha,
                                style: TextStyle(
                                  color: esUsuario
                                      ? Colors.white70
                                      : Colors.black54,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Divider(height: 1),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Escribe un mensaje...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.teal),
                    onPressed: enviarMensaje,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
