import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:location/location.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/dominio/entidades/usuario.dart';
import 'package:prestaservicios/funcionalidades/autenticacion/ui/paginas/chats.dart';
import 'package:prestaservicios/funcionalidades/principal/ui/paginas/imagenPantallaCompleta.dart';
import 'package:prestaservicios/funcionalidades/principal/ui/paginas/resenas.dart';
import 'package:prestaservicios/funcionalidades/promociones_mensajes/datos/modelos/pagoAsignado.dart';
import 'package:prestaservicios/funcionalidades/promociones_mensajes/datos/repositorios/repositorioPromociones.dart';
import 'package:prestaservicios/funcionalidades/promociones_mensajes/ui/controladores/controladorPromocion.dart';

import 'package:prestaservicios/funcionalidades/servicios/datos/modelos/modeloComentarios.dart';
import 'package:prestaservicios/funcionalidades/servicios/datos/modelos/modeloServicioVista.dart';
import 'package:prestaservicios/funcionalidades/servicios/datos/repositorios/repositorioServicio.dart';
import 'package:prestaservicios/funcionalidades/servicios/dominipo/casosUso/casoUsoServicio.dart';
import 'package:prestaservicios/funcionalidades/usuario/ui/controladores/controladorServicio.dart';
import 'package:prestaservicios/funcionalidades/usuario/ui/widgets/filtroDistancia.dart';
import 'package:prestaservicios/nucleo/env.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controlador/controladorPrincipal.dart';

class MarketplaceScreen extends StatefulWidget {
  late Usuario usuario;
  List<Modeloserviciovista>? listaservicios;
  LocationData locationData;
  final String cat;

  MarketplaceScreen({
    super.key,
    required this.usuario,
    this.listaservicios,
    required this.locationData,
    required this.cat,
  });

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  List<Modeloserviciovista> _servicios = [];
  late final ControladorServicio controladorServicio;
  late final ControladorPromocion controladorPromocion;
  final ScrollController _scrollController = ScrollController();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  int _page = 0;
  final int _limit = 100;
  bool _isLoading = false;
  bool _hasMore = true;
  late List<Map<String, dynamic>> misfavoritos;
  int mensajesNuevos = 0;
  int cantidadinicial = 0;
  List<String> _categories = [];
  String _selectedCategory = '';
  PagoAsignado? promocionActual;
  Map<String, List<String>> categorias = {};
  late ControladorPrincipal controladorPrincipal;
  String filtro = "";
  String _selectedSubcategory = '';
  List<String> get _subcategories {
    return categorias[_selectedCategory] ?? [];
  }

  @override
  void initState() {
    super.initState();
    final CasoUsoServicio casoUsoServicio = RepositorioServicio();
    controladorServicio = ControladorServicio(casoUsoServicio: casoUsoServicio);
    final casoUsoPromociones = RepositorioPromociones();
    controladorPromocion = ControladorPromocion(casopromo: casoUsoPromociones);
    widget.listaservicios = [];
    _loadMore();
    _misFavoritos();
    _verificarMensajesNuevos();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
    initNotifications();
    _categories.add(widget.cat.toLowerCase());
    _selectedCategory = widget.cat.toLowerCase();
    controladorPrincipal = ControladorPrincipal();
    cargarcategorias();
  }

  Future<void> cargarcategorias() async {
    final data = await controladorPrincipal.getCategorias();
    final Map<String, List<String>> categoriasMap = {};

    if (data['success'] == true) {
      final List<dynamic> categoriasList = data['mensaje'];

      for (var item in categoriasList) {
        final catNombre = item['categoria_nombre'] ?? "todos";
        final subNombre = item['subcategoria_nombre'] ?? "todos";

        if (categoriasMap.containsKey(catNombre)) {
          categoriasMap[catNombre]!.add(subNombre);
        } else {
          categoriasMap[catNombre] = [subNombre];
        }
      }
      categoriasMap.forEach((key, value) {
        if (!value.contains("todos")) {
          value.insert(0, "todos");
        }
      });
    }

    setState(() {
      categorias = categoriasMap;
      _categories = categorias.keys.toList();

      if (!_categories.contains("todos")) {
        _categories.insert(0, "todos");
      }

      _selectedCategory = "todos";
      _selectedSubcategory = "todos"; // inicializamos subcategoría también
    });
  }

