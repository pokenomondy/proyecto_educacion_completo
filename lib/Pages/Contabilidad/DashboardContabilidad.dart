import 'package:dashboard_admin_flutter/Objetos/Objetos%20Auxiliares/HistorialServiciosAgendados.dart';
import 'package:dashboard_admin_flutter/Providers/Providers.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/StreamBuilders.dart';
import 'package:dashboard_admin_flutter/Utils/Utiles/FuncionesUtiles.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../Config/elements.dart';
import '../../Config/strings.dart';
import '../../Config/theme.dart';
import '../../Objetos/AgendadoServicio.dart';
import '../../Objetos/Objetos Auxiliares/Materias.dart';
import '../../Objetos/Tutores_objet.dart';
import '../../Utils/Disenos.dart';
import '../../Utils/Firebase/Uploads.dart';
import '../../Utils/FuncionesMaterial.dart';

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
    final tamanowidthtriple = (widthcompleto/3.1)-20;
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


  void seleccionarServicoAgendado(ServicioAgendado servicioAgendado, List<ServicioAgendado> serviciosAgendadosList) async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final contabilidadProvider = Provider.of<ContabilidadProvider>(context, listen: false);
      ServicioAgendado servicioEnLista = serviciosAgendadosList.firstWhere((s) => s.codigo == servicioAgendado.codigo);
      contabilidadProvider.seleccionarServicio(servicioEnLista);
      contabilidadProvider.actualizarHistorialPorCodigo(servicioEnLista.codigo);
    });
  }

  void eliminarServicioSeleccionado(){
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final contabilidadProvider = Provider.of<ContabilidadProvider>(context, listen: false);
      contabilidadProvider.clearServicioSeleccionado();
      contabilidadProvider.clearHistorial();
    });
  }

  final ThemeApp themeApp = ThemeApp();
  late bool construct = false;

  @override
  void initState(){
    super.initState();
    WidgetsFlutterBinding.ensureInitialized(); // Asegura que Flutter esté inicializado
    themeApp.initTheme().then((_) {
      setState(()=>construct = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if(construct){
      return Consumer<ContabilidadProvider>(
          builder: (context, pagosProvider, child) {
            List<ServicioAgendado> serviciosAgendadosList = pagosProvider.todoslosServiciosAgendados;

            if (servicioAgendado != null) {
              seleccionarServicoAgendado(servicioAgendado!,serviciosAgendadosList);
            }else{
              eliminarServicioSeleccionado();
            }
            return ItemsCard(
              verticalPadding: 15.0,
              height: widget.currentheight,
              width: widget.currentwidth,
              cardColor: themeApp.primaryColor,
              shadow: false,
              alignementColumn: MainAxisAlignment.start,
              children: [
                Text("Servicio", style: themeApp.styleText(20, true, themeApp.whitecolor),),
                SizedBox(
                  height: 50,
                  width: 350,
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
            );
          }
      );
    }else{
      return const Center(child: material.CircularProgressIndicator(),);
    }
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

  final ThemeApp themeApp = ThemeApp();
  late bool construct = false;

  @override
  void initState(){
    super.initState();
    WidgetsFlutterBinding.ensureInitialized(); // Asegura que Flutter esté inicializado
    themeApp.initTheme().then((_) {
      setState(()=>construct = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if(construct){
      return Consumer<ContabilidadProvider>(
          builder: (context, historialProvider, child) {
            List<HistorialAgendado> historialDelServicioSeleccionado = historialProvider.historialDelServicioSeleccionado;
            return ItemsCard(
              shadow: false,
              width: widget.currentwidth,
              height: widget.currentheight,
              cardColor: themeApp.primaryColor,
              verticalPadding: 15.0,
              children: [
                Text('Historial', style: themeApp.styleText(20, true, themeApp.whitecolor),),
                Expanded(
                  child: ListView.builder(
                    itemCount: historialDelServicioSeleccionado.length,
                    itemBuilder: (context, index) {
                      HistorialAgendado historialcod = historialDelServicioSeleccionado[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                        child: Card(
                          borderRadius: BorderRadius.circular(20),
                          backgroundColor: themeApp.whitecolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _textRow("Modificacion", historialcod.motivocambio, true, false),
                              _textRow("Anterior:", historialcod.cambioant, false, false),
                              _textRow("Nuevo:", historialcod.cambionew, false, false),
                              _textRow(historialcod.codigo, historialcod.fechacambio.toString(), false, true),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
      );
    }else{
      return const Center(child: material.CircularProgressIndicator());
    }
  }

  Padding _textRow(String title, String text, bool encabezado, bool ultima){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title, style: themeApp.styleText(ultima? 11:encabezado?15:14, !ultima, encabezado? themeApp.primaryColor: themeApp.grayColor), textAlign: TextAlign.start,)),
          Expanded(child: Text(text, style: themeApp.styleText(ultima? 11:encabezado?15:14, encabezado, encabezado? themeApp.primaryColor: themeApp.grayColor), textAlign: TextAlign.end,)),
        ],
      ),
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
  List<bool> editarcasilla = List.generate(15, (index) => false);
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

  final ThemeApp themeApp = ThemeApp();
  late bool construct = false;

  @override
  void initState(){
    super.initState();
    loadTablas();
    WidgetsFlutterBinding.ensureInitialized(); // Asegura que Flutter esté inicializado
    themeApp.initTheme().then((_) {
      setState(()=>construct = true);
    });
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
    if(construct){
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
                margin: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }else{
              return ItemsCard(
                shadow: false,
                alignementColumn: MainAxisAlignment.start,
                verticalPadding: 15.0,
                cardColor: themeApp.whitecolor,
                width: widget.currentwidth,
                height: widget.currentheight,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text("Detalles", style: themeApp.styleText(20, true, themeApp.primaryColor),),
                  ),
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
                        Text('pagos clientes ${sumaPagosClientes-sumaPagosReembolsoCliente}', style: themeApp.styleText(14, false, themeApp.grayColor),),
                        Text('pagos tutores ${sumaPagosTutores-sumaPagosReembolsoTutores}', style: themeApp.styleText(14, false, themeApp.grayColor),)
                      ],
                    ),
                  //Entrega
                  textoymodificable('Entrega Tutor: ', servicioAgendado.linkEntregaTutor.toString(),11,false),


                ],
              );
            }
          }
      );
    }else{
      return const Center(child: material.CircularProgressIndicator(),);
    }
  }

  Padding textoymodificable(String text,String valor,int index,bool bool){

    TextStyle styleText([double? tamanio]) => themeApp.styleText(tamanio?? 14, false, themeApp.blackColor);
    const double widthSuggest = 300.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!editarcasilla[index])
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("$text : $valor", style: styleText(),),
                    if(bool && widget.editDetalles)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: (){
                              setState(() {
                                editarcasilla[index] = !editarcasilla[index]; // Alterna entre los modos de visualización y edición
                              });
                            },
                            child: const Icon(FluentIcons.edit),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),
            if (editarcasilla[index])
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //Lista materias
                    if(index == 1)
                      SizedBox(
                        height: 30,
                        width: widthSuggest,
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
                      Flexible(
                        child: SizedBox(
                          child: TextBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            placeholder: valor,
                            onChanged: (value){
                              valorcambio = int.parse(value);
                              cambio = valorcambio.toString();
                              print("el valor de cambio es $cambio");
                            },
                            maxLines: null,
                          ),
                        ),
                      ),
                    //Tutores
                    if(index == 6)
                      SizedBox(
                        height: 30,
                        width: widthSuggest,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularButton(
                          buttonColor: themeApp.primaryColor,
                          iconData: material.Icons.add,
                          function: () async{
                            comprobaractualziardatos(index,cambio,valor,valorcambio);
                          },
                        ),
                        //cancelar
                        CircularButton(
                          buttonColor: themeApp.redColor,
                          iconData: material.Icons.clear,
                          function: (){
                            setState(() {
                              editarcasilla[index] = !editarcasilla[index]; // Alterna entre los modos de visualización y edición
                            });
                            print("oprimido para cambiar");
                          }
                        ),
                      ],
                    )
                  ],
                ),
              ),
        ],
      ),
    );
  }

  Column selectfecha(BuildContext context){
    return Column(
      children: [
        GestureDetector(
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
        GestureDetector(
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
    await Uploads().modifyServicioAgendado(index, servicioAgendado!.codigo, cambio,valor,valorcambio,cambiarfecha);
    setState(() {
      editarcasilla[index] = !editarcasilla[index];
    });
  }

  String _truncateLabel(String label) {
    const int maxLength = 30; // Define la longitud máxima permitida para la etiqueta
    if (label.length > maxLength) {
      return '${label.substring(0, maxLength - 3)}...'; // Agrega puntos suspensivos
    }
    return label;
  }

}






