import 'package:flutter/material.dart';
import 'package:prestaservicios/funcionalidades/promociones_mensajes/datos/modelos/modeloPromociones.dart';
import 'package:prestaservicios/funcionalidades/promociones_mensajes/datos/repositorios/repositorioPromociones.dart';
import 'package:prestaservicios/funcionalidades/promociones_mensajes/dominio/casosUso/casoUsoPromocionesMensajes.dart';
import 'package:prestaservicios/funcionalidades/promociones_mensajes/ui/controladores/controladorPromocion.dart';
import 'package:prestaservicios/funcionalidades/promociones_mensajes/ui/paginas/promocionCard.dart';

class ListaPromociones extends StatefulWidget {
  final Function(Promocion)? onSelect;
  final String usuario;
  const ListaPromociones({Key? key, this.onSelect,required this.usuario}) : super(key: key);

  @override
  State<ListaPromociones> createState() => _ListaPromocionesState();
}

class _ListaPromocionesState extends State<ListaPromociones> {
  late ControladorPromocion controladorPromocion;
  List<Promocion> promociones = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    final casoUsoPromociones casopromo = RepositorioPromociones();
    controladorPromocion = ControladorPromocion(casopromo: casopromo);
    listarPromociones();
  }

  Future<void> listarPromociones() async {
    try {
      final data = await controladorPromocion.getpromociones();
      if (data["success"] == true) {
        final datos = data["mensaje"] as List;
        final List<Promocion> listapromo = List<Promocion>.from(
          datos.map((e) => Promocion.fromJson(e)),
        ).toList();
        setState(() {
          promociones = listapromo;
          cargando = false;
        });
      }else{
        setState(() {
          cargando=false;

        });
      }
    } catch (e) {
      debugPrint('Error al cargar promociones: $e');
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Promociones-Planes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : promociones.isEmpty
          ? const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Text(
            '😕 No hay promociones disponibles por el momento',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      )
          : RefreshIndicator(
        onRefresh: listarPromociones,
        child: ListView.builder(

          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          itemCount: promociones.length,
          itemBuilder: (context, index) {
            final promocion = promociones[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: PromocionCard(
                promocion: promocion,
                 usuario: widget.usuario,
              ),
            );
          },
        ),
      ),
    );
  }
}
