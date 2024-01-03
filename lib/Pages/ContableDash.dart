import 'package:dashboard_admin_flutter/Pages/Contabilidad/DashboardContabilidad.dart';
import 'package:dashboard_admin_flutter/Pages/Contabilidad/Pagos.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;

class ContableDashboard extends StatefulWidget {
  const ContableDashboard({super.key});
  @override
  ContableDashboardState createState() => ContableDashboardState();
}

class ContableDashboardState extends State<ContableDashboard> {
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
            PaneItem(
              icon:  const Icon(material.Icons.monetization_on_outlined),
              title: const Text('Registrar pagos'),
              body: const ContablePagos(),
            ),
            /*
            PaneItem(
              icon:  const Icon(FluentIcons.home),
              title: const Text('PAGOS PENDIENTES DASH'),
              body: ListaPagosDash(),
            ),
            
             */
            PaneItem(
              icon:  const Icon(material.Icons.dashboard),
              title: const Text('Dash contabilidad'),
              body: const ContaDash(),
            ),
          ]
      ),
    );
  }
}
