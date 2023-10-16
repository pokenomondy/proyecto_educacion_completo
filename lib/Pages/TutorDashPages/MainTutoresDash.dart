import 'package:dashboard_admin_flutter/Config/Config.dart';
import 'package:dashboard_admin_flutter/Objetos/Tutores_objet.dart';
import 'package:dashboard_admin_flutter/Pages/Estadistica.dart';
import 'package:dashboard_admin_flutter/Pages/Tutores.dart';
import 'package:dashboard_admin_flutter/Utils/Disenos.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'AgendaTutor.dart';
import 'EntregasTutor.dart';

class MainTutoresDash extends StatefulWidget {

  @override
  MainTutoresDashState createState() => MainTutoresDashState();
}

class MainTutoresDashState extends State<MainTutoresDash> {
  int _currentPage = 0;
  Config configuracion = Config();
  bool configloaded = false;

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
    if (!configloaded) {
      print("cargando vainas");
      return Text('cargando'); // Ejemplo de indicador de carga
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
            PaneItem(icon: const Icon(FluentIcons.home),
              title:  configuracion.panelnavegacion("AGENDA",_currentPage == 0),
              body: AgendaTutor(), //Este puede variar, entre detalles y solicitudes
              selectedTileColor:ButtonState.all(configuracion.primaryColor),
            ),
            PaneItem(icon: const Icon(FluentIcons.home),
              title:  configuracion.panelnavegacion("ENTREGAS",_currentPage == 1),
              body: EntregaTutor(), //Este puede variar, entre detalles y solicitudes
              selectedTileColor:ButtonState.all(configuracion.primaryColor),
            ),
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