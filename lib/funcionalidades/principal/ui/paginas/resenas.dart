import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prestaservicios/compartido/funciones.dart';
import 'package:prestaservicios/funcionalidades/servicios/datos/modelos/modeloComenta.dart';
import 'package:prestaservicios/funcionalidades/servicios/datos/modelos/modeloComentarios.dart';
import 'package:prestaservicios/funcionalidades/servicios/datos/repositorios/repositorioServicio.dart';
import 'package:prestaservicios/funcionalidades/usuario/ui/controladores/controladorServicio.dart';
import 'package:prestaservicios/nucleo/env.dart';

class ServiceReviewScreen extends StatelessWidget {
  final String serviceId;
  final String usuario;
  final Map<String, dynamic> serviceProvider;
  final List<ComentarioModel> initialReviews;

  const ServiceReviewScreen({
    super.key,
    required this.serviceId,
    required this.serviceProvider,
    required this.initialReviews,
    required this.usuario
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reseñas del servicio')),
      body: ServiceReviewSection(
        serviceId: serviceId,
        serviceProvider: serviceProvider,
        initialReviews: initialReviews,
        usuario: usuario,
      ),
    );
  }
}

class ServiceReviewSection extends StatefulWidget {
  final String serviceId;
  final String usuario;
  final Map<String, dynamic> serviceProvider;
  late List<ComentarioModel> initialReviews;

   ServiceReviewSection({
    super.key,
    required this.serviceId,
    required this.serviceProvider,
    required this.usuario,
     required this.initialReviews
  });

  @override
  State<ServiceReviewSection> createState() => _ServiceReviewSectionState();
}

class _ServiceReviewSectionState extends State<ServiceReviewSection> {
  final TextEditingController _commentController = TextEditingController();
  double _rating = 0.0;
  late bool cargando=false;
  late List<ComentarioModel> _reviews;
  late ControladorServicio controladorServicio;

  @override
  void initState() {
    super.initState();
    _reviews = List.from(widget.initialReviews);
    final casoUsoServicio = RepositorioServicio();
    controladorServicio = ControladorServicio(casoUsoServicio: casoUsoServicio);
  }

  void _submitReview( usuario_id, servicioId) async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _rating == 0.0) {
      await Funciones().mostrarMensaje(
        "error",
        "Ingrese comentario y calificacion de estrellas",
      );
      return;
    }
    if(! await Funciones().mostrarConfirmacion(context: context, titulo: "Confirmación", mensaje: "¿Enviar Comentario?")){
      return;
    }
    setState(() {
      cargando=true;
    });
    final comentario = _commentController.text.trim();
    final estrellas = _rating.toString();
    final ModeloComenta modelo = ModeloComenta(
      comentario: comentario,
      estrellas: estrellas,
      usuarioId: usuario_id,
      servicioId: servicioId,
    );
    final rsp = await controladorServicio.guardarComentario(modelo);
    setState(() {
      cargando=false;
    });
    if (rsp["success"] == true) {
      await Funciones().mostrarMensaje("ok", rsp["mensaje"]);
      final data = await controladorServicio
          .listarComentarios(
        "comentarios",
        widget.serviceId,
      );
        final comentarios=data["mensaje"] as List;
        final List<ComentarioModel> listacomentarios=List<ComentarioModel>.from(
            comentarios.map((e)=>ComentarioModel.fromJson(e))
        ).toList();

        setState(() {
          _reviews=List.from(listacomentarios);
        });
    } else {
      await Funciones().mostrarMensaje("error", rsp["mensaje"]);
      return;
    }
    _commentController.clear();
    _rating = 0.0;
  }

  double _averageRating() {
    if (_reviews.isEmpty) return 0.0;
    double sum = 0;
    for (var r in _reviews) {
      sum += r.estrellas;
    }
    return sum / _reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección del proveedor
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                    "${Env.dominio}/uploads/usuarios/${widget.serviceProvider['avatarUrl'] ?? ''}",
                  ),
                  backgroundColor: Colors.grey.shade200,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.serviceProvider['name'] ?? 'Proveedor',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(5, (i) {
                          final avg = _averageRating();
                          return Icon(
                            i < avg ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.serviceProvider['direccion'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),

            // Título de reseñas
            const Text(
              'Reseñas y comentarios',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Lista de reseñas
            if (_reviews.isEmpty)
              const Text('Aún no hay reseñas. ¡Sé el primero en opinar!')
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _reviews.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final r = _reviews[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: const Icon(Icons.person, color: Colors.black87),
                    ),
                    title: Row(
                      children: [
                        Expanded(child: Text(r.nombreCalificador)),
                        Row(
                          children: List.generate(5, (i) {
                            return Icon(
                              i < r.estrellas ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 16,
                            );
                          }),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.comentario),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('yyyy-MM-dd HH:mm').format(r.fechaCreacion),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 16),
            const Divider(),

            // Formulario para dejar reseña
            const Text(
              'Deja tu reseña',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                const Text('Tu calificación: '),
                Row(
                  children: List.generate(5, (i) {
                    final filled = i < _rating;
                    return IconButton(
                      icon: Icon(
                        filled ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: () =>
                          setState(() => _rating = (i + 1).toDouble()),
                    );
                  }),
                ),
              ],
            ),

            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: 'Escribe tu comentario...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed:cargando?null:() => _submitReview(widget.usuario, widget.serviceId),
                icon: const Icon(Icons.send),
                label: Text(cargando?'Procesando...':'Enviar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
