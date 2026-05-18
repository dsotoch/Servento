import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' hide LocationAccuracy;
import 'package:prestaservicios/compartido/funciones.dart';
import 'package:prestaservicios/funcionalidades/servicios/datos/modelos/modeloServicioVista.dart';
import 'package:prestaservicios/funcionalidades/servicios/datos/repositorios/repositorioServicio.dart';
import 'package:prestaservicios/funcionalidades/usuario/ui/controladores/controladorServicio.dart';

class FiltroDistanciaScreen extends StatefulWidget {
  LocationData locationData;
  double radio;
  FiltroDistanciaScreen({super.key, required this.locationData,required this.radio});

  @override
  State<FiltroDistanciaScreen> createState() => _FiltroDistanciaScreenState();
}

class _FiltroDistanciaScreenState extends State<FiltroDistanciaScreen> {
  LatLng? _ubicacionActual;
  late double _radioKm;
  bool _buscando = false;
  List<dynamic> _resultados = [];

  late ControladorServicio controladorServicio;
  @override
  void initState() {
    super.initState();
    _obtenerUbicacion();
    final casoUsoServicio = RepositorioServicio();
    controladorServicio = ControladorServicio(casoUsoServicio: casoUsoServicio);
    _radioKm=widget.radio;
  }

  Future<void> _obtenerUbicacion() async {
    bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) {
      await Geolocator.openLocationSettings();
      Funciones().mostrarMensaje(
        "error",
        "Activa tu ubicación y vuelve a intentarlo.",
      );
      return;
    }

    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        Funciones().mostrarMensaje("error", "Permiso de ubicación denegado.");
        return;
      }
    }

    if (permiso == LocationPermission.deniedForever) {
      Funciones().mostrarMensaje(
        "error",
        "Permiso de ubicación denegado permanentemente.",
      );
      return;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _ubicacionActual = LatLng(pos.latitude, pos.longitude);
    });
  }

  Future<void> _buscarServiciosCercanos() async {
    if (widget.locationData == null) {
      Funciones().mostrarMensaje("error", "Ubicación no disponible");
      return;
    }

    setState(() => _buscando = true);


    Funciones().mostrarMensaje("info", "Buscando servicios a ${_radioKm.toStringAsFixed(2)} km...");

    try {


      final data = await controladorServicio.listarServiciosGeneral(
        "0",
        "100",
        widget.locationData.latitude.toString(),
        widget.locationData.longitude.toString(),
        _radioKm.toString(),
      );



      if (data["success"] == true) {
        final rs = data["mensaje"] as List;
        final List<Modeloserviciovista> lista = List<Modeloserviciovista>.from(
          rs.map((e) => Modeloserviciovista.fromJson(e)),
        ).toList();
        setState(() {
          _buscando = false;
        });
        Funciones().mostrarMensaje(
          "success",
          "${lista.length} servicios encontrados",
        );
        Navigator.pop(context, {"lista":lista,"radio":_radioKm});
      } else {
        Funciones().mostrarMensaje(
          "error",
          "No se pudieron obtener servicios cercanos",
        );
      }
    } catch (e) {
      Funciones().mostrarMensaje("error", "Error: $e");
    } finally {
      setState(() => _buscando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Filtrar por distancia")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Selecciona el radio de búsqueda:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _radioKm,
              min: 50,
              max: 30000,
              divisions: 199,
              label: "${_radioKm.round()} km",
              onChanged: (v) => setState(() => _radioKm = v),
            ),
            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: _buscando ? null : _buscarServiciosCercanos,
              icon: const Icon(Icons.search),
              label: Text(
                _buscando ? "Buscando..." : "Buscar servicios cercanos",
              ),
            ),

            const SizedBox(height: 20),

            if (_buscando)
              const CircularProgressIndicator()
            else if (_resultados.isEmpty)
              const Text("No hay resultados aún.")
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _resultados.length,
                  itemBuilder: (context, index) {
                    final s = _resultados[index];
                    return ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(s['titulo'] ?? "Sin título"),
                      subtitle: Text(s['ubicacion'] ?? "Sin dirección"),
                      trailing: Text("${s['precio']}"),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
