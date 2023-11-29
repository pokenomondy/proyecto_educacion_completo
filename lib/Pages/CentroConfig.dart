import 'package:dashboard_admin_flutter/Config/Config.dart';
import 'package:dashboard_admin_flutter/Config/theme.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/Load_Data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../Objetos/Solicitud.dart';
import '../Utils/Firebase/DeleteLocalData.dart';
import '../Utils/Firebase/Uploads.dart';
import 'Configuracion/AgregarVariables.dart';
import 'Configuracion/Configuracion_Completa.dart';
import 'Configuracion/EditarClientes.dart';

class CentroConfiguracionDash extends StatefulWidget {
  const CentroConfiguracionDash({super.key});

  @override
  CentroConfiguracionDashState createState() => CentroConfiguracionDashState();
}

class CentroConfiguracionDashState extends State<CentroConfiguracionDash> {
  int _selectedpage = 0;


  @override
  Widget build(BuildContext context) {
    final currentwidth = MediaQuery.of(context).size.width;
    final tamanowidth = (currentwidth/1.5)-30;
    print("se dibuja la solicitud");
    return NavigationView(
      pane: NavigationPane(
          selected: _selectedpage,
          onChanged: (index) => setState(() {
            _selectedpage = index;
          }),
          displayMode: PaneDisplayMode.top,
          items: <NavigationPaneItem>[
            PaneItem(
              icon:  const Icon(FluentIcons.home),
              title: const Text('Configuración'),
              body: ConfiguracionDatos(),
            ),
            PaneItem(
              icon:  const Icon(FluentIcons.home),
              title: const Text('Agregar variables'),
              body: AgregarVariables(),
            ),
            PaneItem(
              icon:  const Icon(FluentIcons.home),
              title: const Text('Editar Clientes'),
              body: EditarClientes(),
            ),
          ]
      ),
    );
  }
}

