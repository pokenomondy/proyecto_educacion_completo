import 'dart:async';
import 'package:dashboard_admin_flutter/Config/Config.dart';
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
import 'Objetos/Configuracion/objeto_configuracion.dart';
import 'Objetos/Solicitud.dart';
import 'Objetos/Tutores_objet.dart';
import 'Pages/CentroConfig.dart';
import 'Pages/ContableDash.dart';
import 'Pages/MainTutores/DetallesTutores.dart';
import 'Pages/Servicios/Detalle_Solicitud.dart';
import 'Pages/SolicitudesNew.dart';
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
    if(!widget.showSolicitudesNew && !widget.showTutoresDetalles){
      _initStream();
    }
    _configuracionStream();
  }

  _initStream() async {

    //Contabilidad stream
    Stream<List<ServicioAgendado>> streamservicios = stream_builders().getServiciosAgendados(context,"ADMIN","");
    _streamControllerServiciosAgendados.addStream(streamservicios);
    //solicitudes stream
    Stream<List<Solicitud>> streamsolicitud = stream_builders().getTodasLasSolicitudes(context);
    _streamControllerSolicitudes.addStream(streamsolicitud);
    //Tutores stream
    Stream<List<Tutores>> streamTutores = stream_builders().getTodosLosTutores(context);
    _streamControllerTutores.addStream(streamTutores);
    //Carreras stream
    Stream<List<Carrera>> streamCarreras = stream_builders().getTodasLasCarreras(context);
    _streamControllerCarreras.addStream(streamCarreras);
    //Materias Stream
    Stream<List<Materia>> streamMateria = stream_builders().getTodasLasMaterias(context);
    _streamControllerMaterias.addStream(streamMateria);
    //Clientes Stream
    Stream<List<Clientes>> streamClientes = stream_builders().getTodosLosClientes(context);
    _streamControllerClientes.addStream(streamClientes);
    //Universidad Stream
    Stream<List<Universidad>> streamUniversidad = stream_builders().getTodasLasUniversidades(context);
    _streamControllerUniversidades.addStream(streamUniversidad);
  }

  _configuracionStream() async{
    //Configuración stream
    Stream<ConfiguracionPlugins> stream = stream_builders().getstreamConfiguracion(context);
    _streamController.addStream(stream);
  }

  @override
  void dispose() {
    super.dispose();
    if(widget.showSolicitudesNew || widget.showTutoresDetalles){
      _streamController.close();
      _streamControllerServiciosAgendados.close();
      _streamControllerSolicitudes.close();
      _streamControllerTutores.close();
      _streamControllerCarreras.close();
      _streamControllerMaterias.close();
      _streamControllerClientes.close();
      _streamControllerUniversidades.close();
    }
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
                    body: widget.showTutoresDetalles ? const DetallesTutores(): const TutoresVista(),
                    selectedTileColor:ButtonState.all(Utiles().hexToColor(configuracion!.primaryColor))),
              ];
            }else if(widget.showSolicitudesNew){
              return <NavigationPaneItem>[
                PaneItem(
                  icon: const Icon(FluentIcons.home),
                  title:  configuracionrol.panelnavegacion("Solicitudes",_currentPage == 0),
                  body: const DetallesServicio(),
                  selectedTileColor:ButtonState.all(Utiles().hexToColor(configuracion!.primaryColor)),
                  key: const ValueKey('/home'),
                ),
              ];
            }else{
              return <NavigationPaneItem>[
                PaneItem(
                  icon: const Icon(FluentIcons.home),
                  title:  configuracionrol.panelnavegacion("Solicitudes",_currentPage == 0),
                  body: const SolicitudesNew(),
                  selectedTileColor:ButtonState.all(Utiles().hexToColor(configuracion!.primaryColor)),
                  key: const ValueKey('/home'),
                ),
                PaneItem(icon: const Icon(Icons.person_sharp),
                    title: configuracionrol.panelnavegacion("Tutores",_currentPage==1),
                    body: widget.showTutoresDetalles ?  const DetallesTutores(): const TutoresVista(),
                    selectedTileColor:ButtonState.all(Utiles().hexToColor(configuracion.primaryColor)) ),
                PaneItem(icon: const Icon(Icons.insert_chart_outlined_rounded),
                    title: configuracionrol.panelnavegacion("Estadisticas",_currentPage==2), body: const Estadistica(),selectedTileColor:ButtonState.all(Utiles().hexToColor(configuracion.primaryColor)) ),
                PaneItem(icon: const Icon(Icons.attach_money_rounded),
                    title: configuracionrol.panelnavegacion("Contable",_currentPage==3), body: const ContableDashboard(),selectedTileColor:ButtonState.all(Utiles().hexToColor(configuracion.primaryColor)) ),
                PaneItem(icon: const Icon(Icons.settings),
                    title: configuracionrol.panelnavegacion("Centro Datos",_currentPage==4), body: const CentroConfiguracionDash(),selectedTileColor:ButtonState.all(Utiles().hexToColor(configuracion.primaryColor)) ),
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
                      if(!widget.showSolicitudesNew && !widget.showTutoresDetalles)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20.0, left: 5.0,),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(configuracion.nombreEmpresa, style: themeApp.styleText(35, true, themeApp.grayColor),),
                              StreamBuilder<List<ServicioAgendado>>(
                                stream: _streamControllerServiciosAgendados.stream,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    // No mostrar nada, ya que el stream está vacío
                                    return const Text(''); // O cualquier otro widget que no muestre nada
                                  }
                                },
                              ),
                              StreamBuilder<List<Materia>>(
                                stream: _streamControllerMaterias.stream,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    // No mostrar nada, ya que el stream está vacío
                                    return const Text(''); //
                                  }
                                },
                              ),
                              StreamBuilder<List<Clientes>>(
                                stream: _streamControllerClientes.stream,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error cliente: ${snapshot.error}');
                                  } else {
                                    // No mostrar nada, ya que el stream está vacío
                                    return const Text(''); // O cualquier otro widget que no muestre nada
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
                                    return const Text(''); // O cualquier otro widget que no muestre nada
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
                                    return const Text(''); // O cualquier otro widget que no muestre nada
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
                                    return const Text(''); // O cualquier otro widget que no muestre nada
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
                                    return const Text(''); // O cualquier otro widget que no muestre nada
                                  }
                                },
                              ),
                              /*
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

                               */
                            ],
                          ),
                        ),
                      ),
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