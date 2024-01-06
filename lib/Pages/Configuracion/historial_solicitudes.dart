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

  const SolicitudClientesDash({Key? key}) : super(key: key);

  @override
  SolicitudClientesDashState createState() => SolicitudClientesDashState();

}

class SolicitudClientesDashState extends State<SolicitudClientesDash> {

  @override
  Widget build(BuildContext context) {
    final currentwidth = MediaQuery.of(context).size.width;
    final tamanowidth = (currentwidth/2)-Config.responsivepc;
    final currentheight = MediaQuery.of(context).size.height-Config.tamnoHeihtConMenu;

    return Row(
      children: [
        PrimarySolicitudClientesDash(currentwidth: tamanowidth,currentheight: currentheight,),
        SecundarySolicitudClientesDash(currentwidth: tamanowidth,currentheight: currentheight,)
      ],
    );
  }
}

class PrimarySolicitudClientesDash extends StatefulWidget {
  final double currentwidth;
  final double currentheight;

  const PrimarySolicitudClientesDash({Key?key,
    required this.currentwidth,
    required this.currentheight
  }) :super(key: key);

  @override
  PrimarySolicitudClientesDashState createState() => PrimarySolicitudClientesDashState();

}

class PrimarySolicitudClientesDashState extends State<PrimarySolicitudClientesDash> {
  List<Clientes> clienteList = [];
  Clientes? selectedCliente;

  @override
  Widget build(BuildContext context) {
      return Consumer<ClientesVistaProvider>(
          builder: (context, clienteProviderselect, child) {
            clienteList = clienteProviderselect.todosLosClientes;

          return Column(
            children: [
              const Text('Busqueda por numero'),
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
                    final providersolicitud = Provider.of<SolicitudProvider>(context, listen: false);
                    providersolicitud.busquedaSolicitudes(selectedCliente!.numero);
                  });
                },
                onChanged: (text, reason) {
                  if (text.isEmpty ) {
                    setState(() {
                      selectedCliente = null;
                      final providersolicitud = Provider.of<SolicitudProvider>(context, listen: false);
                      providersolicitud.clearBusqueda();
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
  final double currentheight;

  const SecundarySolicitudClientesDash({Key?key,
    required this.currentwidth,
    required this.currentheight
  }) :super(key: key);

  @override
  SecundarySolicitudClientesDashState createState() => SecundarySolicitudClientesDashState();
}

class SecundarySolicitudClientesDashState extends State<SecundarySolicitudClientesDash> {
  List<Solicitud> solicitudesList = [];
  List<Clientes> clienteList = [];
  List<Tutores> tutoresList = [];

  @override
  Widget build(BuildContext context) {


    return Consumer<SolicitudProvider>(
        builder: (context, solicitudProviderselect, child) {
          solicitudesList = solicitudProviderselect.solicitudesBUSQUEDA;

          if(solicitudesList.isEmpty){
            return const Text('Seleccione un cliente, para poder ver las solicitudes');
          }else{
            return Expanded(
              child: CuadroSolicitudes(
                solicitudesList: solicitudesList,
                height: widget.currentheight,
                clienteList: clienteList,
                tutoresList: tutoresList,
                primarycolor: Config().primaryColor,
                vistaBusqueda: true,
              ),
            );
          }
        }
    );
  }
}



