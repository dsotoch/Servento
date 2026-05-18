import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:prestaservicios/compartido/funciones.dart';

class MapaUbicacionScreen extends StatefulWidget {
  const MapaUbicacionScreen({super.key});

  @override
  State<MapaUbicacionScreen> createState() => _MapaUbicacionScreenState();
}

class _MapaUbicacionScreenState extends State<MapaUbicacionScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  LatLng? _center;
  LatLng? _selectedPosition;
  String? _lat;
  String? _long;
  String _direccion = "";
  List<dynamic> _sugerencias = [];
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _posicionActual();
  }

  // ✅ Obtiene la posición actual o usa Lima si no se puede
  Future<void> _posicionActual() async {
    try {
      bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
      if (!servicioHabilitado) {
        await Geolocator.openLocationSettings();
        Funciones().mostrarMensaje(
          "error",
          "Activa tu Ubicación y vuelve a Intentarlo.",
        );
        _usarLimaPorDefecto();
        return;
      }

      LocationPermission permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
        if (permiso == LocationPermission.denied) {
          Funciones().mostrarMensaje(
            "error",
            "Permiso de ubicación denegado.",
          );
          _usarLimaPorDefecto();
          return;
        }
      }

      if (permiso == LocationPermission.deniedForever) {
        Funciones().mostrarMensaje(
          "error",
          "Permiso de ubicación denegado permanentemente.",
        );
        _usarLimaPorDefecto();
        return;
      }

      Position posicion = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _center = LatLng(posicion.latitude, posicion.longitude);
      });
    } catch (e) {
      print("Error obteniendo ubicación: $e");
      _usarLimaPorDefecto();
    }
  }

  // ✅ Fallback a Lima
  void _usarLimaPorDefecto() {
    setState(() {
      _center = const LatLng(-12.0464, -77.0428);
      _direccion = "Lima, Perú";
    });
  }

  // 🔍 Busca sugerencias de direcciones usando Nominatim
  Future<void> _buscarSugerencias(String query) async {
    if (query.isEmpty) {
      setState(() => _sugerencias = []);
      return;
    }

    setState(() => _cargando = true);

    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5",
    );

    try {
      final response = await http.get(
        url,
        headers: {"User-Agent": "FlutterMapApp/1.0"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => _sugerencias = data);
      }
    } catch (e) {
      print("Error buscando sugerencias: $e");
    } finally {
      setState(() => _cargando = false);
    }
  }

  // ✅ Cuando el usuario selecciona una sugerencia
  void _seleccionarSugerencia(dynamic lugar) {
    final lat = double.parse(lugar['lat']);
    final lon = double.parse(lugar['lon']);
    final displayName = lugar['display_name'];

    setState(() {
      _selectedPosition = LatLng(lat, lon);
      _direccion = displayName;
      _searchController.text = displayName;
      _sugerencias = [];
      _mapController.move(_selectedPosition!, 16);
      _lat = lat.toString();
      _long = lon.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Si no se ha cargado aún la posición, muestra cargando
    if (_center == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return SafeArea(child: Scaffold(
      appBar: AppBar(title: const Text("Selecciona una ubicación")),
      body: Stack(
        children: [
          // 🗺️ Mapa base
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center!,
              initialZoom: 13,
              onTap: (tapPosition, point) async {
                try {
                  final lugares = await placemarkFromCoordinates(
                    point.latitude,
                    point.longitude,
                  );
                  String direccionFinal = "";
                  if (lugares.isNotEmpty) {
                    final lugar = lugares.first;
                    direccionFinal =
                    "${lugar.locality ?? ''}, ${lugar.country ?? ''}";
                  } else {
                    direccionFinal =
                    "Lat: ${point.latitude.toStringAsFixed(5)}, Lng: ${point.longitude.toStringAsFixed(5)}";
                  }

                  setState(() {
                    _selectedPosition = point;
                    _lat = point.latitude.toStringAsFixed(5);
                    _long = point.longitude.toStringAsFixed(5);
                    _direccion = direccionFinal;
                    _sugerencias = [];
                  });
                } catch (e) {
                  print("Error obteniendo dirección: $e");
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.app',
              ),
              if (_selectedPosition != null || _center != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 40,
                      height: 40,
                      point: _selectedPosition ?? _center!,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // 🔍 Campo de búsqueda con sugerencias
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Column(
              children: [
                Card(
                  elevation: 8,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Buscar dirección...",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _cargando
                          ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                          : IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () => _buscarSugerencias(
                          _searchController.text.trim(),
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                    onChanged: _buscarSugerencias,
                  ),
                ),

                if (_sugerencias.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _sugerencias.length,
                      itemBuilder: (context, index) {
                        final lugar = _sugerencias[index];
                        return ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text(
                            lugar['display_name'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _seleccionarSugerencia(lugar),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // ✅ Botón confirmar (visible si hay ubicación seleccionada)
          if (_selectedPosition != null || _center != null)
            Positioned(
              bottom: 20,
              left: 50,
              right: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text("Confirmar ubicación"),
                onPressed: () async {
                  final posicionFinal = _selectedPosition ?? _center!;
                  String direccionFinal = _direccion;

                  if (direccionFinal.isEmpty) {
                    final lugares = await placemarkFromCoordinates(
                      posicionFinal.latitude,
                      posicionFinal.longitude,
                    );
                    if (lugares.isNotEmpty) {
                      final lugar = lugares.first;
                      direccionFinal =
                      "${lugar.locality ?? ''}, ${lugar.country ?? ''}";
                    } else {
                      direccionFinal =
                      "Lat: ${posicionFinal.latitude.toStringAsFixed(5)}, Lng: ${posicionFinal.longitude.toStringAsFixed(5)}";
                    }
                  }

                  Navigator.pop(context, {
                    "direccion": direccionFinal,
                    "lat": posicionFinal.latitude,
                    "lng": posicionFinal.longitude,
                  });
                },
              ),
            ),
        ],
      ),
    ));
  }
}
