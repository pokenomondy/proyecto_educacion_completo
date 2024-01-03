import 'package:dashboard_admin_flutter/Pages/Estadisticas/EstadisticaMain.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'Estadisticas/CalendarioData.dart';
import 'package:flutter/material.dart' as material;

class Estadistica extends StatefulWidget {
  @override
  _EstadisticaState createState() => _EstadisticaState();
}

class _EstadisticaState extends State<Estadistica> {
  int _selectedpage = 0;

  @override
  Widget build(BuildContext context) {
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
              icon:  const Icon(material.Icons.schedule_rounded),
              title: const Text('Calendario'),
              body: const CalendarioData(),
            ),
            PaneItem(
              icon:  const Icon(material.Icons.insert_chart_outlined_rounded),
              title: const Text('Estadisticas'),
              body: const EstadisticaMain(),
            ),
            /*
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

             */

          ]
      ),
    );
  }
}

