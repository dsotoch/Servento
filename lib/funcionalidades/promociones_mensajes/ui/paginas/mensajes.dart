import 'package:flutter/material.dart';
import 'package:prestaservicios/funcionalidades/promociones_mensajes/datos/repositorios/repositorioPromociones.dart';
import 'package:prestaservicios/funcionalidades/promociones_mensajes/dominio/casosUso/casoUsoPromocionesMensajes.dart';
import 'package:prestaservicios/funcionalidades/promociones_mensajes/ui/controladores/controladorPromocion.dart';

/// ===== Modelo del mensaje =====
class Mensaje {
  final String? id;
  final String? contenido;
  final String? fecha;
  final String? servicio;

  Mensaje({this.id, this.contenido, this.fecha, this.servicio});

  factory Mensaje.fromJson(Map<String, dynamic> json) => Mensaje(
    id: json['id']?.toString(),
    contenido: json['mensaje'] ?? '',
    fecha: json['fecha'] ?? '',
    servicio: json['servicio'] ?? '',
  );
}

/// ===== Widget principal =====
class ListaMensajesAdmin extends StatefulWidget {
  final String id;
  const ListaMensajesAdmin({Key? key,required this.id}) : super(key: key);

  @override
  State<ListaMensajesAdmin> createState() => _ListaMensajesAdminState();
}

class _ListaMensajesAdminState extends State<ListaMensajesAdmin> {
  List<Mensaje> mensajes = [];
  bool cargando = true;
  late final ControladorPromocion controladorPromocion;
  @override
  void initState() {
    super.initState();
    final casoUsoPromociones = RepositorioPromociones();
    controladorPromocion = ControladorPromocion(casopromo: casoUsoPromociones);
    listarMensajes();
  }

  /// Simula una carga de mensajes desde un servidor
  Future<void> listarMensajes() async {
    try {
      final data = await controladorPromocion.getMensajes(widget.id);
      if (data["success"] == true) {
        final datas = data["mensaje"] as List;
        final lista = datas.map((e) => Mensaje.fromJson(e)).toList();
        if (mounted) {
          setState(() {
            mensajes = lista;
            cargando = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error al cargar mensajes: $e');
      if (mounted) setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mensajes del Sistema',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : mensajes.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Text(
                  '💬 No hay mensajes por el momento',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: listarMensajes,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: mensajes.length,
                itemBuilder: (context, index) {
                  final mensaje = mensajes[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _MensajeCard(mensaje: mensaje),
                  );
                },
              ),
            ),
    );
  }
}

/// ===== Widget para cada mensaje =====
class _MensajeCard extends StatelessWidget {
  final Mensaje mensaje;

  const _MensajeCard({Key? key, required this.mensaje}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.blueAccent,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Administrador',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const Spacer(),
                Text(
                  mensaje.fecha ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            if (mensaje.servicio != "") ...[
              const SizedBox(height: 12),
              Text(
                mensaje.servicio!.toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ],

            const SizedBox(height: 12),

            Text(
              mensaje.contenido ?? 'Mensaje sin contenido',
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
