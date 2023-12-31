import 'package:dashboard_admin_flutter/Config/elements.dart';
import 'package:dashboard_admin_flutter/Objetos/RegistrarPago.dart';
import 'package:dashboard_admin_flutter/Utils/Utiles/FuncionesUtiles.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/Uploads.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import '../../Config/Config.dart';
import '../../Config/theme.dart';
import '../../Objetos/AgendadoServicio.dart';
import '../../Objetos/Configuracion/objeto_configuracion.dart';
import '../../Providers/Providers.dart';
import '../../Utils/Disenos.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart' as material;
import 'package:intl/intl.dart';


class ContablePagos extends StatefulWidget {
  const ContablePagos({super.key});
  @override
  ContablePagosState createState() => ContablePagosState();
}

class ContablePagosState extends State<ContablePagos> {
  List<ServicioAgendado> servicioagendadList = [];
  List<ServicioAgendado> updatedServicioAgendadoList = []; // Agrega esta variable
  bool dataloaded = false;
  String selectedCodigo = ""; // Mantén el código seleccionado aquí
  bool cargue = false;
  final GlobalKey<_ContainerPagosState> registrarpago = GlobalKey<_ContainerPagosState>();

  @override
  void initState() {
    loadTablaTutores(); // Cargar los datos al inicializar el widget
    super.initState();
  }

