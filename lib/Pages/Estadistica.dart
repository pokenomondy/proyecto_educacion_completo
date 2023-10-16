import 'package:dashboard_admin_flutter/Pages/Estadisticas/Contabilida.dart';
import 'package:dashboard_admin_flutter/Pages/Estadisticas/EstadisticaMain.dart';
import 'package:dashboard_admin_flutter/Pages/Estadisticas/Ventas.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../Objetos/Solicitud.dart';
import '../Utils/Firebase/Load_Data.dart';
import 'Estadisticas/CalendarioData.dart';

class Estadistica extends StatefulWidget {
  @override
  _EstadisticaState createState() => _EstadisticaState();
}

class _EstadisticaState extends State<Estadistica> {
  int _selectedpage = 0;

  @override
  Widget build(BuildContext context) {
    final currentwidth = MediaQuery.of(context).size.width;
    return NavigationView(
      pane: NavigationPane(
        selected: _selectedpage,
        onChanged: (index) => setState(() {
          _selectedpage = index;
        }),
        displayMode: PaneDisplayMode.top,
        items: <NavigationPaneItem>[
          /*
          PaneItem(
            icon:  const Icon(FluentIcons.home),
            title: const Text('Ventas'),
            body: Ventas(),
          ),

           */
          PaneItem(
            icon:  const Icon(FluentIcons.home),
            title: const Text('CALENDARIO'),
            body: CalendarioData(),
          ),
          PaneItem(
            icon:  const Icon(FluentIcons.home),
            title: const Text('Estadisticas'),
            body: EstadisticaMain(currentwidth: currentwidth,),
          ),
          PaneItem(
              icon:  const Icon(FluentIcons.home),
              title: const Text('Contabilidad'),
              body: CrearContabilidad(),
          ),
          PaneItem(
            icon:  const Icon(FluentIcons.home),
            title: const Text('Solicitudes'),
            body: CrearSolciitudes(),
          ),
          PaneItem(
            icon:  const Icon(FluentIcons.home),
            title: const Text('PAGOS'),
            body: PagosDatos(),
          ),
          ]
      ),
    );
  }
}

