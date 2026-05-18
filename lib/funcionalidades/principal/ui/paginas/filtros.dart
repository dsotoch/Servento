import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/dominio/entidades/usuario.dart';
import 'package:prestaservicios/funcionalidades/principal/ui/controlador/controladorPrincipal.dart';
import 'package:prestaservicios/funcionalidades/principal/ui/paginas/buscador.dart';
import 'package:prestaservicios/funcionalidades/usuario/ui/controladores/controladorServicio.dart';

class CategoriasScreen extends StatefulWidget {
  final Usuario usuario;
  final LocationData locationData;
  const CategoriasScreen({
    Key? key,
    required this.locationData,
    required this.usuario,
  }) : super(key: key);

  @override
  _CategoriasScreenState createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  late ControladorPrincipal controladorPrincipal;
  Map<String, List<String>> categorias = {};
  String filtro = "";

  @override
  void initState() {
    super.initState();
    controladorPrincipal = ControladorPrincipal();
    cargarcategorias();
  }

  void cargarcategorias() async {
    final data = await controladorPrincipal.getCategorias();
    final Map<String, List<String>> categoriasMap = {};

    if (data['success'] == true) {
      final List<dynamic> categoriasList = data['mensaje'];

      for (var item in categoriasList) {
        final catNombre = item['categoria_nombre'] ?? "Sin categoría";
        final subNombre = item['subcategoria_nombre'] ?? "Sin subcategoría";

        if (categoriasMap.containsKey(catNombre)) {
          categoriasMap[catNombre]!.add(subNombre);
        } else {
          categoriasMap[catNombre] = [subNombre];
        }
      }
    }

    setState(() {
      categorias = categoriasMap;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (categorias.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Categorías"),
          backgroundColor: Colors.purple,
        ),
        body: Center(child: CircularProgressIndicator(color: Colors.purple)),
      );
    }

    // Filtrar categorías
    Map<String, List<String>> categoriasFiltradas = {};
    categorias.forEach((key, value) {
      final subFiltradas = value
          .where((sub) => sub.toLowerCase().contains(filtro.toLowerCase()))
          .toList();
      if (subFiltradas.isNotEmpty) {
        categoriasFiltradas[key] = subFiltradas;
      }
    });

    // Crear lista de tarjetas
    List<Widget> tarjetas = [];

    // Tarjeta "Todos"
    tarjetas.add(
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MarketplaceScreen(
                usuario: widget.usuario,
                locationData: widget.locationData,
                cat: "TODOS",
              ),
            ),
          );
        },
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(1),
          ),
          elevation: 6, // sombra más visible
          color: Colors.transparent, // importante para ver el gradiente
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8E24AA), Colors.black87], // morado a negro
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 20),
            alignment: Alignment.center,
            child: const Text(
              "💫 VER TODOS",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        )
      ),
    );

    // Tarjetas de categorías
    categoriasFiltradas.entries.forEach((entry) {
      tarjetas.add(
        Card(
          margin: EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 3,
          child: ExpansionTile(
            tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            collapsedBackgroundColor: Color(0xFF7B1FA2), // morado vibrante
            backgroundColor: Color(0xFF4A148C), // morado oscuro intenso
            textColor: Colors.white,
            collapsedTextColor: Colors.white,
            iconColor: Colors.white,
            collapsedIconColor: Colors.white,
            title: Text(
              entry.key,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            children: entry.value
                .map(
                  (sub) => ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 32),
                title: Text(
                  sub,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                trailing: Icon(Icons.arrow_forward_ios,
                    color: Colors.white70, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MarketplaceScreen(
                        usuario: widget.usuario,
                        locationData: widget.locationData,
                        cat: sub,
                      ),
                    ),
                  );
                },
              ),
            )
                .toList(),
          ),
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("Categorías"),
        backgroundColor: Colors.purple,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(1)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            SizedBox(height: 15),
            Expanded(
              child: tarjetas.isEmpty
                  ? Center(
                child: Text(
                  "No se encontraron resultados",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
                  : ListView(children: tarjetas),
            ),
          ],
        ),
      ),
    );
  }
}
