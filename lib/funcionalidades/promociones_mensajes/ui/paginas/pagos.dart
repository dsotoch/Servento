import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:prestaservicios/compartido/funciones.dart';
import 'package:prestaservicios/funcionalidades/promociones_mensajes/datos/repositorios/repositorioPromociones.dart';
import 'package:prestaservicios/funcionalidades/promociones_mensajes/ui/controladores/controladorPromocion.dart';
import 'package:url_launcher/url_launcher.dart';

class PagoScreen extends StatefulWidget {
  final String paymentSecret; // client_secret
  final String paymentIntentId; // id del PaymentIntent

  const PagoScreen({
    super.key,
    required this.paymentSecret,
    required this.paymentIntentId,
  });

  @override
  State<PagoScreen> createState() => _PagoScreenState();
}

class _PagoScreenState extends State<PagoScreen> {
  bool _isLoading = false;
  bool _aplicandoCupon = false;

  String _clientSecret = "";
  String _cupon = "";
  double? _nuevoMonto;

  Map<String, dynamic>? _promoData; // datos completos del cupon

  late ControladorPromocion controladorPromocion;

  @override
  void initState() {
    super.initState();
    _clientSecret = widget.paymentSecret;
    final repo = RepositorioPromociones();
    controladorPromocion = ControladorPromocion(casopromo: repo);
  }

  // Helper visual para mostrar fila de info
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ---------------- VALIDAR CUPÓN ------------------
  Future<void> _validarCupon() async {
    if (_cupon.isEmpty) {
      Funciones().mostrarMensaje("error", "Ingrese un código de cupón");
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _aplicandoCupon = true);

    try {
      final rs = await controladorPromocion.validarCupon(
        _cupon,
        widget.paymentIntentId,
      );

      if (rs["success"] == true) {
        setState(() {
          _nuevoMonto = double.tryParse(rs["nuevo_amount"].toString());
          _clientSecret = rs["client_secret"];
          _promoData = rs["data"]; // guardar info del cupón
        });

        Funciones().mostrarMensaje("ok", "Cupón aplicado correctamente");
      } else {
        Funciones().mostrarMensaje("error", rs["mensaje"] ?? "Cupón inválido");
      }
    } catch (e) {
      Funciones().mostrarMensaje("error", "Error al validar cupón: $e");
    } finally {
      setState(() => _aplicandoCupon = false);
    }
  }

  // ---------------- INICIAR PAGO ------------------
  Future<void> _iniciarPago() async {
    setState(() => _isLoading = true);

    try {
      print(_clientSecret);
      final uri = Uri.parse(_clientSecret);

      if (await launchUrl(uri)) {
        await Funciones().mostrarMensaje(
          "ok",
          'Sigue con el proceso de  pago...',
        );
      } else {
        throw new Exception("No se pudo abrir el enlace de Pago.");
      }

      Navigator.pop(context);
    } catch (e) {
      Funciones().mostrarMensaje("error", 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ---------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Continuar con el Pago')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff6a11cb), Color(0xff2575fc)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.elasticOut,
                  builder: (context, scale, child) {
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: Hero(
                    tag: "cuca_logo",
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Expanded(
                        child: Image.asset(
                          "assets/images/cuca.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              /*Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "¿Tienes un cupón?",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        onChanged: (v) => _cupon = v,
                        decoration: const InputDecoration(
                          labelText: "Código de cupón",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _aplicandoCupon || _promoData != null
                              ? null
                              : () => _validarCupon(),
                          child: _aplicandoCupon
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text("Aplicar cupón"),
                        ),
                      ),

                      // ------------ CARD INFORMACIÓN DEL CUPÓN --------------
                      if (_promoData != null) ...[
                        const SizedBox(height: 12),
                        Card(
                          color: Colors.green.shade50,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Cupón aplicado",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                _infoRow(
                                  "Monto original:",
                                  " ${_promoData!['monto_original']}",
                                ),
                                _infoRow(
                                  "Descuento:",
                                  "${_promoData!['descuento']}",
                                ),
                                _infoRow(
                                  "Monto final:",
                                  " ${_nuevoMonto!.toStringAsFixed(2)}",
                                ),
                                _infoRow(
                                  "Código aplicado:",
                                  _promoData!['cupon'].toString(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              )*/
              const Spacer(),

              // -------------------- BOTÓN DE PAGO --------------------
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _iniciarPago,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.payment),
                label: Text(_isLoading ? 'Procesando...' : 'Pagar ahora'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 24,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
