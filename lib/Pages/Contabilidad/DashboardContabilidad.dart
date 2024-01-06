import 'dart:html';
import 'package:dashboard_admin_flutter/Objetos/Configuracion/objeto_configuracion.dart';
import 'package:dashboard_admin_flutter/Objetos/Objetos%20Auxiliares/HistorialServiciosAgendados.dart';
import 'package:dashboard_admin_flutter/Providers/Providers.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/StreamBuilders.dart';
import 'package:dashboard_admin_flutter/Utils/Utiles/FuncionesUtiles.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../Config/elements.dart';
import '../../Config/strings.dart';
import '../../Objetos/AgendadoServicio.dart';
import '../../Objetos/Objetos Auxiliares/Materias.dart';
import '../../Objetos/Tutores_objet.dart';
import '../../Utils/Disenos.dart';
import '../../Utils/Firebase/Load_Data.dart';
import '../../Utils/Firebase/Uploads.dart';
import '../../Utils/FuncionesMaterial.dart';
import 'Pagos.dart';

class ContaDash extends StatefulWidget {
  const ContaDash({super.key});
  @override
  ContaDashState createState() => ContaDashState();
}

class ContaDashState extends State<ContaDash> {
  @override
  Widget build(BuildContext context) {
    //tamaño completo de width
    final widthcompleto = MediaQuery.of(context).size.width;
    //tamaño completo de height
    final currentheight = MediaQuery.of(context).size.height;
    //triple para pc
    final tamanowidthtriple = (widthcompleto/3)-20;
    //doble para tablet
    final tamanowidthdouble = (widthcompleto/2)-40;
    //doble para celular
    final tamanowidthdoubleCelular = (widthcompleto/2);

    return Row(
      children: [
        if(widthcompleto >= 1200)
          Row(
            children: [
              PrimaryColumnContaDash(currentwidth: tamanowidthtriple,currentheight: currentheight,),
              TercerColumnContaDash(currentwidth: tamanowidthtriple,currentheight: currentheight,editDetalles: true,),
              SecundaryColumnContaDash(currentwidth: tamanowidthtriple,currentheight: currentheight,),
            ],
          ),
        if(widthcompleto < 1200 && widthcompleto > 620)
          getResponsve(tamanowidthdouble,widthcompleto-80,currentheight-180),
        if(widthcompleto <= 620)
          getResponsve(tamanowidthdoubleCelular,widthcompleto,currentheight-180),

      ],
    );
  }

  Widget getResponsve(double doblewidth,double widthhentero, double currentheight){
    return Column(
      children: [
        PrimaryColumnContaDash(currentwidth: widthhentero,currentheight: 80,),
        Row(
          children: [
            TercerColumnContaDash(currentwidth: doblewidth,currentheight: currentheight,editDetalles: true,),
            SecundaryColumnContaDash(currentwidth: doblewidth,currentheight: currentheight,),
          ],
        )
      ],
    );
  }
}

class PrimaryColumnContaDash extends StatefulWidget {
  final double currentwidth;
  final double currentheight;

  const PrimaryColumnContaDash({Key?key,
    required this.currentwidth,
    required this.currentheight,
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


  void SeleccionarServicoAgendado(ServicioAgendado servicioAgendado, List<ServicioAgendado> serviciosAgendadosList) async {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      final contabilidadProvider = Provider.of<ContabilidadProvider>(context, listen: false);
      ServicioAgendado servicioEnLista = serviciosAgendadosList.firstWhere((s) => s.codigo == servicioAgendado.codigo);
      contabilidadProvider.seleccionarServicio(servicioEnLista);
      contabilidadProvider.actualizarHistorialPorCodigo(servicioEnLista!.codigo);
    });
  }

