import 'package:dashboard_admin_flutter/Pages/SolicitudesNew.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/Load_Data.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../../Config/Config.dart';
import '../../Objetos/Clientes.dart';
import '../../Objetos/Solicitud.dart';
import '../../Objetos/Tutores_objet.dart';
import '../../Utils/Disenos.dart';
import '../../Utils/Utiles/FuncionesUtiles.dart';
import '../ShowDialogs/SolicitudesDialogs.dart';

class SolicitudClientesDash extends StatefulWidget {

  @override
  SolicitudClientesDashState createState() => SolicitudClientesDashState();

}

class SolicitudClientesDashState extends State<SolicitudClientesDash> {

  @override
  Widget build(BuildContext context) {
    final currentwidth = MediaQuery.of(context).size.width;
    final tamanowidth = (currentwidth/2)-30;
    return Container(
      child: Row(
        children: [
          PrimarySolicitudClientesDash(),
        ],
      ),
    );
  }
}

class PrimarySolicitudClientesDash extends StatefulWidget {

  @override
  PrimarySolicitudClientesDashState createState() => PrimarySolicitudClientesDashState();

}

class PrimarySolicitudClientesDashState extends State<PrimarySolicitudClientesDash> {
  List<Clientes> clienteList = [];
  List<Solicitud> solicitudList = [];
  List<Solicitud> solicitudFiltrada = [];
  bool dataLoaded = false;
  bool dataLoadedSolicitudes = false;
  Clientes? selectedCliente;
  List<Tutores> tutoresList = [];
  Config configuracion = Config();


  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized(); // Asegura que Flutter esté inicializado
    configuracion.initConfig().then((_) {
      setState(() {
        laodtablas(); // Cargar los datos al inicializar el widget
      });
    });
    super.initState();
  }

  Future<void> laodtablas() async {
    clienteList = await LoadData().obtenerclientes();
    solicitudList = await LoadData().obtenerSolicitudes();
    tutoresList = await LoadData().obtenertutores();
    setState(() {
      dataLoaded=true;
    });
  }

  void busquedaSolicitudes(String numerocliente) {
    if (numerocliente == null || solicitudList == null) {
      // Manejar casos nulos según sea necesario
      return;
    }
    print(numerocliente);
    solicitudFiltrada.clear();
    solicitudFiltrada = solicitudList.where((solicitud) {
      return solicitud.cliente.toString() == numerocliente;
    }).toList();
    dataLoadedSolicitudes = true;
  }


  @override
  Widget build(BuildContext context) {
    final currentwidth = MediaQuery.of(context).size.width;
      final currentheight = MediaQuery.of(context).size.height-140;
      return Container  (
        child: Row(
          children: [
            Column(
              children: [
                Container(
                  height: 30,
                  width: 200,
                  child: AutoSuggestBox<Clientes>(
                    items: clienteList.map<AutoSuggestBoxItem<Clientes>>(
                          (cliente) => AutoSuggestBoxItem<Clientes>(
                        value: cliente,
                        label: Utiles().truncateLabel(cliente.numero.toString() ),
                        onFocusChange: (focused) {
                          if (focused) {
                            debugPrint('Focused #${cliente.numero} - ');
                          }
                        },
                      ),
                    )
                        .toList(),
                    decoration: Disenos().decoracionbuscador(),
                    onSelected: (item) {
                      setState(() {
                        print("seleccionado ${item.label} con numero ${item.value?.numero.toString()}");
                        selectedCliente = item.value;
                        busquedaSolicitudes(selectedCliente!.numero!.toString());
                      });
                    },
                    onChanged: (text, reason) {
                      if (text.isEmpty ) {
                        setState(() {
                          selectedCliente = null; // Limpiar la selección cuando se borra el texto
                          dataLoadedSolicitudes = false;
                        });
                      }
                    },
                  ),
                ),
                if(dataLoadedSolicitudes==true)
                  Container(
                    color: Colors.green,
                    height: 600,
                    width: 1000,
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return CuadroSolicitudes(
                          solicitudesList: solicitudFiltrada,
                          height: currentheight,
                          clienteList: clienteList,
                          tutoresList: tutoresList,
                          primarycolor: configuracion.primaryColor,
                        );
                      },
                    ),
                  ),
              ],
            ),
          ],
      ),
    );
  }
}