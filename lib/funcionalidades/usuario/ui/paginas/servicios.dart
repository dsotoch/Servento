import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

import 'package:prestaservicios/funcionalidades/principal/ui/controlador/controladorPrincipal.dart';
import 'package:prestaservicios/funcionalidades/promociones_mensajes/datos/modelos/pagoAsignado.dart';
import 'package:prestaservicios/funcionalidades/promociones_mensajes/datos/repositorios/repositorioPromociones.dart';
import 'package:prestaservicios/funcionalidades/promociones_mensajes/ui/controladores/controladorPromocion.dart';
import 'package:prestaservicios/funcionalidades/servicios/datos/modelos/servicioModel.dart';
import 'package:prestaservicios/compartido/funciones.dart';
import 'package:prestaservicios/funcionalidades/servicios/datos/repositorios/repositorioServicio.dart';
import 'package:prestaservicios/funcionalidades/servicios/dominipo/casosUso/casoUsoServicio.dart';
import 'package:prestaservicios/funcionalidades/usuario/ui/controladores/controladorServicio.dart';
import 'package:prestaservicios/funcionalidades/usuario/ui/widgets/mapaUbicacionScreen.dart';
import 'package:prestaservicios/nucleo/env.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MisServiciosScreen extends StatefulWidget {
  final String usuarioId;
  List<ServicioModel> servicios;
  MisServiciosScreen({
    super.key,
    required this.usuarioId,
    required this.servicios,
  });

  @override
  State<MisServiciosScreen> createState() => _MisServiciosScreenState();
}

