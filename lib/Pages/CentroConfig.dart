import 'package:fluent_ui/fluent_ui.dart';
import 'Configuracion/AgregarVariables.dart';
import 'Configuracion/Configuracion_Completa.dart';
import 'Configuracion/editar_clientes.dart';
import 'Configuracion/historial_solicitudes.dart';

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
              body: const ConfiguracionDatos(),
            ),
            PaneItem(
              icon:  const Icon(FluentIcons.home),
              title: const Text('Agregar variables'),
              body: const AgregarVariables(),
            ),
            PaneItem(
              icon:  const Icon(FluentIcons.home),
              title: const Text('Editar Clientes'),
              body: const EditarClientes(),
            ),
            PaneItem(
              icon:  const Icon(FluentIcons.home),
              title: const Text('Clientes Consulta'),
              body: SolicitudClientesDash(),
            ),
          ]
      ),
    );
  }
}

