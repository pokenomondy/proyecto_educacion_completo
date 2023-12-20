import 'dart:html';
import 'package:dashboard_admin_flutter/Objetos/HistorialServiciosAgendados.dart';
import 'package:dashboard_admin_flutter/Providers/Providers.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/StreamBuilders.dart';
import 'package:dashboard_admin_flutter/Utils/Utiles/FuncionesUtiles.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../Objetos/AgendadoServicio.dart';
import '../../Objetos/Objetos Auxiliares/Materias.dart';
import '../../Objetos/Tutores_objet.dart';
import '../../Utils/Disenos.dart';
import '../../Utils/Firebase/Load_Data.dart';
import '../../Utils/Firebase/Uploads.dart';
import '../../Utils/FuncionesMaterial.dart';
import 'Pagos.dart';

class ContaDash extends StatefulWidget {

  @override
  ContaDashState createState() => ContaDashState();

}

class ContaDashState extends State<ContaDash> {

  @override
  Widget build(BuildContext context) {
    final currentwidth = MediaQuery.of(context).size.width;
    final tamanowidth = (currentwidth/3)-30;
    return Container(
      child: Row(
        children: [
          PrimaryColumnContaDash(currentwidth: tamanowidth,),
          TercerColumnContaDash(currentwidth: tamanowidth,),
          SecundaryColumnContaDash(currentwidth: tamanowidth,),
        ],
      ),
    );
  }
}

class PrimaryColumnContaDash extends StatefulWidget {
  final double currentwidth;

  const PrimaryColumnContaDash({Key?key,
    required this.currentwidth,
  }) :super(key: key);

  @override
  PrimaryColumnContaDashState createState() => PrimaryColumnContaDashState();

}

class PrimaryColumnContaDashState extends State<PrimaryColumnContaDash> {
  List<Materia> materiaList = [];
  List<String> valores = [];
  bool buscador = false;
  String datoscambiostext = "";
  Materia? selectedMateria;
  Tutores? selectedTutor;
  List<String> identificadoresList = ["T","P","Q","A"];
  String? selectedIdentificador;
  DateTime cambiarfecha = DateTime.now();
  List<Tutores> tutoresList = [];
  int valorcambio = 0;
  ServicioAgendado? servicioAgendado;

  //Pagos
  int sumaPagosClientes = 0;
  int sumaPagosTutores = 0;
  int sumaPagosReembolsoCliente = 0;
  int sumaPagosReembolsoTutores = 0;
  bool disabledbutton = false;
  Map<String, dynamic> uploadconfiguracion = {};
  bool interfazpagos = false;