class _MisServiciosScreenState extends State<MisServiciosScreen> {
  late final ControladorServicio controladorServicio;
  late final ControladorPrincipal controladorPrincipal;
  bool cargando = false;
  final ImagePicker _picker = ImagePicker();
  late List<String> _categories = [];
  Map<String, List<String>> _subcategories = {}; // subcategorías por categoría
  String? selectedSubcategory;
  List<String> subcategoriesForSelected = [];
  late ControladorPromocion controladorPromocion;
  PagoAsignado? promocionActual;
  TextEditingController codigoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final CasoUsoServicio casoUsoServicio = RepositorioServicio();
    controladorServicio = ControladorServicio(casoUsoServicio: casoUsoServicio);
    controladorPrincipal = ControladorPrincipal();
    final casopromo = RepositorioPromociones();
    controladorPromocion = ControladorPromocion(casopromo: casopromo);
    cargarcategorias();
    cargarServicios();
    _obtenerPromocion();
  }

  void cargarServicios() async {
    final data = await controladorServicio.listarServicios(widget.usuarioId);
    if (data['success'] == true) {
      final servicios = data['mensaje'] as List;
      setState(() {
        widget.servicios = List<ServicioModel>.from(
          servicios.map((e) => ServicioModel.fromJson(e)),
        ).toList();
      });
    }
  }

  void cargarcategorias() async {
    final data = await controladorPrincipal.getCategorias();
    final Map<String, List<String>> categoriasMap = {};

    if (data['success'] == true) {
      final List<dynamic> categoriasList = data['mensaje'];

      for (var item in categoriasList) {
        final catNombre = item['categoria_nombre'] ?? "Sin categoría";
        final subNombre = item['subcategoria_nombre'] ?? "Sin subcategoría";

        // Guardar subcategorías
        if (categoriasMap.containsKey(catNombre)) {
          categoriasMap[catNombre]!.add(subNombre);
        } else {
          categoriasMap[catNombre] = [subNombre];
        }
      }
    }
    setState(() {
      _categories =
          ["Seleccione..."] +
          categoriasMap.keys
              .toList(); // lista de categorías con opción por defecto
      _subcategories = categoriasMap; // mapa categoría → subcategorías
      selectedSubcategory = null; // limpiar selección de subcategoría
    });
  }

  Future<bool> _guardarServicio(
    ServicioModel modelo,
    BuildContext context,
  ) async {
    bool res = false;
    try {
      setState(() => cargando = true);

      if (modelo.precio <= 0) {
        Funciones().mostrarMensaje("error", "Ingrese un precio válido");
        return res;
      }
      if (modelo.titulo.isEmpty ||
          modelo.descripcion.isEmpty ||
          modelo.ubicacion.isEmpty ||
          modelo.lat.isEmpty ||
          modelo.long.isEmpty) {
        Funciones().mostrarMensaje("error", "Ingrese todos los datos");
        if (kDebugMode) {
          print(modelo.toJson());
        }
        return res;
      }

      Map<String, dynamic> rs;
      if (modelo.id != 0) {
        rs = await controladorServicio.modificarServicio(modelo);
      } else {
        rs = await controladorServicio.guardarServicio(modelo);
      }
      if (kDebugMode) {
        print(rs["mensaje"]);
      }
      if (rs["success"] == true) {
        Funciones().mostrarMensaje("ok", rs["mensaje"]);
        res = true;
      } else {
        Funciones().mostrarMensaje("error", rs["mensaje"]);
      }
    } catch (e) {
      Funciones().mostrarMensaje("error", "⚠️ Error inesperado: $e");
    } finally {
      setState(() => cargando = false);
      return res;
    }
  }

  Future<void> _obtenerPromocion() async {
    try {
      final rs = await controladorPromocion.getPagos(
        "",
        widget.usuarioId.toString(),
      );
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

  Future<List<String>> _convertirFotosABase64(List<XFile> fotos) async {
    List<String> imagenesBase64 = [];
    for (var foto in fotos) {
      final bytes = await File(foto.path).readAsBytes();
      imagenesBase64.add(base64Encode(bytes));
    }
    return imagenesBase64;
  }

  void _mostrarModal({ServicioModel? servicio}) async {
    final State padreState = this;
    final isEdit = servicio != null;
    final _tituloController = TextEditingController(
      text: isEdit ? servicio.titulo : '',
    );
    final _descripcionController = TextEditingController(
      text: isEdit ? servicio.descripcion : '',
    );
    final _precioController = TextEditingController(
      text: isEdit ? servicio.precio.toString() : '',
    );
    final _ubicacionController = TextEditingController(
      text: isEdit ? servicio.ubicacion : '',
    );
    bool procesando = false;
    var _latitud = TextEditingController(text: isEdit ? servicio.lat : '');
    var _longitud = TextEditingController(text: isEdit ? servicio.long : '');

    List<XFile> fotos = [];
    List<Uint8List> fotosThumb = [];
    String selectedCategory = isEdit ? servicio!.categoria : _categories[0];
    selectedSubcategory = isEdit ? servicio!.sub : '';
    subcategoriesForSelected = (isEdit
        ? _subcategories[servicio!.categoria]
        : [])!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isEdit ? 'Editar Servicio' : 'Nuevo Servicio',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _tituloController,
                      decoration: const InputDecoration(
                        labelText: "Título",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descripcionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "Descripción",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _precioController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Precio",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _ubicacionController,
                      readOnly: true,
                      onTap: () async {
                        final direccion = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MapaUbicacionScreen(),
                          ),
                        );
                        if (direccion != null) {
                          _ubicacionController.text = direccion["direccion"];
                          _latitud.text = direccion["lat"].toString();
                          _longitud.text = direccion["lng"].toString();
                        }
                      },
                      decoration: InputDecoration(
                        labelText: "Ubicación",
                        border: const OutlineInputBorder(),
                        suffixIcon: const Icon(
                          Icons.my_location,
                          color: Colors.green,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      items: _categories
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                          subcategoriesForSelected =
                              _subcategories[value] ?? [];
                          selectedSubcategory =
                              null; // limpiar selección anterior
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    SizedBox(height: 10),

                    DropdownButtonFormField<String>(
                      value: selectedSubcategory,
                      items: subcategoriesForSelected
                          .map(
                            (sub) =>
                                DropdownMenuItem(value: sub, child: Text(sub)),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedSubcategory = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Sub Categoría',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text("Fotos:"),
                        const SizedBox(width: 12),
                        ...List.generate(3, (i) {
                          return GestureDetector(
                            onTap: () async {
                              if (fotos.length <= i) {
                                ImageSource? source =
                                    await showDialog<ImageSource>(
                                      context: context,
                                      builder: (context) => SimpleDialog(
                                        title: const Text(
                                          'Selecciona fuente de la imagen',
                                        ),
                                        children: [
                                          SimpleDialogOption(
                                            onPressed: () => Navigator.pop(
                                              context,
                                              ImageSource.camera,
                                            ),
                                            child: const Text('Cámara'),
                                          ),
                                          SimpleDialogOption(
                                            onPressed: () => Navigator.pop(
                                              context,
                                              ImageSource.gallery,
                                            ),
                                            child: const Text('Galería'),
                                          ),
                                        ],
                                      ),
                                    );
                                if (source == null) return;

                                final XFile? picked = await _picker.pickImage(
                                  source: source,
                                  maxWidth: 600,
                                  maxHeight: 600,
                                  imageQuality: 70,
                                );

                                if (picked != null) {
                                  final Uint8List? thumbBytes =
                                      await FlutterImageCompress.compressWithFile(
                                        picked.path,
                                        minWidth: 100,
                                        minHeight: 100,
                                        quality: 70,
                                      );
                                  if (thumbBytes != null) {
                                    setState(() {
                                      if (fotos.length <= i) {
                                        fotos.add(picked);
                                        fotosThumb.add(thumbBytes);
                                      } else {
                                        fotos[i] = picked;
                                        fotosThumb[i] = thumbBytes;
                                      }
                                    });
                                  }
                                }
                              } else {
                                setState(() {
                                  fotos.removeAt(i);
                                  fotosThumb.removeAt(i);
                                });
                              }
                            },
                            child: Container(
                              width: 60,
                              height: 60,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.shade200,
                              ),
                              child: fotosThumb.length > i
                                  ? Image.memory(
                                      fotosThumb[i],
                                      fit: BoxFit.cover,
                                      gaplessPlayback: true,
                                    )
                                  : const Icon(
                                      Icons.add_a_photo,
                                      color: Colors.grey,
                                    ),
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: codigoController,
                      decoration: InputDecoration(
                        labelText: "Código para publicar sin costo.",
                        hintText: "Ej: SERVI20",
                        prefixIcon: Icon(Icons.discount_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      style: TextStyle(fontSize: 16, letterSpacing: 1),
                      validator: (valor) {
                        if (valor == null || valor.trim().isEmpty) {
                          return "Ingresa un código válido";
                        }
                        if (valor.trim().length < 4) {
                          return "El código es demasiado corto";
                        }
                        return null;
                      },
                    ),
                    ElevatedButton(
                      onPressed: procesando
                          ? null
                          : () async {
                             if (!await Funciones().mostrarConfirmacion(
                                context: context,
                                titulo: 'Confirmación',
                                mensaje:
                                    '¿Estas Seguro de realizar esta Operación?',
                              ))
                                {
                                  return;
                                }
                              if (codigoController.text != "") {
                                final rs = await controladorPromocion
                                    .validarCodigo(codigoController.text,widget.usuarioId);

                                if (rs["success"] == true) {
                                  Funciones().mostrarMensaje(
                                    "ok",
                                    rs["mensaje"],
                                  );
                                } else {
                                  Funciones().mostrarMensaje(
                                    "error",
                                    rs["mensaje"],
                                  );
                                  return;
                                }
                              } else {
                                if (promocionActual == null ||
                                    promocionActual?.estado == "pendiente") {
                                  Funciones().mostrarMensaje(
                                    "error",
                                    "No tienes una promoción activa o esta pendiente de pago. Debes adquirir un plan para continuar utilizando la aplicación.",
                                  );
                                  return;
                                }
                              }

                             
                              setState(() {
                                procesando = true;
                              });
                              List<String> dataImagenes =
                                  await _convertirFotosABase64(fotos);
                              final modelo = ServicioModel(
                                id: isEdit ? servicio!.id : 0,
                                titulo: _tituloController.text,
                                descripcion: _descripcionController.text,
                                precio:
                                    double.tryParse(_precioController.text) ??
                                    0,
                                ubicacion: _ubicacionController.text,
                                categoria: selectedCategory,
                                sub: selectedSubcategory,
                                estado: "pendiente",
                                usuarioId: int.parse(widget.usuarioId),
                                imagen1: dataImagenes.isNotEmpty
                                    ? dataImagenes[0]
                                    : null,

                                imagen2: dataImagenes.length > 1
                                    ? dataImagenes[1]
                                    : null,
                                imagen3: dataImagenes.length > 2
                                    ? dataImagenes[2]
                                    : null,
                                lat: _latitud.text,
                                long: _longitud.text,
                              );

                              if (await _guardarServicio(modelo, context)) {
                                final data = await controladorServicio
                                    .listarServicios(
                                      modelo.usuarioId.toString(),
                                    );
                                setState(() {
                                  procesando = false;
                                });
                                print(data);
                                if (data["success"] == true &&
                                    data["mensaje"] is List) {
                                  padreState.setState(() {
                                    widget.servicios = (data["mensaje"] as List)
                                        .map(
                                          (e) => ServicioModel.fromJson(
                                            Map<String, dynamic>.from(e),
                                          ),
                                        )
                                        .toList();
                                  });
                                   Navigator.pop(context);
                                }
                              }else{
                                 setState(() {
                                procesando = false;
                              });
                              }
                             
                            },
                      child: Text(
                        procesando
                            ? "Procesando..."
                            : (isEdit ? "Guardar cambios" : "Agregar servicio"),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildServicioCard(ServicioModel servicio) {
    List<String?> imagenes = [
      servicio.imagen1,
      servicio.imagen2,
      servicio.imagen3,
    ];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📝 CONTENIDO PRINCIPAL
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    servicio.titulo.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    servicio.descripcion,
                    maxLines: null, // Permite texto largo
                    overflow: TextOverflow.visible,
                  ),
                  const SizedBox(height: 4),
                  Text("Categoría: ${servicio.categoria}"),
                  Text("Ubicación: ${servicio.ubicacion}"),

                  if (imagenes.any((e) => e != null && e.isNotEmpty))
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: SizedBox(
                        height: 60,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: imagenes
                              .where((f) => f != null && f.isNotEmpty)
                              .map(
                                (f) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: CachedNetworkImage(
                                      imageUrl: "${Env.dominio}/$f",
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.broken_image),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 🎛️ BOTONES A LA DERECHA
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _mostrarModal(servicio: servicio),
                ),
                IconButton(
                  icon: servicio.estado == "pendiente"
                      ? Icon(Icons.pending_actions)
                      : Icon(
                          size: 35,
                          servicio.estado == "activo"
                              ? Icons.toggle_off
                              : Icons.toggle_on,
                          color: servicio.estado == "activo"
                              ? Colors.green
                              : Colors.red,
                        ),
                  onPressed: servicio.estado == "pendiente"
                      ? null
                      : () async {
                          if (!await Funciones().mostrarConfirmacion(
                            context: context,
                            titulo: 'Confirmación',
                            mensaje:
                                '¿Estas Seguro de realizar esta Operación?',
                          )) {
                            return;
                          }
                          final rs = await controladorServicio.editarRegistro(
                            servicio.id.toString(),
                            "estado",
                          );
                          if (rs["success"] == true) {
                            Funciones().mostrarMensaje("ok", rs["mensaje"]);

                            final data = await controladorServicio
                                .listarServicios(widget.usuarioId.toString());
                            if (data["success"] == true &&
                                data["mensaje"] is List) {
                              setState(() {
                                widget.servicios = (data["mensaje"] as List)
                                    .map(
                                      (e) => ServicioModel.fromJson(
                                        Map<String, dynamic>.from(e),
                                      ),
                                    )
                                    .toList();
                              });
                            }
                          } else {
                            Funciones().mostrarMensaje("error", rs["mensaje"]);
                          }
                        },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    if (!await Funciones().mostrarConfirmacion(
                      context: context,
                      titulo: 'Confirmación',
                      mensaje: '¿Estas Seguro de realizar esta Operación?',
                    )) {
                      return;
                    }
                    final rs = await controladorServicio.eliminarServicio(
                      servicio.id.toString(),
                    );
                    if (rs["success"] == true) {
                      Funciones().mostrarMensaje("ok", rs["mensaje"]);

                      final data = await controladorServicio.listarServicios(
                        widget.usuarioId.toString(),
                      );
                      if (data["success"] == true && data["mensaje"] is List) {
                        setState(() {
                          widget.servicios = (data["mensaje"] as List)
                              .map(
                                (e) => ServicioModel.fromJson(
                                  Map<String, dynamic>.from(e),
                                ),
                              )
                              .toList();
                        });
                      }
                    } else {
                      Funciones().mostrarMensaje("error", rs["mensaje"]);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activos = widget.servicios
        .where((s) => s.estado == "activo")
        .toList();
    final inactivos = widget.servicios
        .where((s) => s.estado == "inactivo")
        .toList();
    final pendientes = widget.servicios
        .where((s) => s.estado == "pendiente")
        .toList();
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Mis Servicios')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(
            bottom: 80,
            left: 12,
            right: 12,
            top: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Servicios Activos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (activos.isEmpty)
                const Text('No tienes servicios activos.')
              else
                ...activos.map(_buildServicioCard),
              const SizedBox(height: 20),
              const Text(
                'Servicios Pendientes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (pendientes.isEmpty)
                const Text('No tienes servicios pendientes.')
              else
                ...pendientes.map(_buildServicioCard),
              const SizedBox(height: 20),
              const Text(
                'Servicios Inactivos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (inactivos.isEmpty)
                const Text('No tienes servicios inactivos.')
              else
                ...inactivos.map(_buildServicioCard),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _mostrarModal(),
          label: const Text('Publicar servicio'),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }
}
