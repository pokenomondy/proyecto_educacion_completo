import 'package:dashboard_admin_flutter/Pages/Contabilidad/DashboardContabilidad.dart';
import 'package:dashboard_admin_flutter/Pages/Contabilidad/Pagos.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'Contabilidad/ListaPagos.dart';

class ContableDashboard extends StatefulWidget {

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
              icon:  const Icon(FluentIcons.home),
              title: const Text('Registrar pagos'),
              body: ContablePagos(),
            ),
            PaneItem(
              icon:  const Icon(FluentIcons.home),
              title: const Text('PAGOS PENDIENTES DASH'),
              body: ListaPagosDash(),
            ),
            PaneItem(
              icon:  const Icon(FluentIcons.home),
              title: const Text('Dash contabilidad'),
              body: ContaDash(),
            ),
          ]
      ),
    );
  }
}
