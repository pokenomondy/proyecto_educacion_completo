import 'package:dashboard_admin_flutter/Objetos/Configuracion/Configuracion_Configuracion.dart';
import 'package:dashboard_admin_flutter/Pages/SolicitudesNew.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import '../../Config/Config.dart';
import '../../Objetos/Clientes.dart';
import '../../Objetos/Solicitud.dart';
import '../../Objetos/Tutores_objet.dart';
import '../../Providers/Providers.dart';
import '../../Utils/Disenos.dart';
import '../../Utils/Utiles/FuncionesUtiles.dart';

class SolicitudClientesDash extends StatefulWidget {

  @override
  SolicitudClientesDashState createState() => SolicitudClientesDashState();

}

class SolicitudClientesDashState extends State<SolicitudClientesDash> {

  @override
  Widget build(BuildContext context) {
    final currentwidth = MediaQuery.of(context).size.width;
    final tamanowidth = (currentwidth/2)-Config.responsivepc;
    return Container(
      child: Row(
        children: [
          PrimarySolicitudClientesDash(currentwidth: tamanowidth,),
          SecundarySolicitudClientesDash(currentwidth: tamanowidth)
        ],
      ),
    );
  }
}

class PrimarySolicitudClientesDash extends StatefulWidget {
  final double currentwidth;

  const PrimarySolicitudClientesDash({Key?key,
    required this.currentwidth,
  }) :super(key: key);

  @override
  PrimarySolicitudClientesDashState createState() => PrimarySolicitudClientesDashState();

}

class PrimarySolicitudClientesDashState extends State<PrimarySolicitudClientesDash> {
  List<Clientes> clienteList = [];
  Clientes? selectedCliente;

  @override
  Widget build(BuildContext context) {
      final currentheight = MediaQuery.of(context).size.height-140;
      return Consumer<ClientesVistaProvider>(
          builder: (context, clienteProviderselect, child) {
            clienteList = clienteProviderselect.todosLosClientes;

          return Column(
            children: [
              Text('Busqueda por numero'),
              //autosuggest
              SizedBox(
              height: 30,
              width: 200,
              child: AutoSuggestBox<Clientes>(
                items: clienteList.map<AutoSuggestBoxItem<Clientes>>(
                      (cliente) => AutoSuggestBoxItem<Clientes>(
                    value: cliente,
                    label: Utiles().truncateLabel(cliente.numero.toString() ),
                  ),
                ).toList(),
                decoration: Disenos().decoracionbuscador(),
                onSelected: (item) {
                  setState(() {
                    selectedCliente = item.value;
                  });
                },
                onChanged: (text, reason) {
                  if (text.isEmpty ) {
                    setState(() {
                      selectedCliente = null;
                    });
                  }
                },
              ),
        ),
            ],
          );
        }
      );
  }
}

class SecundarySolicitudClientesDash extends StatefulWidget {
  final double currentwidth;

  const SecundarySolicitudClientesDash({Key?key,
    required this.currentwidth,
  }) :super(key: key);

  @override
  SecundarySolicitudClientesDashState createState() => SecundarySolicitudClientesDashState();
}

class SecundarySolicitudClientesDashState extends State<SecundarySolicitudClientesDash> {

  @override
  Widget build(BuildContext context) {
    List<Solicitud> solicitudesList = [];
    List<Clientes> clienteList = [];
    List<Tutores> tutoresList = [];
    ConfiguracionPlugins? configuracion;


    return Consumer<SolicitudProvider>(
        builder: (context, solicitudProviderselect, child) {
          solicitudesList = solicitudProviderselect.todaslasSolicitudes;

          //Toca filtrar la lista
          //Toca bloquear en la lista ver cotizaciones y cotizar por tutor
          return Expanded(
            child: CuadroSolicitudes(
              solicitudesList: solicitudesList,
              height: 500,
              clienteList: clienteList,
              tutoresList: tutoresList,
              primarycolor: Config.primarycikirbackground,
            ),
          );
        }
    );
  }
}