  Future<void> initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _misFavoritos() async {
    final data = await controladorServicio.listarFavoritos(
      widget.usuario.id.toString(),
    );
    final lista = data["mensaje"] as List;
    final ids = lista.map((e) => e['id'].toString()).toSet();
    setState(() {
      _favorites.addAll(ids);
    });
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    final response = await controladorServicio.listarServiciosGeneral(
      (_page * _limit).toString(),
      _limit.toString(),
      widget.locationData.latitude.toString(),
      widget.locationData.longitude.toString(),
      _radioKm.toString(),
    );
    final data = response["mensaje"] as List;
    final nuevos = data.map((e) => Modeloserviciovista.fromJson(e)).toList();
    setState(() {
      if (nuevos.length < _limit) {
        _hasMore = false;
      }
      _servicios.addAll(nuevos);
      _page++;
      _isLoading = false;
    });
  }

  String _query = '';
  String _sortBy = 'Relevancia';

  final Set<String> _favorites = {};
  double _radioKm = 100;

  List<Modeloserviciovista> get _filteredServices {
    final q = _query.toLowerCase().trim();
    final category = _selectedCategory.toLowerCase().trim();
    final subcategory = _selectedSubcategory.toLowerCase().trim();

    final baseList = _servicios;

   

    final filtered = baseList.where((s) {
      final titulo = s.titulo.toLowerCase();
      final descripcion = s.descripcion.toLowerCase();
      final cat = s.categoria.toLowerCase().trim();
      final sub = s.subcategoria.toLowerCase().trim();

      final matchesQuery =
          q.isEmpty ||
          titulo.contains(q) ||
          descripcion.contains(q) ||
          cat.contains(q) ||
          sub.contains(q);

      final matchesCategory = category == 'todos' || cat == category;
      final matchesSubcategory = subcategory == 'todos' || sub == subcategory;

      final result = matchesQuery && matchesCategory && matchesSubcategory;

    

      return result;
    }).toList();


    filtered.sort((a, b) {
      final aFav = _favorites.contains(a.id.toString()) ? 1 : 0;
      final bFav = _favorites.contains(b.id.toString()) ? 1 : 0;

      if (aFav != bFav) return bFav - aFav;

      switch (_sortBy) {
        case 'Precio: menor':
          return a.precio.compareTo(b.precio);
        case 'Precio: mayor':
          return b.precio.compareTo(a.precio);
        case 'Mejor valorados':
          return b.promedioEstrellas.compareTo(a.promedioEstrellas);
        default:
          return 0;
      }
    });

    return filtered;
  }