  Future<void> loadTablaTutores() async {
    //servicioagendadList = await stream_builders().cargarserviciosagendados();
    setState(() {
      dataloaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    //Completo
    final widthCompleto = MediaQuery.of(context).size.width;
    //tamaño para computador y tablet
    final tamanowidthdobleComputador = (widthCompleto/2)-Config.responsivepc/2;
    //tamaño para celular
    final tamanowidthdobleCelular = (widthCompleto/2) - Config.responsivecelular/2-10;
    //currentheight completo
    final heightCompleto = MediaQuery.of(context).size.height-Config.tamnoHeihtConMenu;

    return Column(
      children: [
        if(widthCompleto >= 1200)
          getVista(tamanowidthdobleComputador,heightCompleto),
        if(widthCompleto < 1200 && widthCompleto > 620)
          getVista(tamanowidthdobleComputador,heightCompleto),
        if(widthCompleto <= 620)
          getVista(tamanowidthdobleCelular,heightCompleto),
      ],
    );
  }

  Widget getVista(double currentwidth, double currentheight){
    return Row(
      children: [
        _ContainerPagos(currentwidth: currentwidth,dataloaded: dataloaded,servicioagendadList: servicioagendadList,key: registrarpago,currentheight: currentheight,),
        ContainerPagosDashboard(currentwidth: currentwidth,dataloaded: dataloaded,currentheight: currentheight,)
      ],
    );
  }
}

class _ContainerPagos extends StatefulWidget{
  final double currentwidth;
  final bool dataloaded;
  final List<ServicioAgendado> servicioagendadList;
  final double currentheight;

  const _ContainerPagos({Key?key,
    required this.currentwidth,
    required this.dataloaded,
    required this.servicioagendadList,
    required this.currentheight,
  }) :super(key: key);

  @override
  _ContainerPagosState createState() => _ContainerPagosState();
}

class _ContainerPagosState extends State<_ContainerPagos> {
    List<String> tipodepagos = ['CLIENTES','TUTOR','CANCELADO','REEMBOLSOCLIENTE','REEMBOLSOTUTOR'];
    List<String> metodopagos = ['NEQUI','BANCOLOMBIA','DAVIPLATA','BINANCE','AUTOPAGO','PAYPAL'];
  
    ServicioAgendado? selectedservicio;
    String selectedtipopago = "";
    int valordepago = 0;
    String selectedmetodopago = "";
    DateTime fecharegistropago = DateTime.now();
    Map<String, List<RegistrarPago>> pagosPorServicio = {};
    List<PlatformFile>? selectedFiles ;
    List<ServicioAgendado> servicioagendadList = [];
    bool cargandopagos = false;
    final TextEditingController _controllerpagos = TextEditingController(); //controller valor de pago
    final TextEditingController _referenciaPagos = TextEditingController();
    bool interfazpagos = false;

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

    //Pagos
    int sumaPagosClientes = 0;
    int sumaPagosTutores = 0;
    int sumaPagosReembolsoCliente = 0;
    int sumaPagosReembolsoTutores = 0;
    bool disabledbutton = false;
    Map<String, dynamic> uploadconfiguracion = {};

    //apoyo para configuración
    bool configuracionSolicitudes = false;
    String idcarpetaPagosDrive = "";


    void actualizarpagosMain(List<ServicioAgendado> servicioagendadoList,String codigo) async{
      uploadconfiguracion = await Utiles().actualizarpagos(selectedservicio!, context,servicioagendadoList);
      setState(() {
        sumaPagosClientes = uploadconfiguracion['sumaPagosClientes'];
        sumaPagosTutores = uploadconfiguracion['sumaPagosTutores'];
        sumaPagosReembolsoCliente = uploadconfiguracion['sumaPagosReembolsoCliente'];
        sumaPagosReembolsoTutores = uploadconfiguracion['sumaPagosReembolsoTutores'];
      });
      final pagosProvider = Provider.of<ContabilidadProvider>(context, listen: false);
      pagosProvider.actualizarPagosPorCodigo(codigo);
    }

    Future selectFile() async{
      if(kIsWeb){
        final result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: false);
  
        if (result != null && result.files.isNotEmpty) {
          final fileName = result.files.first.name;
          final fileextension = result.files.first.extension;
          setState(() {
            selectedFiles  = result.files;
            print(fileName);
            print(fileextension);
          });
        }}else{
        print('Aqui no va a pasar');
      }
    }

    void clearProviderPagos(){
      final pagosProvider = Provider.of<ContabilidadProvider>(context, listen: false);
      pagosProvider.clearPagos();
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
              List<ServicioAgendado> serviciosAgendadosList = pagosProvider.todoslosServiciosAgendados;
              if(selectedservicio!=null){
                actualizarpagosMain(serviciosAgendadosList,selectedservicio!.codigo);
              }else{
                clearProviderPagos();
              }
              return Stack(
                children: [
                  cuadroPagos(serviciosAgendadosList),
                  if(cargandopagos==true)
                    const Positioned.fill(
                      child: AbsorbPointer(
                        absorbing: true, // Evita todas las interacciones del usuario
                        child: Center(
                          child: material.CircularProgressIndicator(), // Puedes personalizar el indicador de carga
                        ),
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

    void comprobacionpagos(int debecliente,int debetutor) async{
      if(selectedtipopago=="CLIENTES"){
        if(debecliente == 0){
          Utiles().notificacion("Error, el cliente ya pago todo", context, false, "No joda");
        }else if(valordepago == 0){
          Utiles().notificacion("Error, el valor de pago no puede ser 0", context, false, "cambielo");
  
        }else if(valordepago > debecliente){
          Utiles().notificacion("Error, el valor de pago no puede ser mayor ", context, false, "cambielo");
        }else{
          addpagomain();
        }
      }else if(selectedtipopago == "TUTOR"){
        if(debetutor == 0){
          Utiles().notificacion("Error, ya se le pago al tutor", context, false, "No joda");
        }else if(valordepago == 0){
          Utiles().notificacion("Error, ya se le pago al tutor", context, false, "No joda");
        }else if(valordepago > debetutor){
          Utiles().notificacion("Error, el valor de pago no puede ser mayor ", context, false, "cambielo");
        } else{
          addpagomain();
        }
      }else if(selectedtipopago == "CANCELADO"){
        if(sumaPagosTutores > 0 || sumaPagosTutores > 0){
          print("No hace ni mierda, se debe cancelar el oprimir el boton");
        }else{
          Uploads().modificarcancelado(selectedservicio!.idcontable, 0, 0);
          Utiles().notificacion("Servicio cancelado ", context, false, "Servicio al parecer cancelado");
          //Toca modificar el precio del servicio , precio cobrado 0 y precio de tutor 0, y marcar como cancelado en el registro, o algo asi
        }
      }else if(selectedtipopago == "REEMBOLSOCLIENTE"){
        if(sumaPagosClientes-sumaPagosReembolsoCliente==0){
          Utiles().notificacion("Error, no se puede reembolsar mas dinero", context, false, "cambielo");
        }else if(sumaPagosClientes-sumaPagosReembolsoCliente<valordepago){
          Utiles().notificacion("Error, No puede reembolsar esa cantidad", context, false, "cambielo");
        }
        else{
          addpagomain();
        }
      }else if(selectedtipopago == "REEMBOLSOTUTOR"){
        if(sumaPagosTutores-sumaPagosReembolsoTutores==0){
          Utiles().notificacion("Error, no se puede reembolsar mas dinero", context, false, "cambielo");
        }else if(sumaPagosTutores-sumaPagosReembolsoTutores<valordepago){
          Utiles().notificacion("Error, No puede reembolsar esa cantidad", context, false, "cambielo");
        }
        else{
          addpagomain();
        }
      }
    }
  
    void addpagomain() async{
      setState(() {
        cargandopagos = true;
      });
      await Uploads().addPago(selectedservicio!.idcontable, selectedservicio!, selectedtipopago, valordepago, _referenciaPagos.text, fecharegistropago, selectedmetodopago,context);
      // Actualiza la lista de pagos por servicio
      if(configuracionSolicitudes){
        //await DriveApiUsage().subirPago(idcarpetaPagosDrive, selectedFiles, _referenciaPagos.text);
      }else{
      }
      //Borrar todas las variables anteriores
      setState(() {
        selectedFiles=null;
        selectedtipopago="";
        selectedmetodopago ="";
        _referenciaPagos.text ="null";
        valordepago=0;
        cargandopagos = false;
        _controllerpagos.text = "";
        interfazpagos = false;
      });
    }
  
    Text textopagoclientetutor(int debecliente,int debetutor){
      TextStyle style = themeApp.styleText(15, false, themeApp.blackColor);
      if(selectedtipopago=="CLIENTES"){
        if(debecliente!=0){
          return Text("El cliente debe ${selectedservicio!.preciocobrado-sumaPagosClientes+sumaPagosReembolsoCliente}", style: style,);
        }else{
          return Text("TODO PAGO", style: style,);
        }
      }else if(selectedtipopago =="TUTOR"){
        if(debetutor!=0){
          return Text("El tutor debe ${selectedservicio!.preciotutor-sumaPagosTutores+sumaPagosReembolsoTutores}", style: style,);
        }else{
          return Text("TODO PAGO", style: style,);
        }
      }else if(selectedtipopago =="CANCELADO"){
        if(sumaPagosClientes > 0 || sumaPagosTutores > 0){
          setState(() {
            disabledbutton = true;
          });
          return Text('No se puede cancelar,hay pagos', style: style,);
        }else{
          return Text("SE PUEDE CANCELAR ${selectedservicio!.idcontable}", style: style,);
        }
      }else if(selectedtipopago =="REEMBOLSOCLIENTE"){
        if(sumaPagosClientes-sumaPagosReembolsoCliente==0){
          setState(() {
            disabledbutton = true;
          });
          return Text('No se puede reembolsar saldo,el saldo es 0', style: style,);
        }else{
          return Text('Se puede reembolsar ${sumaPagosClientes-sumaPagosReembolsoCliente}', style: style,);
        }
      }else if(selectedtipopago=="REEMBOLSOTUTOR"){
        if(sumaPagosTutores-sumaPagosReembolsoTutores==0){
          setState(() {
            disabledbutton = true;
          });
          return Text('No se puede reembolsar saldo,el saldo es 0', style: style,);
        }else{
          return Text('SE PUEDEN REEMBOLSAR ${sumaPagosTutores-sumaPagosReembolsoTutores}', style: style,);
        }
      }else{
        return Text('Seleccione el tipo de pago a revisar', style: style,);
      }
    }

    ItemsCard cuadroPagos(List<ServicioAgendado> serviciosAgendadosList){

      Text subText(String text, double tamanio, [bool? isBold]) => Text(text, style: themeApp.styleText(tamanio, isBold??false, themeApp.blackColor),);
      const double tamanioText = 14;
      const double verticalPadding = 5.0;

      return ItemsCard(
        width: widget.currentwidth,
        height: widget.currentheight,
        alignementColumn: MainAxisAlignment.start,
        horizontalPadding: 20.0,
        verticalPadding: 12.0,
        shadow: false,
        children: [

          Text("Registrar pagos", style: themeApp.styleText(22, true, themeApp.primaryColor),),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                subText('Pagos de clientes = $sumaPagosClientes', tamanioText),
                subText('Pagos de tutores = $sumaPagosTutores', tamanioText),
              ],
            ),
          ),

          //Codigo de servicio
          if(widget.dataloaded == true)
            Container(
              height: 30,
              width: 200,
              margin: const EdgeInsets.symmetric(vertical: 5.0),
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
                    interfazpagos = true;
                    selectedservicio = item.value;
                  });
                },
                onChanged: (text, reason) {
                  if (text.isEmpty ) {
                    setState(() {
                      selectedservicio = null; // Limpiar la selección cuando se borra el texto
                      interfazpagos = false;
                    });
                  }
                },
              ),
            ),
          if(interfazpagos)
            Column(
              children: [
                // tipo de pago ?,
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: verticalPadding),
                  child: AutoSuggestBox<String>(
                    items: tipodepagos.map((tipopago) {
                      return AutoSuggestBoxItem<String>(
                          value: tipopago,
                          label: tipopago,
                          onFocusChange: (focused) {
                            if (focused) {
                              debugPrint('Focused $tipopago');
                            }
                          }
                      );
                    }).toList(),
                    onSelected: (item) {
                      setState(() {
                        selectedtipopago = item.value!;
                        disabledbutton = false;
                      }
                      );

                    },
                    decoration: Disenos().decoracionbuscador(),
                    placeholder: 'Selecciona tu tipo pago',
                  ),
                ),
                //Valor de pago
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: verticalPadding),
                  child: TextBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    controller: _controllerpagos,
                    keyboardType: TextInputType.number,
                    placeholder: 'Valor de pago',
                    onChanged: (value) {
                      if (RegExp(r'^[0-9]*$').hasMatch(value)) {
                        setState(() {
                          valordepago = int.tryParse(value) ?? 0;
                        });
                      } else {
                        setState(() {
                          _controllerpagos.text = valordepago.toString();
                        });
                      }
                    },
                    maxLines: null,
                  ),
                ),
                //Cliente - nombre cliente
                if(selectedservicio!=null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: verticalPadding),
                    child: textopagoclientetutor(selectedservicio!.preciocobrado-sumaPagosClientes,selectedservicio!.preciotutor-sumaPagosTutores),
                  ),
                //metodo de pago
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: verticalPadding),
                  child: AutoSuggestBox<String>(
                    items: metodopagos.map((metodopago) {
                      return AutoSuggestBoxItem<String>(
                          value: metodopago,
                          label: metodopago,
                          onFocusChange: (focused) {
                            if (focused) {
                              debugPrint('Focused $metodopago');
                            }
                          }
                      );
                    }).toList(),
                    onSelected: (item) {
                      setState(() => selectedmetodopago = item.value!);
                    },
                    decoration: Disenos().decoracionbuscador(),
                    placeholder: 'Selecciona tu metodo de pago',
                  ),
                ),
                //Referencia
                RoundedTextField(
                  topMargin: verticalPadding,
                  bottomMargin: verticalPadding,
                  controller: _referenciaPagos,
                  placeholder: "Referencia"
                ),
                //fecha de pago
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: verticalPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DatePicker(
                        header: 'Seleccionar fecha de registro de pago',
                        selected: fecharegistropago,
                        showYear: false,
                        onChanged: (time){
                          setState((){
                            fecharegistropago = time.toUtc();
                          },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                //Seleccionar archivo de pago, aun no hay archivos
                Consumer<ConfiguracionAplicacion>(
                  builder: (context, condifuracionProvider, child) {
                    ConfiguracionPlugins? config = condifuracionProvider.config;
                    configuracionSolicitudes = Utiles().obtenerBool(config!.pagosDriveApiFecha);
                    idcarpetaPagosDrive = config.idcarpetaPagos;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: verticalPadding),
                      child: Column(
                        children: [
                          if(configuracionSolicitudes)
                          PrimaryStyleButton(
                            function: (){
                              selectFile();
                            },
                            text: "Registrar Pago"
                          ),
                        ],
                      ),
                    );
                  }
                ),
                //vista de archivos
                if(selectedFiles  != null)
                  Column(
                    children: selectedFiles!.map((file) {
                      return Container(
                        color: Colors.blue,
                        child: subText(file.name, 14),
                      );
                    }).toList(),
                  ),
                //Registrar pago
                PrimaryStyleButton(
                  buttonColor: themeApp.primaryColor,
                  function: disabledbutton ? (){} : ()async{
                    comprobacionpagos(selectedservicio!.preciocobrado-sumaPagosClientes,selectedservicio!.preciotutor-sumaPagosTutores);
                  },
                  text: "Registrar Pago",
                ),
              ],
            ),
        ],
      );
    }
  }

