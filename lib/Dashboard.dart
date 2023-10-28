import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard_admin_flutter/Config/Config.dart';
import 'package:dashboard_admin_flutter/Pages/Estadistica.dart';
import 'package:dashboard_admin_flutter/Pages/Tutores.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'Objetos/Solicitud.dart';
import 'Pages/CentroConfig.dart';
import 'Pages/ContableDash.dart';
import 'Pages/Servicios/Detalle_Solicitud.dart';
import 'Pages/SolicitudesNew.dart';
import 'package:intl/intl.dart';

import 'Utils/Firebase/Load_Data.dart';

class Dashboard extends StatefulWidget {
  final bool showSolicitudesNew;
  final Solicitud solicitud;

  Dashboard({Key? key,
    required this.showSolicitudesNew,
    required this.solicitud,}) : super(key: key);

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
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
    // Mover la lógica de inicialización aquí
    WidgetsFlutterBinding.ensureInitialized(); // Asegura que Flutter esté inicializado
    configuracion.initConfig().then((_) {
      setState(() {
        configloaded = true;
      }); // Actualiza el estado para reconstruir el widget
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!configloaded && !configloadedos) {
      print("cargando vainas");
      // Configuración aún no cargada, muestra un indicador de carga o contenido temporal
      return Text('cargando'); // Ejemplo de indicador de carga
    }else if(configuracion.basicofecha.isBefore(DateTime.now())){
      return Text('Se acabo tu Licencia, expiro el ${DateFormat('dd/MM/yyyy hh:mma').format(configuracion.basicofecha)}');
  }else if(currentUser == null || configuracion.rol == "TUTOR" ){
      return Text('ERROR 404');
  }else{
      print("cargando main dash");
      return NavigationView(
        appBar: NavigationAppBar(
          title: Container(
            margin:  const EdgeInsets.only(left: 20),
            child:   Text(configuracion.nombreempresa,
              style: TextStyle(fontSize: 32),),
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
                title: configuracion.panelnavegacion("Tutores",_currentPage==1), body: TutoresVista(),selectedTileColor:ButtonState.all(configuracion.primaryColor) ),
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