  void eliminarServicioSeleccionado(){
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      final contabilidadProvider = Provider.of<ContabilidadProvider>(context, listen: false);
      contabilidadProvider.clearServicioSeleccionado();
      contabilidadProvider.clearHistorial();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContabilidadProvider>(
        builder: (context, pagosProvider, child) {
          List<ServicioAgendado> serviciosAgendadosList = pagosProvider.todoslosServiciosAgendados;

          if (servicioAgendado != null) {
            SeleccionarServicoAgendado(servicioAgendado!,serviciosAgendadosList);
          }else{
            eliminarServicioSeleccionado();
          }
          return Container(
            height: widget.currentheight,
            width: widget.currentwidth,
            color: Colors.yellow,
            child: Row(
              children: [
                Container(
                  height: 50,
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
                        buscador = true;
                      });
                    },
                    onChanged: (text, reason) {
                      if (text.isEmpty ) {
                        setState(() {
                          servicioAgendado = null;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        }
    );
  }

}

class SecundaryColumnContaDash extends StatefulWidget {
  final double currentwidth;
  final double currentheight;

  const SecundaryColumnContaDash({Key?key,
    required this.currentwidth,
    required this.currentheight,
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
            height: widget.currentheight,
            child: Column(
              children: [
                Text('Aquí tenemos historial'),
                  Column(
                    children: [
                      Container(
                        height: 600,
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
  final double currentheight;
  final bool editDetalles;

  const TercerColumnContaDash({Key?key,
    required this.currentwidth,
    required this.currentheight,
    required this.editDetalles,
  }) :super(key: key);

  @override
  TercerColumnContaDashState createState() => TercerColumnContaDashState();

}

class TercerColumnContaDashState extends State<TercerColumnContaDash> {
  List<bool> editarcasilla = List.generate(11, (index) => false);
  //Pagos
  int sumaPagosClientes = 0;
  int sumaPagosTutores = 0;
  int sumaPagosReembolsoCliente = 0;
  int sumaPagosReembolsoTutores = 0;
  bool disabledbutton = false;
  Map<String, dynamic> uploadconfiguracion = {};
  //lista de materias
  List<Materia> materiaList = [];
  Materia? selectedMateria;
  //servicio seleccionado
  ServicioAgendado? servicioAgendado;
  DateTime cambiarfecha = DateTime.now();
  //valor de cambio
  int valorcambio= 0;
  //lista de tutores
  List<Tutores> tutoresList = [];
  Tutores? selectedTutor;
  //CAMBIOS
  String cambio = "";

  @override
  void initState() {
    loadTablas(); // Cargar los datos al inicializar el widget
    super.initState();
  }

  Future<void> loadTablas() async {
    final tutoresProvider = Provider.of<VistaTutoresProvider>(context, listen: false);
    materiaList = await stream_builders().cargarMaterias();
    tutoresList = tutoresProvider.tutoresactivos;
  }

  void actualizarpagosMain(List<ServicioAgendado> servicioagendadoList,ServicioAgendado servicio) async{
    uploadconfiguracion = await Utiles().actualizarpagos(servicio, context,servicioagendadoList);
    servicioAgendado = servicio;
    setState(() {
      sumaPagosClientes = uploadconfiguracion['sumaPagosClientes'];
      sumaPagosTutores = uploadconfiguracion['sumaPagosTutores'];
      sumaPagosReembolsoCliente = uploadconfiguracion['sumaPagosReembolsoCliente'];
      sumaPagosReembolsoTutores = uploadconfiguracion['sumaPagosReembolsoTutores'];
    });
  }

  void clearProviderServicio(){
    sumaPagosClientes = 0;
    sumaPagosTutores = 0;
    sumaPagosReembolsoCliente = 0;
    sumaPagosReembolsoTutores = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContabilidadProvider>(
        builder: (context, pagosProvider, child) {
          ServicioAgendado servicioAgendado = pagosProvider.servicioSeleccionado;
          List<ServicioAgendado> servicioAgendadoList = pagosProvider.todoslosServiciosAgendados;

          if(servicioAgendado.sistema!=""){
            actualizarpagosMain(servicioAgendadoList,servicioAgendado);
          }else{
            clearProviderServicio();
          }

          if(servicioAgendado.sistema==""){
            return Container(
              width: widget.currentwidth,
              height: widget.currentheight,
            );
          }else{
            return Container(
              width: widget.currentwidth,
              height: widget.currentheight,
              child: Column(
                children: [
                  textoymodificable('Código: ', servicioAgendado.codigo,0,false),
                  textoymodificable('Matería: ', servicioAgendado.materia,1,true),
                  if(widget.editDetalles)
                    Column(
                      children: [
                        textoymodificable('Fecha sistema: ', servicioAgendado.fechasistema.toString(),2,false),
                        textoymodificable('Numero cliente: ', servicioAgendado.cliente.toString(),3,false),
                        textoymodificable('Precio cobrado: ', servicioAgendado.preciocobrado.toString(),4,true),
                        textoymodificable('Tutor: ', servicioAgendado.tutor,6,true),
                        textoymodificable('identificador codigo: ', servicioAgendado.identificadorcodigo,8,false),
                      ],
                    ),
                  textoymodificable('Fecha de entrega: ', servicioAgendado.fechaentrega.toString(),5,true),
                  textoymodificable('Precio tutor: ', servicioAgendado.preciotutor.toString(),7,true),
                  textoymodificable('id solicitud: ', servicioAgendado.idsolicitud.toString(),9,false),
                  textoymodificable('id Contable: ', servicioAgendado.idcontable.toString(),10,false),
                  if(widget.editDetalles)
                    Column(
                      children: [
                        Text('pagos clientes ${sumaPagosClientes-sumaPagosReembolsoCliente}'),
                        Text('pagos tutores ${sumaPagosTutores-sumaPagosReembolsoTutores}')
                      ],
                    )

                ],
              ),
            );
          }
        }
    );
  }

  Widget textoymodificable(String text,String valor,int index,bool bool){

    return Row(
      children: [
        if (!editarcasilla[index])
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text("$text : $valor"),
                if(bool && widget.editDetalles)
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
                //Lista materias
                if(index == 1)
                  Container(
                    height: 30,
                    width: 300,
                    child: AutoSuggestBox<Materia>(
                      items: materiaList.map<AutoSuggestBoxItem<Materia>>(
                            (materia) => AutoSuggestBoxItem<Materia>(
                          value: materia,
                          label: _truncateLabel(materia.nombremateria),
                          onFocusChange: (focused) {
                            if (focused) {
                              debugPrint('Focused #${materia.nombremateria} - ');
                            }
                          },
                        ),
                      )
                          .toList(),
                      decoration: Disenos().decoracionbuscador(),
                      onSelected: (item) {
                        setState(() {
                          selectedMateria = item.value;
                          cambio = item.value!.nombremateria;
                        });
                      },
                      onChanged: (text, reason) {
                        if (text.isEmpty ) {
                          setState(() {
                            selectedMateria = null; // Limpiar la selección cuando se borra el texto
                          });
                        }
                      },
                    ),
                  ),
                //Precio tutor y precio al cliente
                if(index == 4 || index == 7)
                  Container(
                    width: 100,
                    child: TextBox(
                      placeholder: valor,
                      onChanged: (value){
                        valorcambio = int.parse(value);
                        cambio = valorcambio.toString();
                        print("el valor de cambio es $cambio");
                      },
                      maxLines: null,
                    ),
                  ),
                //Tutores
                if(index == 6)
                  Container(
                    height: 30,
                    width: 300,
                    child: AutoSuggestBox<Tutores>(
                      items: tutoresList.map<AutoSuggestBoxItem<Tutores>>(
                            (tutor) => AutoSuggestBoxItem<Tutores>(
                          value: tutor,
                          label: _truncateLabel(tutor.nombrewhatsapp),
                          onFocusChange: (focused) {
                            if (focused) {
                              debugPrint('Focused #${tutor.nombrewhatsapp} - ');
                            }
                          },
                        ),
                      )
                          .toList(),
                      decoration: Disenos().decoracionbuscador(),
                      onSelected: (item) {
                        setState(() {
                          print("seleccionado ${item.label}");
                          selectedTutor = item.value; // Actualizar el valor seleccionado
                          cambio = item.value!.nombrewhatsapp;
                        });
                      },
                      onChanged: (text, reason) {
                        if (text.isEmpty ) {
                          setState(() {
                            selectedTutor = null; // Limpiar la selección cuando se borra el texto
                          });
                        }
                      },
                    ),
                  ),
                //Fecha de entrega
                if(index == 5)
                  selectfecha(context),
                //actualizar variable
                GestureDetector(
                  onTap: () async{
                    comprobaractualziardatos(index,cambio!,valor,valorcambio);
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

  Column selectfecha(BuildContext context){
    return Column(
      children: [
        Container(
          child: GestureDetector(
            onTap: () async{
              final date = await Utiles().pickDate(context,cambiarfecha);
              if(date == null) return;

              final newDateTime = DateTime(
                date.year,
                date.month,
                date.day,
                cambiarfecha.hour,
                cambiarfecha.minute,
              );

              setState( () =>
              cambiarfecha = newDateTime
              );
            },
            child: Disenos().fecha_y_entrega('${cambiarfecha.day}/${cambiarfecha.month}/${cambiarfecha.year}',400),
          ),
        ),
        Container(
          child: GestureDetector(
            onTap: () async {
              final time = await FuncionesMaterial().pickTime(context,cambiarfecha);
              if (time == null) return;

              final newDateTime = DateTime(
                cambiarfecha.year,
                cambiarfecha.month,
                cambiarfecha.day,
                time.hour,
                time.minute,
              );
              setState(() =>
              cambiarfecha = newDateTime
              );
              final formattedTime = DateFormat('hh:mm a').format(cambiarfecha);
              print(formattedTime);
            },
            child: Disenos().fecha_y_entrega(DateFormat('hh:mm  a').format(cambiarfecha), 400),
          ),
        ),
      ],
    );
  }

  void comprobaractualziardatos(int index,String cambio,String valor, int valorcambio,) async{
    UtilDialogs dialogs = UtilDialogs(context : context);
    int pagocliente = sumaPagosClientes-sumaPagosReembolsoCliente;
    int pagoTutor = sumaPagosTutores-sumaPagosReembolsoTutores;
    if(index == 1 && cambio == valor){
      dialogs.error(Strings().errorseleccionemateria, Strings().errorglobalText);
      Utiles().notificacion("Selecciona una materia", context, false,"desp");
    }else if(index == 4 && sumaPagosClientes>0){
      if(valorcambio < pagocliente ){
        Utiles().notificacion("No se puede cambiar, porque el precio es < al pagado", context, false,"desp");
        print("valor de cambio es $valorcambio y el pagocliente $pagocliente");
      }else{
        Utiles().notificacion("CAMBIANDO PRECIO", context, true,"desp");
        _cambiarprecio(index, valor, cambio, valorcambio);
      }
    }else if(index == 7 && sumaPagosTutores>0){
      if(valorcambio < pagoTutor){
        Utiles().notificacion("No se puede editar el precio porque hay pagos", context, false,"desp");
        print("valor de cambio es $valorcambio y el pagocliente $pagoTutor");
      }else{
        Utiles().notificacion("CAMBIANDO PRECIO", context, true,"desp");
        _cambiarprecio(index, valor, cambio, valorcambio);
      }
    } else if(index==5){
      if(cambiarfecha.isBefore(DateTime.now())){
        Utiles().notificacion("No se puede editar por la fecha", context, false,"desp");
      }else{
        _cambiarprecio(index, valor, cambio, valorcambio);
      }
    } else{
      _cambiarprecio(index, valor, cambio, valorcambio);
    }
  }

  Future<void> _cambiarprecio(int index,String valor,String cambio,int valorcambio) async{
    print("a modificar el servicio ${servicioAgendado!.codigo}");
    await Uploads().modifyServicioAgendado(index, servicioAgendado!.codigo, cambio!,valor!,valorcambio,cambiarfecha);
    setState(() {
      editarcasilla[index] = !editarcasilla[index];
    });
  }

  String _truncateLabel(String label) {
    const int maxLength = 30; // Define la longitud máxima permitida para la etiqueta
    if (label.length > maxLength) {
      return label.substring(0, maxLength - 3) + '...'; // Agrega puntos suspensivos
    }
    return label;
  }

}