  void _toggleFavorite(String id) async {
    final isCurrentlyFav = _favorites.contains(
      id,
    ); // estado actual antes de cambiar
    setState(() {
      if (isCurrentlyFav) {
        _favorites.remove(id);
      } else {
        _favorites.add(id);
      }
    });

    if (isCurrentlyFav) {
      // estaba en favoritos, ahora lo eliminamos del backend
      await controladorServicio.eliminarFavoritos(
        widget.usuario.id.toString(),
        id,
      );
    } else {
      // no estaba, ahora lo agregamos
      await controladorServicio.guardarFavoritos(
        widget.usuario.id.toString(),
        id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<String>> categoriasFiltradas = {};

    categorias.forEach((key, value) {
      final subFiltradas = value
          .where((sub) => sub.toLowerCase().contains(filtro.toLowerCase()))
          .toList();
      if (subFiltradas.isNotEmpty) {
        categoriasFiltradas[key] = subFiltradas;
      }
    });

    final services = _filteredServices;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Material(
                  elevation: 0,
                  borderRadius: BorderRadius.circular(8),
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText:
                          'Buscar servicios, ej.: plomero, clases, diseño...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  final res = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FiltroDistanciaScreen(
                        radio: _radioKm,
                        locationData: widget.locationData,
                      ),
                    ),
                  );

                  if (res != null) {
                    setState(() {
                      _radioKm = res["radio"];

                      final lista = res["lista"];
                      if (lista != null && lista is List<Modeloserviciovista>) {
                        _servicios = lista; // ✅ AQUÍ EL CAMBIO IMPORTANTE
                      } else {
                        print("❌ lista inválida desde filtro: $lista");
                        _servicios = [];
                      }
                      _page = 1;
                      _hasMore = true;
                    });
                  }
                },
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.purple,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.gps_fixed,
                        color: Colors.white,
                        size: 20,
                      ),
                      Text(
                        "${_radioKm.round()} km",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = _categories;
              final selected = cat[index] == _selectedCategory;
              return ChoiceChip(
                label: Text(cat[index]),
                selected: selected,
                onSelected: (_) {
                  setState(() => _selectedCategory = cat[index]);
                  _loadMore();
                },
              );
            },
          ),
        ),
        SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: _subcategories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final sub = _subcategories[index];

              final selected = sub == _selectedSubcategory;

              return ChoiceChip(
                label: Text(sub),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    _selectedSubcategory = sub;
                  });
                  _loadMore();
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              Text(
                '${services.length} resultados',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              DropdownButton<String>(
                value: _sortBy,
                items: const [
                  DropdownMenuItem(
                    value: 'Relevancia',
                    child: Text('Relevancia'),
                  ),
                  DropdownMenuItem(
                    value: 'Mejor valorados',
                    child: Text('Mejor valorados'),
                  ),
                  DropdownMenuItem(
                    value: 'Precio: menor',
                    child: Text('Precio: menor'),
                  ),
                  DropdownMenuItem(
                    value: 'Precio: mayor',
                    child: Text('Precio: mayor'),
                  ),
                ],
                onChanged: (v) => setState(() => _sortBy = v ?? 'Relevancia'),
              ),
            ],
          ),
        ),

        Expanded(
          child: services.isEmpty
              ? Center(child: Text('No se encontraron servicios '))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxis = constraints.maxWidth > 900
                        ? 3
                        : (constraints.maxWidth > 600 ? 2 : 1);
                    return RefreshIndicator(
                      onRefresh: () async {
                        setState(() {
                          _page = 0;
                          _hasMore = true;
                          _isLoading = false;
                          _servicios = [];
                          _favorites.clear();
                        });

                        final response = await controladorServicio
                            .listarServiciosGeneral(
                              (_page * _limit).toString(),
                              _limit.toString(),
                              widget.locationData.latitude.toString(),
                              widget.locationData.longitude.toString(),
                              _radioKm.toString(),
                            );

                        final data = response["mensaje"] as List;
                        final nuevos = data
                            .map((e) => Modeloserviciovista.fromJson(e))
                            .toList();
                        await _misFavoritos();

                        setState(() {
                          _servicios = nuevos;
                          _page = 0;
                          _hasMore = nuevos.length >= _limit;
                        });
                      },
                      child: GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxis,
                          childAspectRatio: 3 / 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: services.length + (_hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == services.length) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.greenAccent,
                              ),
                            );
                          }
                          if (index < services.length) {
                            final s = services[index];

                            final isFav = _favorites.contains(s.id.toString());

                            return GestureDetector(
                              onTap: () async {
                                await _obtenerPromocion(s.usuarioId.toString());
                                _showServiceDetail(context, s);
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                                child: Column(
                                  children: [
                                    Expanded(
                                      flex: 6,
                                      child: ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(12),
                                            ),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            CachedNetworkImage(
                                              imageUrl:
                                                  "${Env.dominio}/${s.imagen1 ?? 'sin_imagen.png'}",
                                              placeholder: (context, url) =>
                                                  const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                          color: Colors.black,
                                                        ),
                                                  ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(
                                                        Icons.broken_image,
                                                      ),
                                              fit: BoxFit.cover,
                                            ),
                                            Positioned(
                                              right: 8,
                                              top: 8,
                                              child: InkWell(
                                                onTap: () => _toggleFavorite(
                                                  s.id.toString(),
                                                ),
                                                child: CircleAvatar(
                                                  backgroundColor:
                                                      Colors.white70,
                                                  child: Icon(
                                                    isFav
                                                        ? Icons.favorite
                                                        : Icons.favorite_border,
                                                    color: isFav
                                                        ? Colors.red
                                                        : Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    s.titulo.toUpperCase(),
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '💰 ${s.precio.toStringAsFixed(0)}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              s.descripcion,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const Spacer(),
                                            Text(
                                              '🗂️ ${s.categoria}',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const Spacer(),
                                            Text(
                                              '➤ ${s.subcategoria.toLowerCase()}',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const Spacer(),
                                            Row(
                                              children: [
                                                Icon(Icons.star, size: 14),
                                                const SizedBox(width: 4),
                                                Text(
                                                  s.promedioEstrellas
                                                      .toString(),
                                                ),
                                                const SizedBox(width: 8),
                                                const Icon(
                                                  Icons.location_on,
                                                  size: 14,
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    s.ubicacion,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _obtenerPromocion(String id_anunciante) async {
    try {
      final rs = await controladorPromocion.getPagos("", id_anunciante);
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

  void _verificarMensajesNuevos() async {
    await listarMensajesInicial();
    Timer.periodic(const Duration(seconds: 20), (timer) async {
      if (mounted) {
        await listarMensajes();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> listarMensajesInicial() async {
    try {
      final data = await controladorPromocion.getMensajesNuevos(
        widget.usuario.id.toString(),
        0,
      );
      if (data["success"] == true) {
        final datas = data["mensaje"];

        int cnt = 0;
        if (datas.isNotEmpty && datas[0]["total"] != null) {
          cnt = int.tryParse(datas[0]["total"].toString()) ?? 0;
        }
        if (mounted) {
          setState(() {
            cantidadinicial = cnt;
          });
        }
      }
    } catch (e) {
      debugPrint('Error al cargar mensajes: $e');
    }
  }

  Future<void> listarMensajes() async {
    try {
      final data = await controladorPromocion.getMensajesNuevos(
        widget.usuario.id.toString(),
        cantidadinicial,
      );
      if (data["success"] == true) {
        final datas = data["mensaje"];

        int diferencia = 0;
        if (datas.isNotEmpty && datas[0]["total"] != null) {
          diferencia = int.tryParse(datas[0]["total"].toString()) ?? 0;
        }
        if (mounted && diferencia >= cantidadinicial) {
          if (diferencia > cantidadinicial) {
            await flutterLocalNotificationsPlugin.show(
              0,
              '¡Nuevos mensajes!',
              'Tienes mensajes nuevos',
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  'mensajes_channel',
                  'Mensajes',
                  channelDescription: 'Notificaciones de nuevos mensajes',
                  importance: Importance.max,
                  priority: Priority.high,
                ),
              ),
            );
          }
          setState(() {
            mensajesNuevos = diferencia - cantidadinicial;
            cantidadinicial = diferencia;
          });
        }
      }
    } catch (e) {
      debugPrint('Error al cargar mensajes: $e');
    }
  }

  void _showServiceDetail(BuildContext context, Modeloserviciovista s) {
    final PageController _pageController = PageController();
    int _currentPage = 0;
    final List<String> imagenes = [
      if (s.imagen1 != null && s.imagen1.isNotEmpty)
        "${Env.dominio}/${s.imagen1}",
      if (s.imagen2 != null && s.imagen2.isNotEmpty)
        "${Env.dominio}/${s.imagen2}",
      if (s.imagen3 != null && s.imagen3.isNotEmpty)
        "${Env.dominio}/${s.imagen3}",
    ];
    showDialog(
      context: context,
      builder: (context) {
        return Dialog.fullscreen(
          child: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                backgroundColor: Colors.white,
                body: SafeArea(
                  child: Column(
                    children: [
                      // ==================================================
                      //     GALERÍA QUE OCUPA CASI TODA LA PANTALLA
                      // ==================================================
                      SizedBox(
                        height:
                            MediaQuery.of(context).size.height *
                            0.55, // 🔥 55% pantalla
                        width: double.infinity,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: imagenes.length,
                          onPageChanged: (index) {
                            setState(() => _currentPage = index);
                          },
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ImagenPantallaCompleta(
                                      imagenUrl: imagenes[index],
                                    ),
                                  ),
                                );
                              },
                              child: Image.network(
                                imagenes[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Indicadores
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(imagenes.length, (index) {
                          return InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ImagenPantallaCompleta(
                                    imagenUrl: imagenes[index],
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: _currentPage == index ? 14 : 10,
                                height: _currentPage == index ? 14 : 10,
                                decoration: BoxDecoration(
                                  color: _currentPage == index
                                      ? Colors.blueAccent
                                      : Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 10),

                      // ==================================================
                      //   SCROLL SOLO PARA LA INFORMACIÓN INFERIOR
                      // ==================================================
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),

                              // TITULO + PRECIO
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      s.titulo.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '💰 ${s.precio.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // ESTRELLAS + UBICACIÓN
                              Row(
                                children: [
                                  const Icon(Icons.star),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '${s.promedioEstrellas} • ${s.ubicacion}',
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                              // DESCRIPCIÓN
                              Text(
                                s.descripcion,
                                style: const TextStyle(fontSize: 16),
                              ),

                              const SizedBox(height: 20),

                              // ==================================================
                              //   BOTONES
                              // ==================================================
                              Row(
                                children: [
                                  if (promocionActual?.descripcionPlan ==
                                      "PLAN GOLDEN") ...[
                                    Expanded(
                                      child: IconButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStateProperty.all(
                                                Colors.green,
                                              ),
                                        ),
                                        onPressed: () async {
                                          final Uri url = Uri.parse(
                                            "https://wa.me/+52${s.wsp}",
                                          );
                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(
                                              url,
                                              mode: LaunchMode
                                                  .externalApplication,
                                            );
                                          }
                                        },
                                        icon: const FaIcon(
                                          FontAwesomeIcons.whatsapp,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    Expanded(
                                      child: IconButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStateProperty.all(
                                                Colors.blueAccent,
                                              ),
                                        ),
                                        onPressed: () async {
                                          final Uri url = Uri.parse(
                                            "tel:+52${s.contacto}",
                                          );
                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(
                                              url,
                                              mode: LaunchMode
                                                  .externalApplication,
                                            );
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.phone,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 10),
                                  ],

                                  // Chat
                                  Expanded(
                                    child: IconButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                              Colors.blueAccent,
                                            ),
                                      ),
                                      onPressed: () {
                                        final cliente = Cliente(
                                          nombre: s.nombrePublicador,
                                          fotoUrl: '',
                                          tipo: '',
                                          contacto: s.usuarioId.toString(),
                                        );

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ChatScreen(
                                              cliente: cliente,
                                              usuarioId: widget.usuario.id
                                                  .toString(),
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.send,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  OutlinedButton.icon(
                                    onPressed: () async {
                                      final data = await controladorServicio
                                          .listarComentarios(
                                            "comentarios",
                                            s.id.toString(),
                                          );

                                      if (data["success"] == true) {
                                        final comentarios =
                                            data["mensaje"] as List;

                                        final lista = comentarios
                                            .map(
                                              (e) =>
                                                  ComentarioModel.fromJson(e),
                                            )
                                            .toList();

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ServiceReviewScreen(
                                              serviceId: s.id.toString(),
                                              initialReviews: lista,
                                              serviceProvider: {
                                                'avatarUrl': s.foto,
                                                'name': s.nombrePublicador
                                                    .toUpperCase(),
                                                'direccion': s.direccion,
                                                'estrellas':
                                                    s.promedioEstrellas,
                                              },
                                              usuario: widget.usuario.id
                                                  .toString(),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.home_repair_service_rounded,
                                    ),
                                    label: const Text("Reseña"),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
