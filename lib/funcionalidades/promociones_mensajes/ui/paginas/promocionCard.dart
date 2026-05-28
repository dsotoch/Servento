import 'package:flutter/material.dart';
import 'package:prestaservicios/compartido/colores.dart';
import 'package:prestaservicios/compartido/funciones.dart';
import 'package:prestaservicios/funcionalidades/promociones_mensajes/datos/modelos/modeloPromociones.dart';
import 'package:prestaservicios/funcionalidades/promociones_mensajes/datos/repositorios/repositorioPromociones.dart';
import 'package:prestaservicios/funcionalidades/promociones_mensajes/ui/controladores/controladorPromocion.dart';
import 'package:prestaservicios/funcionalidades/promociones_mensajes/ui/paginas/pagosPrincipal.dart';

class PromocionCard extends StatefulWidget {
  final Promocion promocion;
  final String usuario;
  
  const PromocionCard({
    Key? key,
    required this.promocion,
    required this.usuario,
  }) : super(key: key);

  @override
  _PromocionCardState createState() => _PromocionCardState();
}

class _PromocionCardState extends State<PromocionCard> {
  late ControladorPromocion controladorPromocion;
  Color _estadoColor(String? estado) {
    switch (estado) {
      case 'activo':
        return Colors.green.shade600;
      case 'pendiente':
        return Colors.orange.shade600;
      default:
        return Colors.red.shade600;
    }
  }

  bool procesando = false;
  @override
  void initState() {
    final casopromo = RepositorioPromociones();
    controladorPromocion = ControladorPromocion(casopromo: casopromo);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.black87, Colors.purple]),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: procesando
            ? null
            : () async {
                final res = await Funciones().mostrarConfirmacion(
                  context: context,
                  titulo: "Confirmación",
                  mensaje: "¿Seguro de Asignar la Promoción?",
                );
                if (!res) return;
                setState(() {
                  procesando = true;
                });
                final rs = await controladorPromocion.asignarPromocion(
                  widget.promocion.id.toString(),
                  widget.usuario,
                );
                setState(() {
                  procesando = false;
                });
                if (rs["success"] == true) {
                 await Funciones().mostrarMensaje("ok", rs["mensaje"]);
                 Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MovimientosPagosScreen(usuario: widget.usuario),));
                } else {
                  Funciones().mostrarMensaje("error", rs["mensaje"]);
                }
              },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: procesando
              ? Text("Procesando...",style: TextStyle(color: Colors.white),)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 Encabezado
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _estadoColor(
                              widget.promocion.estado,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.promocion.estado?.toUpperCase() ??
                                'SIN ESTADO',
                            style: TextStyle(
                              color: _estadoColor(widget.promocion.estado),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.promocion.titulo,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    // 🔹 Descripción
                    if (widget.promocion.descripcion != null)
                      Text(
                        widget.promocion.descripcion??'',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                        maxLines: 50,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 12),
                    // 🔹 Detalles de promoción
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.money,
                              size: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Costo:  S/ ${widget.promocion.descuento ?? 0}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // 🔹 Tipo y categoría
                    Wrap(
                      spacing: 8,
                      children: [
                        if (widget.promocion.tipo != null)
                          Chip(
                            label: Text(
                              "Exclusiva para: ${widget.promocion.tipo!.toUpperCase()}",
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: Colors.blue.shade50,
                          ),
                        if (widget.promocion.categoria!=null  && widget.promocion.categoria != '' )
                          Chip(
                            label: Text(
                              widget.promocion.categoria??'',
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: Colors.purple.shade50,
                          ),

                        Chip(
                          label: Text(
                            "Vigencia ${widget.promocion.diasVigencia??0} dias",
                            style: const TextStyle(fontSize: 12,color: Colors.white),
                          ),
                          backgroundColor: Colores.color_primario,
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
