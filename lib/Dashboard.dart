import 'dart:async';
import 'package:dashboard_admin_flutter/Config/Config.dart';
import 'package:dashboard_admin_flutter/Objetos/AgendadoServicio.dart';
import 'package:dashboard_admin_flutter/Pages/Estadistica.dart';
import 'package:dashboard_admin_flutter/Pages/Tutores.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/Load_Data.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/StreamBuilders.dart';
import 'package:dashboard_admin_flutter/Utils/Utiles/FuncionesUtiles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Objetos/Configuracion/Configuracion_Configuracion.dart';
import 'Objetos/Solicitud.dart';
import 'Objetos/Tutores_objet.dart';
import 'Pages/CentroConfig.dart';
import 'Pages/ContableDash.dart';
import 'Pages/Login page/PageCargando.dart';
import 'Pages/MainTutores/DetallesTutores.dart';
import 'Pages/Servicios/Detalle_Solicitud.dart';
import 'Pages/SolicitudesNew.dart';
import 'package:intl/intl.dart';
import 'Utils/Firebase/CollectionReferences.dart';

class Dashboard extends StatefulWidget {
  final bool showSolicitudesNew;
  final Solicitud solicitud;
  final bool showTutoresDetalles;
  final Tutores tutor;

  const Dashboard({Key? key,
    required this.showSolicitudesNew,
    required this.solicitud,
    required this.showTutoresDetalles,
    required this.tutor,
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


  @override
  void initState() {
    super.initState();
    cargarprimeravez();
    // Mover la lógica de inicialización aquí
    WidgetsFlutterBinding.ensureInitialized(); // Asegura que Flutter esté inicializado
    configuracionrol.initConfig().then((_) {
      setState((){
        configloaded = true;
      }); // Actualiza el estado para reconstruir el widget
    });
    //Cargamos streambuilder
    _streamController = StreamController<ConfiguracionPlugins>();
    _streamControllerServiciosAgendados = StreamController<List<ServicioAgendado>>();
    _initStream();
  }

  _initStream() async {
    //Configuración stream
    Stream<ConfiguracionPlugins> stream = await stream_builders().getstreamConfiguracion(context);
    _streamController.addStream(stream);
    //Contabilidad stream
    Stream<List<ServicioAgendado>> streamservicios = await stream_builders().getServiciosAgendados(context);
    _streamControllerServiciosAgendados.addStream(streamservicios);
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
          return CircularProgressIndicator();
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
                    body: widget.showTutoresDetalles ? DetallesTutores(tutor: widget.tutor,): TutoresVista(),
                    selectedTileColor:ButtonState.all(Utiles().hexToColor(configuracion!.PrimaryColor))),
              ];
            }else{
              return <NavigationPaneItem>[
                PaneItem(
                  icon: const Icon(FluentIcons.home),
                  title:  configuracionrol.panelnavegacion("Solicitudes",_currentPage == 0),
                  body: widget.showSolicitudesNew ?  DetallesServicio(solicitud: widget.solicitud,) : SolicitudesNew(),
                  selectedTileColor:ButtonState.all(Utiles().hexToColor(configuracion!.PrimaryColor)),
                  key: const ValueKey('/home'),
                ),
                PaneItem(icon: const Icon(FluentIcons.home),
                    title: configuracionrol.panelnavegacion("Tutores",_currentPage==1),
                    body: widget.showTutoresDetalles ? DetallesTutores(tutor: widget.tutor,): TutoresVista(),
                    selectedTileColor:ButtonState.all(Utiles().hexToColor(configuracion!.PrimaryColor)) ),
                PaneItem(icon: const Icon(FluentIcons.home),
                    title: configuracionrol.panelnavegacion("Estadisticas",_currentPage==2), body: Estadistica(),selectedTileColor:ButtonState.all(Utiles().hexToColor(configuracion!.PrimaryColor)) ),
                PaneItem(icon: const Icon(FluentIcons.home),
                    title: configuracionrol.panelnavegacion("Contable",_currentPage==3), body: ContableDashboard(),selectedTileColor:ButtonState.all(Utiles().hexToColor(configuracion!.PrimaryColor)) ),
                PaneItem(icon: const Icon(FluentIcons.home),
                    title: configuracionrol.panelnavegacion("Centro Datos",_currentPage==4), body: CentroConfiguracionDash(),selectedTileColor:ButtonState.all(Utiles().hexToColor(configuracion!.PrimaryColor)) ),
              ];
            }
          }

          if(currentUser == null || configuracionrol.rol == "TUTOR"){
            return Text('ERROR 404');
          }
          else if(configuracion!.basicoFecha.isBefore(DateTime.now())){
            return Text('Vencio la licencia');
          }
          else{
            return NavigationView(
              appBar: NavigationAppBar(
                title: Container(
                  margin:  const EdgeInsets.only(left: 20),
                  child:   Row(
                    children: [
                      Text(configuracion!.nombre_empresa, style: const TextStyle(fontSize: 32),),
                      const Text("Dufy Amor", style: TextStyle(fontSize: 15),),
                      StreamBuilder<List<ServicioAgendado>>(
                        stream: _streamControllerServiciosAgendados.stream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            // No mostrar nada, ya que el stream está vacío
                            return Text('conta true'); // O cualquier otro widget que no muestre nada
                          }
                        },
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