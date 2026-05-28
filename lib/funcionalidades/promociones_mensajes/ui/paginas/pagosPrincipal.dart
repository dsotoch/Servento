import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prestaservicios/compartido/funciones.dart';
import 'package:prestaservicios/funcionalidades/promociones_mensajes/datos/modelos/pagoAsignado.dart';
import 'package:prestaservicios/funcionalidades/promociones_mensajes/datos/repositorios/repositorioPromociones.dart';
import 'package:prestaservicios/funcionalidades/promociones_mensajes/ui/controladores/controladorPromocion.dart';
import 'package:prestaservicios/funcionalidades/promociones_mensajes/ui/paginas/pagos.dart';
import 'package:prestaservicios/funcionalidades/usuario/modelos/pagos.dart';

class MovimientosPagosScreen extends StatefulWidget {
  final VoidCallback? onIrAPagar;
  final String usuario;

  const MovimientosPagosScreen({
    Key? key,
    this.onIrAPagar,
    required this.usuario,
  }) : super(key: key);

  @override
  State<MovimientosPagosScreen> createState() => _MovimientosPagosScreenState();
}

class _MovimientosPagosScreenState extends State<MovimientosPagosScreen> {
  bool cargando = true;

  late ControladorPromocion controladorPromocion;
  List<Pagos> listapagos = [];
  PagoAsignado? promocionActual;

  @override
  void initState() {
    super.initState();
    final usoPromo = RepositorioPromociones();
    controladorPromocion = ControladorPromocion(casopromo: usoPromo);
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    await _obtenerPromocion();
    await _obtenerPagos();
  }

  Future<void> _obtenerPromocion() async {
    try {
      final rs = await controladorPromocion.getPagos("", widget.usuario);
      print(rs);
      if (rs["success"] == true) {
        final da = rs["mensaje"] as List;
        if (da.isNotEmpty) {
          setState(() {
            promocionActual = PagoAsignado.fromJson(da.first);
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _obtenerPagos() async {
    try {
      final pagos = await controladorPromocion.getPagosTodos(widget.usuario);
      if (pagos["success"] == true) {
        final data = pagos["mensaje"] as List;
        setState(() {
          listapagos = List<Pagos>.from(data.map((e) => Pagos.fromJson(e)));
          cargando = false;
        });
      } else {
        setState(() {
          listapagos = [];
          cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        listapagos = [];
        cargando = false;
      });
    }
  }

  Color _estadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'exitoso':
        return Colors.green;
      case 'pendiente':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Movimientos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.payment, color: Colors.white),
            onPressed: () async {
              final data = await controladorPromocion.paymentSecret(
                widget.usuario,
              );
              if (data["success"] == true) {
                final dat = data["mensaje"] as List;
                if (dat.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PagoScreen(
                        paymentSecret: dat[0]["codigostripe"],
                        paymentIntentId: dat[0]["stripe_payment_intent_id"],
                      ),
                    ),
                  );
                } else {
                  Funciones().mostrarMensaje(
                    "error",
                    "Aun No Se te ha Asignado Ningun Plan",
                  );
                }
              } else {
                Funciones().mostrarMensaje("error", data["mensaje"]);
              }
            },
          ),
        ],
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarDatos,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 🔹 MOSTRAR PROMOCIÓN ACTUAL
                  if (promocionActual != null)
                    _cardPromocion(promocionActual!)
                  else
                    const Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Text(
                        "No tienes un plan asignado por el momento.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // 🔹 LISTA DE PAGOS
                  if (listapagos.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: Text(
                          'No hay movimientos de pagos disponibles',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                    )
                  else
                    ...listapagos.map(
                      (pago) => Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _estadoColor(pago.estado ?? ""),
                            child: Icon(
                              pago.estado?.toLowerCase() == 'exitoso'
                                  ? Icons.check
                                  : Icons.pending,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            'Pago #${pago.idAsignacion} - S/${pago.montoAsignado}',
                          ),
                          subtitle: Text(
                            '${pago.metodoPago} • 📅 ${pago.fechaAsignacion == null ? "Pendiente de pago" : pago.fechaAsignacion}',
                          ),
                          trailing: Text(
                            pago.estado!.toUpperCase(),
                            style: TextStyle(
                              color: _estadoColor(pago.estado ?? ''),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final data = await controladorPromocion.paymentSecret(widget.usuario);
          if (data["success"] == true) {
            final dat = data["mensaje"] as List;
            if (dat.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PagoScreen(
                    paymentSecret: dat[0]["codigostripe"],
                    paymentIntentId: dat[0]["stripe_payment_intent_id"],
                  ),
                ),
              );
            } else {
              Funciones().mostrarMensaje(
                "error",
                "Aun No Se te ha Asignado Ningun Plan",
              );
            }
          } else {
            Funciones().mostrarMensaje("error", data["mensaje"]);
          }
        },
        label: const Text('Pagar'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  // 🔹 WIDGET DE LA PROMOCIÓN (EL MISMO QUE EL DE PagoScreen)
  Widget _cardPromocion(PagoAsignado p) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.black87, Colors.purple]),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Mi Plan Actual:",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            // Estado
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                p.estado.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
            const SizedBox(height: 12),

            Text(
              p.descripcionPlan,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Icon(
                  Icons.monetization_on,
                  size: 20,
                  color: Colors.green.shade700,
                ),
                const SizedBox(width: 6),
                Text(
                  "Costo:  S/ ${p.monto ?? 0}",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              children: [
                // 🔹 Chip con la fecha asignada
                if (p.estado == "exitoso")
                  Chip(
                    label: Text(
                      "Desde: ${DateFormat('dd/MM/yyyy').format(p.fechaAsignada)}",
                    ),
                    backgroundColor: Colors.blue.shade50,
                  ),

                // 🔹 Chip con el estado
                if (p.estado == "pendiente")
                  Chip(
                    label: Text(
                      "Vigencia ${p.diasVigencia} dias",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Colors.green.shade50,
                  ),
                if (p.estado == "exitoso")
                  Chip(
                    label: Text(
                      "Hasta: ${DateFormat('dd/MM/yyyy').format(p.fechaAsignada.add(Duration(days: int.tryParse(p.diasVigencia)!)))} ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Colors.green.shade50,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
