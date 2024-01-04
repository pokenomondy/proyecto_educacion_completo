import 'dart:async';
import 'package:dashboard_admin_flutter/Config/Config.dart';
import 'package:dashboard_admin_flutter/Config/elements.dart';
import 'package:dashboard_admin_flutter/Objetos/AgendadoServicio.dart';
import 'package:dashboard_admin_flutter/Objetos/Clientes.dart';
import 'package:dashboard_admin_flutter/Objetos/Objetos%20Auxiliares/Carreras.dart';
import 'package:dashboard_admin_flutter/Objetos/Objetos%20Auxiliares/Materias.dart';
import 'package:dashboard_admin_flutter/Objetos/Objetos%20Auxiliares/Universidad.dart';
import 'package:dashboard_admin_flutter/Pages/Estadistica.dart';
import 'package:dashboard_admin_flutter/Pages/Tutores.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/StreamBuilders.dart';
import 'package:dashboard_admin_flutter/Utils/Utiles/FuncionesUtiles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Config/theme.dart';
import 'Objetos/Configuracion/Configuracion_Configuracion.dart';
import 'Objetos/Solicitud.dart';
import 'Objetos/Tutores_objet.dart';
import 'Pages/CentroConfig.dart';
import 'Pages/ContableDash.dart';
import 'Pages/MainTutores/DetallesTutores.dart';
import 'Pages/Servicios/Detalle_Solicitud.dart';
import 'Pages/SolicitudesNew.dart';
import 'package:intl/intl.dart';
import 'Utils/Firebase/CollectionReferences.dart';

class Dashboard extends StatefulWidget {
  final bool showSolicitudesNew;
  final bool showTutoresDetalles;

  const Dashboard({Key? key,
    required this.showSolicitudesNew,
    required this.showTutoresDetalles,
  }) : super(key: key);

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  bool entraprimeravez = false;
  int _currentPage = 0;
  Config configuracionrol = Config();
  bool configloaded = false;
  bool configloadedStream = false;
  bool showDetallesSolicitud = false;
  String rol = "";
  CollectionReferencias referencias =  CollectionReferencias();
  User? currentUser;
  late StreamController<ConfiguracionPlugins> _streamController;
  late StreamController<List<ServicioAgendado>> _streamControllerServiciosAgendados;
  late StreamController<List<Solicitud>> _streamControllerSolicitudes;
  late StreamController<List<Tutores>> _streamControllerTutores;
  late StreamController<List<Carrera>> _streamControllerCarreras;
  late StreamController<List<Materia>> _streamControllerMaterias;
  late StreamController<List<Clientes>> _streamControllerClientes;
  late StreamController<List<Universidad>> _streamControllerUniversidades;
  final ThemeApp themeApp = ThemeApp();

  @override
  void initState() {
    super.initState();
    cargarprimeravez();
    _streamController = StreamController<ConfiguracionPlugins>();
    _streamControllerServiciosAgendados = StreamController<List<ServicioAgendado>>();
    _streamControllerSolicitudes = StreamController<List<Solicitud>>();
    _streamControllerTutores = StreamController<List<Tutores>>();
    _streamControllerCarreras = StreamController<List<Carrera>>();
    _streamControllerMaterias = StreamController<List<Materia>>();
    _streamControllerClientes = StreamController<List<Clientes>>();
    _streamControllerUniversidades = StreamController<List<Universidad>>();
    _initStream();
  }

