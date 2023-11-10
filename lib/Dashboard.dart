import 'package:dashboard_admin_flutter/Config/Config.dart';
import 'package:dashboard_admin_flutter/Pages/Estadistica.dart';
import 'package:dashboard_admin_flutter/Pages/Tutores.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/Load_Data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Objetos/Solicitud.dart';
import 'Objetos/Tutores_objet.dart';
import 'Pages/CentroConfig.dart';
import 'Pages/ContableDash.dart';
import 'Pages/Login page/PageCargando.dart';
import 'Pages/MainTutores/DetallesTutores.dart';
import 'Pages/Servicios/Detalle_Solicitud.dart';
import 'Pages/SolicitudesNew.dart';
import 'package:intl/intl.dart';

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
  Config configuracion = Config();
  bool configloaded = false;
  bool configloadedos = false;
  bool showDetallesSolicitud = false;
  final currentUser = FirebaseAuth.instance.currentUser;
  String rol = "";

  @override
  void initState() {
    super.initState();
    cargarprimeravez();
    // Mover la lógica de inicialización aquí
    WidgetsFlutterBinding.ensureInitialized(); // Asegura que Flutter esté inicializado
    configuracion.initConfig().then((_) {
      setState((){
        configloaded = true;
      }); // Actualiza el estado para reconstruir el widget
    });
  }

  void cargarprimeravez() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    entraprimeravez = prefs.getBool('datos_descargados_tablaclientes') ?? false;
  }



  @override
  Widget build(BuildContext context) {
    if (!configloaded && !configloadedos) {
      print("Cargando configuración inicial");
      // Configuración aún no cargada, muestra un indicador de carga o contenido temporal
      return Text('cargando'); // Ejemplo de indicador de carga
    }else if(configuracion.basicofecha.isBefore(DateTime.now())){
      return Text('Se acabo tu Licencia, expiro el ${DateFormat('dd/MM/yyyy hh:mma').format(configuracion.basicofecha)}');
    }else if(currentUser == null || configuracion.rol == "TUTOR" ){
      return Text('ERROR 404');
    }else if(entraprimeravez == false){
      return PageCargando();
    }else if(configuracion.tiempoActualizacion.inMinutes >= 5){
      return PageCargando();
    }else{
      return NavigationView(
        appBar: NavigationAppBar(
          title: Container(
            margin:  const EdgeInsets.only(left: 20),
            child:   Row(
              children: [
                Text(configuracion.nombreempresa, style: TextStyle(fontSize: 32),),
                Text("tiempo ${configuracion.tiempoActualizacion.inMinutes.toString()}", style: TextStyle(fontSize: 15),),
              ],
            ),
          ),
        ),
        pane: NavigationPane(
          size: const NavigationPaneSize(
            openMaxWidth: 50.00,
            openMinWidth: 50.00,
          ),
          items: <NavigationPaneItem>[

            PaneItem(
              icon: const Icon(FluentIcons.home),
              title:  configuracion.panelnavegacion("Solicitudes",_currentPage == 0),
              body: widget.showSolicitudesNew ?  DetallesServicio(solicitud: widget.solicitud,) : SolicitudesNew(),
              selectedTileColor:ButtonState.all(configuracion.primaryColor),
              key: const ValueKey('/home'),
            ),
            PaneItem(icon: const Icon(FluentIcons.home),
                title: configuracion.panelnavegacion("Tutores",_currentPage==1),
                body: widget.showTutoresDetalles ? DetallesTutores(tutor: widget.tutor,): TutoresVista(),
                selectedTileColor:ButtonState.all(configuracion.primaryColor) ),
            PaneItem(icon: const Icon(FluentIcons.home),
                title: configuracion.panelnavegacion("Estadisticas",_currentPage==2), body: Estadistica(),selectedTileColor:ButtonState.all(configuracion.primaryColor) ),
            PaneItem(icon: const Icon(FluentIcons.home),
                title: configuracion.panelnavegacion("Contable",_currentPage==3), body: ContableDashboard(),selectedTileColor:ButtonState.all(configuracion.primaryColor) ),
            PaneItem(icon: const Icon(FluentIcons.home),
                title: configuracion.panelnavegacion("Centro Datos",_currentPage==4), body: ConfiguracionDatos(),selectedTileColor:ButtonState.all(configuracion.primaryColor) ),
          ],
          selected: _currentPage,
          onChanged: (index) => setState(() {
            _currentPage = index;
          }),
        ),
      );
    }
  }
}