class ContainerPagosDashboard extends StatefulWidget{
  final double currentwidth;
  final bool dataloaded;
  final double currentheight;

  const ContainerPagosDashboard({
    Key?key,
    required this.currentwidth,
    required this.dataloaded,
    required this.currentheight,
  }) :super(key: key);

  @override
  ContainerPagosDashboardState createState() => ContainerPagosDashboardState();

}

class ContainerPagosDashboardState extends State<ContainerPagosDashboard> {

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

    const double radioButton = 30.0;
    const double horizontalPadding = 4.0;

    if(construct){
      return Consumer<ContabilidadProvider>(
        builder: (context, pagosProvider, child) {
          // Obtener la lista de pagos del provider
          List<RegistrarPago> pagosDelServicioSeleccionado = pagosProvider.pagosDelServicioSeleccionado;

          return ItemsCard(
            shadow: false,
            cardColor: themeApp.primaryColor,
            width: widget.currentwidth,
            height: widget.currentheight + 5.0,
            horizontalPadding: 15.0,
            verticalPadding: 12.0,
            children: [
              Text('Historial', style: themeApp.styleText(20, true, themeApp.whitecolor),),
              if (widget.dataloaded == true)
                Column(
                  children: [
                    SizedBox(
                      height: widget.currentheight-50,
                      child: ListView.builder(
                        itemCount: pagosDelServicioSeleccionado.length,
                        itemBuilder: (context, index) {
                          RegistrarPago registrarpago = pagosDelServicioSeleccionado[index];

                          return Card(
                            borderRadius: BorderRadius.circular(20),
                            backgroundColor: themeApp.whitecolor,
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                            margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
                            child: Column(
                              children: [
                                _textRow(registrarpago.id, registrarpago.tipopago, true),
                                _textRow("Valor Pago:", formatPrecio(registrarpago.valor as double), false),
                                _textRow("Fecha Pago:", formatFecha(registrarpago.fechapago), false),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      CircularButton(
                                        radio: radioButton,
                                        horizontalPadding: horizontalPadding,
                                        buttonColor: themeApp.primaryColor,
                                        iconData: material.Icons.remove_red_eye,
                                        function: (){

                                        },
                                      ),

                                      CircularButton(
                                        radio: radioButton,
                                        horizontalPadding: horizontalPadding,
                                        buttonColor: themeApp.primaryColor,
                                        iconData: material.Icons.create_rounded,
                                        function: (){

                                        },
                                      ),

                                      CircularButton(
                                        radio: radioButton,
                                        horizontalPadding: horizontalPadding,
                                        buttonColor: themeApp.redColor,
                                        iconData: material.Icons.clear,
                                        function: (){

                                        },
                                      ),

                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
            ],
          );
        },
      );
    }else{
      return const Center(child: material.CircularProgressIndicator(),);
    }
  }

  String formatPrecio(double precio) {
    NumberFormat formatoMoneda = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return formatoMoneda.format(precio);
  }

  String formatFecha(DateTime fecha) {
    DateFormat formatoFecha = DateFormat('yyyy-MM-dd');
    return formatoFecha.format(fecha);
  }
  
  Padding _textRow(String title, String text, bool encabezado){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title, style: themeApp.styleText(encabezado? 18: 16, true, encabezado? themeApp.primaryColor : themeApp.grayColor), textAlign: TextAlign.start,)),
          Expanded(child: Text(text, style: themeApp.styleText(encabezado? 18: 20, encabezado, encabezado? themeApp.primaryColor : themeApp.grayColor), textAlign: TextAlign.end,)),
        ],
      ),
    );
  }

}