  void SeleccionarServicoAgendado(ServicioAgendado servicioAgendado) async {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      final contabilidadProvider = Provider.of<ContabilidadProvider>(context, listen: false);
      contabilidadProvider.seleccionarServicio(servicioAgendado);
    });
  }

  void eliminarServicioSeleccionado(){
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      final contabilidadProvider = Provider.of<ContabilidadProvider>(context, listen: false);
      //contabilidadProvider.clearServicioSeleccionado();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContabilidadProvider>(
        builder: (context, pagosProvider, child) {
          List<ServicioAgendado> serviciosAgendadosList = pagosProvider.todoslosServiciosAgendados;
          if(interfazpagos){
            SeleccionarServicoAgendado(servicioAgendado!);
          }else{
            eliminarServicioSeleccionado();
          }
          return Column(
            children: [
                Row(
                  children: [
                    Container(
                      height: 30,
                      width: 200,
                      child: AutoSuggestBox<ServicioAgendado>(
                        items: serviciosAgendadosList.map<AutoSuggestBoxItem<ServicioAgendado>>(
                              (servicioagendado) => AutoSuggestBoxItem<ServicioAgendado>(
                            value: servicioagendado,
                            label: servicioagendado.codigo,
                            onFocusChange: (focused) {
                              if (focused) {
                                debugPrint('Focused #${servicioagendado.codigo} - ');
                              }
                            },
                          ),
                        )
                            .toList(),
                        decoration: Disenos().decoracionbuscador(),
                        onSelected: (item) {
                          setState(() {
                            servicioAgendado = item.value;
                            setState(() {
                              buscador = true;
                              interfazpagos = true;
                            });
                          });
                        },
                        onChanged: (text, reason) {
                          if (text.isEmpty ) {
                            setState(() {
                              servicioAgendado = null; // Limpiar la selección cuando se borra el texto
                              interfazpagos = false;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
            ],
          );
        }
    );
  }

}

class SecundaryColumnContaDash extends StatefulWidget {
  final double currentwidth;

  const SecundaryColumnContaDash({Key?key,
    required this.currentwidth,
  }) :super(key: key);

  @override
  SecundaryColumnContaDashState createState() => SecundaryColumnContaDashState();

}

class SecundaryColumnContaDashState extends State<SecundaryColumnContaDash> {

  @override
  Widget build(BuildContext context) {
    return Consumer<ContabilidadProvider>(
        builder: (context, historialProvider, child) {
          List<HistorialAgendado> historialDelServicioSeleccionado = historialProvider.historialDelServicioSeleccionado;
          return Container(
            color: Colors.green,
            width: widget.currentwidth,
            child: Column(
              children: [
                Text('Aquí tenemos historial'),
                  Column(
                    children: [
                      Container(
                        height: 800,
                        child: ListView.builder(
                          itemCount: historialDelServicioSeleccionado.length,
                          itemBuilder: (context, index) {
                            HistorialAgendado historialcod = historialDelServicioSeleccionado[index];

                            return Container(
                              height: 100,
                              child: Card(
                                child: Column(
                                  children: [
                                    Text(historialcod.codigo),
                                    Text("CAMBIO DE ${historialcod.motivocambio} ${historialcod.cambioant} por ${historialcod.cambionew}")
                                  ],
                                ),
                              ),
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
    );
  }
}

class TercerColumnContaDash extends StatefulWidget {
  final double currentwidth;

  const TercerColumnContaDash({Key?key,
    required this.currentwidth,
  }) :super(key: key);

  @override
  TercerColumnContaDashState createState() => TercerColumnContaDashState();

}

class TercerColumnContaDashState extends State<TercerColumnContaDash> {
  List<bool> editarcasilla = [false, false,false,false,false,false,false,false,false,false,false,false,false];

  @override
  Widget build(BuildContext context) {
    return Consumer<ContabilidadProvider>(
        builder: (context, pagosProvider, child) {
          ServicioAgendado servicioAgendado = pagosProvider.servicioSeleccionado;

          return Column(
            children: [
              textoymodificable('Sistema: ', servicioAgendado.codigo,0,true),
              textoymodificable('Matería: ', servicioAgendado.materia,1,true),
              textoymodificable('Fecha sistema: ', servicioAgendado.fechasistema.toString(),2,true),
              textoymodificable('Numero cliente: ', servicioAgendado.cliente.toString(),3,true),
              textoymodificable('Precio cobrado: ', servicioAgendado.preciocobrado.toString(),4,true),
              textoymodificable('Fecha de entrega: ', servicioAgendado.fechaentrega.toString(),5,true),
              textoymodificable('Tutor: ', servicioAgendado.tutor,6,true),
              textoymodificable('Precio tutor: ', servicioAgendado.preciotutor.toString(),7,true),
              textoymodificable('identificador codigo: ', servicioAgendado.identificadorcodigo,8,true),
              textoymodificable('id solicitud: ', servicioAgendado.idsolicitud.toString(),9,true),
              textoymodificable('id Contable: ', servicioAgendado.idcontable.toString(),10,true),
            ],
          );
        }
    );
  }

  Widget textoymodificable(String text,String valor,int index,bool bool){
    String? cambio = "";

    return Row(
      children: [
        if (!editarcasilla[index])
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text("$text : $valor"),
                if(bool)
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        editarcasilla[index] = !editarcasilla[index]; // Alterna entre los modos de visualización y edición
                      });
                    },
                    child: Icon(FluentIcons.edit),
                  )
              ],
            ),
          ),
          if (editarcasilla[index])
            Row(
              children: [
                //actualizar variable
                GestureDetector(
                  onTap: () async{
                    //comprobaractualziardatos(index,cambio!,valor,valorcambio);
                  },
                  child: Icon(FluentIcons.check_list),
                ),
                //cancelar
                GestureDetector(
                  onTap: (){
                    setState(() {
                      editarcasilla[index] = !editarcasilla[index]; // Alterna entre los modos de visualización y edición
                    });
                    print("oprimido para cambiar");
                  },
                  child: Icon(FluentIcons.cancel),
                )
              ],
            ),
      ],
    );
  }
}