  _initStream() async {
    //Configuración stream
    Stream<ConfiguracionPlugins> stream = await stream_builders().getstreamConfiguracion(context);
    _streamController.addStream(stream);
    //Contabilidad stream
    Stream<List<ServicioAgendado>> streamservicios = await stream_builders().getServiciosAgendados(context);
    _streamControllerServiciosAgendados.addStream(streamservicios);
    //solicitudes stream
    Stream<List<Solicitud>> streamsolicitud = await stream_builders().getTodasLasSolicitudes(context);
    _streamControllerSolicitudes.addStream(streamsolicitud);
    //Tutores stream
    Stream<List<Tutores>> streamTutores = await stream_builders().getTodosLosTutores(context);
    _streamControllerTutores.addStream(streamTutores);
    //Carreras stream
    Stream<List<Carrera>> streamCarreras = await stream_builders().getTodasLasCarreras(context);
    _streamControllerCarreras.addStream(streamCarreras);
    //Materias Stream
    Stream<List<Materia>> stream_materia = await stream_builders().getTodasLasMaterias(context);
    _streamControllerMaterias.addStream(stream_materia);
    //Clientes Stream
    Stream<List<Clientes>> stream_clientes = await stream_builders().getTodosLosClientes(context);
    _streamControllerClientes.addStream(stream_clientes);
    //Universidad Stream
    Stream<List<Universidad>> stream_universidad = await stream_builders().getTodasLasUniversidades(context);
    _streamControllerUniversidades.addStream(stream_universidad);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void cargarprimeravez() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    entraprimeravez = prefs.getBool('datos_descargados_tablaclientes') ?? false;
    currentUser = referencias.authdireccion!.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConfiguracionPlugins>(
      stream: _streamController.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        else {
          final configuracion = snapshot.data;

          List<NavigationPaneItem> getItems(){
            if(widget.showTutoresDetalles){
              return <NavigationPaneItem>[
                PaneItem(icon: const Icon(FluentIcons.home),
                    title: configuracionrol.panelnavegacion("Tutores",_currentPage==1),
                    body: widget.showTutoresDetalles ? /*DetallesTutores()*/ const SolicitudesNew(): const TutoresVista(),
                    selectedTileColor:ButtonState.all(Utiles().hexToColor(configuracion!.PrimaryColor))),
              ];
            }else{
              return <NavigationPaneItem>[
                PaneItem(
                  icon: const Icon(FluentIcons.home),
                  title:  configuracionrol.panelnavegacion("Solicitudes",_currentPage == 0),
                  body: widget.showSolicitudesNew ?  /*DetallesServicio()*/ const SolicitudesNew(): const SolicitudesNew(),
                  selectedTileColor:ButtonState.all(Utiles().hexToColor(configuracion!.PrimaryColor)),
                  key: const ValueKey('/home'),
                ),
                PaneItem(icon: const Icon(Icons.person_sharp),
                    title: configuracionrol.panelnavegacion("Tutores",_currentPage==1),
                    body: widget.showTutoresDetalles ?  /*DetallesTutores()*/ const SolicitudesNew(): const TutoresVista(),
                    selectedTileColor:ButtonState.all(Utiles().hexToColor(configuracion.PrimaryColor)) ),
                PaneItem(icon: const Icon(Icons.insert_chart_outlined_rounded),
                    title: configuracionrol.panelnavegacion("Estadisticas",_currentPage==2), body: Estadistica(),selectedTileColor:ButtonState.all(Utiles().hexToColor(configuracion!.PrimaryColor)) ),
                PaneItem(icon: const Icon(Icons.attach_money_rounded),
                    title: configuracionrol.panelnavegacion("Contable",_currentPage==3), body: const ContableDashboard(),selectedTileColor:ButtonState.all(Utiles().hexToColor(configuracion!.PrimaryColor)) ),
                PaneItem(icon: const Icon(Icons.settings),
                    title: configuracionrol.panelnavegacion("Centro Datos",_currentPage==4), body: const CentroConfiguracionDash(),selectedTileColor:ButtonState.all(Utiles().hexToColor(configuracion!.PrimaryColor)) ),
              ];
            }
          }

          if(currentUser == null || configuracionrol.rol == "TUTOR"){
            return const Text('ERROR 404');
          }
          else if(configuracion!.basicoFecha.isBefore(DateTime.now())){
            return const Text('Vencio la licencia');
          }
          else{
            return NavigationView(
              appBar: NavigationAppBar(
                title: Container(
                  margin:  const EdgeInsets.only(left: 20),
                  child: Row(
                    children: [
                      if(!widget.showSolicitudesNew)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20.0, left: 5.0,),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(configuracion.nombre_empresa, style: themeApp.styleText(35, true, themeApp.grayColor),),
                              StreamBuilder<List<ServicioAgendado>>(
                                stream: _streamControllerServiciosAgendados.stream,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    // No mostrar nada, ya que el stream está vacío
                                    return const Text('conta true'); // O cualquier otro widget que no muestre nada
                                  }
                                },
                              ),
                              const Text('Config true'),
                              StreamBuilder<List<Materia>>(
                                stream: _streamControllerMaterias.stream,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    // No mostrar nada, ya que el stream está vacío
                                    return const Text('Carrera true'); // O cualquier otro widget que no muestre nada
                                  }
                                },
                              ),
                              StreamBuilder<List<Clientes>>(
                                stream: _streamControllerClientes.stream,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    // No mostrar nada, ya que el stream está vacío
                                    return const Text('Clientes true'); // O cualquier otro widget que no muestre nada
                                  }
                                },
                              ),
                              StreamBuilder<List<Solicitud>>(
                                stream: _streamControllerSolicitudes.stream,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    // No mostrar nada, ya que el stream está vacío
                                    return const Text('Solicitudes true'); // O cualquier otro widget que no muestre nada
                                  }
                                },
                              ),
                              StreamBuilder<List<Tutores>>(
                                stream: _streamControllerTutores.stream,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    // No mostrar nada, ya que el stream está vacío
                                    return const Text('Tutores true'); // O cualquier otro widget que no muestre nada
                                  }
                                },
                              ),
                              StreamBuilder<List<Carrera>>(
                                stream: _streamControllerCarreras.stream,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    // No mostrar nada, ya que el stream está vacío
                                    return const Text('Carrera true'); // O cualquier otro widget que no muestre nada
                                  }
                                },
                              ),
                              StreamBuilder<List<Universidad>>(
                                stream: _streamControllerUniversidades.stream,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    // No mostrar nada, ya que el stream está vacío
                                    return const Text('Universidades true'); // O cualquier otro widget que no muestre nada
                                  }
                                },
                              ),
                              Row(
                                children: [
                                  CircularButton(
                                      radio: 35,
                                      iconData: Icons.clear,
                                      function: (){

                                      }
                                  ),
                                  CircularButton(
                                      radio: 35,
                                      iconData: Icons.clear,
                                      function: (){

                                      }
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              pane: NavigationPane(
                size: const NavigationPaneSize(
                  openMaxWidth: 50.00,
                  openMinWidth: 50.00,
                ),
                items: getItems(),
                selected: _currentPage,
                onChanged: (index) => setState(() {
                  _currentPage = index;
                }),
              ),
            );
          }
        }
      },
    );
  }

  bool obtenerBool(DateTime fecha) {
    DateTime fechaActual = DateTime.now();
    return fecha.isAfter(fechaActual);
  }

}