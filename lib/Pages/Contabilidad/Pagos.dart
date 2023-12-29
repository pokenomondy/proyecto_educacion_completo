import 'dart:convert';
import 'package:dashboard_admin_flutter/Objetos/RegistrarPago.dart';
import 'package:dashboard_admin_flutter/Utils/Drive%20Api/GoogleDrive.dart';
import 'package:dashboard_admin_flutter/Utils/Utiles/FuncionesUtiles.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/Uploads.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:googleapis/classroom/v1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Objetos/AgendadoServicio.dart';
import '../../Objetos/Configuracion/Configuracion_Configuracion.dart';
import '../../Providers/Providers.dart';
import '../../Utils/Disenos.dart';
import '../../Utils/Firebase/Load_Data.dart';
import '../../Utils/Firebase/StreamBuilders.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart' as material;

class ContablePagos extends StatefulWidget {

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
    final tamanowidthdobleComputador = (widthCompleto/2)-30;
    //tamaño para celular
    final tamanowidthdobleCelular = (widthCompleto/2);
    //currentheight completo
    final heightCompleto = MediaQuery.of(context).size.height-100;

    return Container(
      child: Column(
        children: [
          if(widthCompleto >= 1200)
            getVista(tamanowidthdobleComputador,heightCompleto),
          if(widthCompleto < 1200 && widthCompleto > 620)
            getVista(tamanowidthdobleComputador,heightCompleto),
          if(widthCompleto <= 620)
            getVista(tamanowidthdobleCelular,heightCompleto),
        ],
      ),
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
    String referenciapago = "";
    DateTime fecharegistropago = DateTime.now();
    Map<String, List<RegistrarPago>> pagosPorServicio = {};
    List<PlatformFile>? selectedFiles ;
    List<ServicioAgendado> servicioagendadList = [];
    bool cargandopagos = false;
    final TextEditingController _controllerpagos = TextEditingController(); //controller valor de pago
    bool interfazpagos = false;

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
                  Positioned.fill(
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
      await Uploads().addPago(selectedservicio!.idcontable, selectedservicio!, selectedtipopago, valordepago, referenciapago, fecharegistropago, selectedmetodopago,context);
      // Actualiza la lista de pagos por servicio
      if(configuracionSolicitudes){
        await DriveApiUsage().subirPago(idcarpetaPagosDrive, selectedFiles,referenciapago);
      }else{
      }
      //Borrar todas las variables anteriores
      setState(() {
        selectedFiles=null;
        selectedtipopago="";
        selectedmetodopago ="";
        referenciapago="null";
        valordepago=0;
        cargandopagos = false;
        _controllerpagos.text = "";
        interfazpagos = false;
      });
    }
  
    Text textopagoclientetutor(int debecliente,int debetutor){
      if(selectedtipopago=="CLIENTES"){
        if(debecliente!=0){
          return Text("El cliente debe ${selectedservicio!.preciocobrado-sumaPagosClientes+sumaPagosReembolsoCliente}");
        }else{
          return Text("TODO PAGO");
        }
      }else if(selectedtipopago =="TUTOR"){
        if(debetutor!=0){
          return Text("El tutor debe ${selectedservicio!.preciotutor-sumaPagosTutores+sumaPagosReembolsoTutores}");
        }else{
          return Text("TODO PAGO");
        }
      }else if(selectedtipopago =="CANCELADO"){
        if(sumaPagosClientes > 0 || sumaPagosTutores > 0){
          setState(() {
            disabledbutton = true;
          });
          return Text('No se puede cancelar,hay pagos');
        }else{
          return Text("SE PUEDE CANCELAR ${selectedservicio!.idcontable}");
        }
      }else if(selectedtipopago =="REEMBOLSOCLIENTE"){
        if(sumaPagosClientes-sumaPagosReembolsoCliente==0){
          setState(() {
            disabledbutton = true;
          });
          return Text('No se puede reembolsar saldo,el saldo es 0');
        }else{
          return Text('Se puede reembolsar ${sumaPagosClientes-sumaPagosReembolsoCliente}');
        }
      }else if(selectedtipopago=="REEMBOLSOTUTOR"){
        if(sumaPagosTutores-sumaPagosReembolsoTutores==0){
          setState(() {
            disabledbutton = true;
          });
          return Text('No se puede reembolsar saldo,el saldo es 0');
        }else{
          return Text('SE PUEDEN REEMBOLSAR ${sumaPagosTutores-sumaPagosReembolsoTutores}');
        }
      }else{
        return Text('Seleccione el tipo de pago a revisar');
      }
    }

    Widget cuadroPagos(List<ServicioAgendado> serviciosAgendadosList){
      return Container(
        color: Colors.red,
        width: widget.currentwidth,
        height: widget.currentheight,
        child:Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Column(
                children: [
                  Text('Pagos de clientes = $sumaPagosClientes'),
                  Text('Pagos de tutores = $sumaPagosTutores'),
                ],
              ),
              //Codigo de servicio
              if(widget.dataloaded == true)
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
                    AutoSuggestBox<String>(
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
                    //Valor de pago
                    TextBox(
                      controller: _controllerpagos,
                      keyboardType: TextInputType.number,
                      placeholder: 'Valor de pago',
                      onChanged: (value) {
                        // Utilizar una expresión regular para permitir solo números
                        if (RegExp(r'^[0-9]*$').hasMatch(value)) {
                          setState(() {
                            // Convertir el valor a entero
                            valordepago = int.tryParse(value) ?? 0;
                          });
                        } else {
                          // Si se ingresa un valor no numérico, limpiar el campo
                          setState(() {
                            _controllerpagos.text = valordepago.toString();
                          });
                        }
                      },
                      maxLines: null,
                    ),
                    //Cliente - nombre cliente
                    if(selectedservicio!=null)
                      Column(
                        children: [
                          textopagoclientetutor(selectedservicio!.preciocobrado-sumaPagosClientes,selectedservicio!.preciotutor-sumaPagosTutores),
                        ],
                      ),
                    //metodo de pago
                    AutoSuggestBox<String>(
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
                    //Referencia
                    TextBox(
                      placeholder: 'Referencia',
                      onChanged: (value){
                        setState(() {
                          referenciapago = value;
                        });
                      },
                      maxLines: null,
                    ),
                    //fecha de pago
                    Row(
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
                    //Seleccionar archivo de pago, aun no hay archivos
                    Consumer<ConfiguracionAplicacion>(
                      builder: (context, condifuracionProvider, child) {
                        ConfiguracionPlugins? config = condifuracionProvider.config;
                        configuracionSolicitudes = Utiles().obtenerBool(config!.PagosDriveApiFecha);
                        idcarpetaPagosDrive = config.idcarpetaPagos;

                        return Column(
                          children: [
                            if(configuracionSolicitudes)
                            FilledButton(child: Text('Seleccionar archivos'), onPressed: (){
                              selectFile();
                            }),
                          ],
                        );
                      }
                    ),
                    //vista de archivos
                    if(selectedFiles  != null)
                      Column(
                        children: selectedFiles!.map((file) {
                          return Container(
                            color: Colors.blue,
                            child: Text(file.name),
                          );
                        }).toList(),
                      ),
                    //Registrar pago
                    FilledButton(
                        child: Text('Registrar pago'),
                        onPressed: disabledbutton ? null : ()async{
                          comprobacionpagos(selectedservicio!.preciocobrado-sumaPagosClientes,selectedservicio!.preciotutor-sumaPagosTutores);

                        }),
                  ],
                ),
            ],
          ),
        ),
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

  @override
  Widget build(BuildContext context) {
    return Consumer<ContabilidadProvider>(
      builder: (context, pagosProvider, child) {
        // Obtener la lista de pagos del provider
        List<RegistrarPago> pagosDelServicioSeleccionado = pagosProvider.pagosDelServicioSeleccionado;

        return Container(
          color: Colors.green,
          width: widget.currentwidth,
          height: widget.currentheight,
          child: Column(
            children: [
              Text('Aquí tenemos historial'),
              if (widget.dataloaded == true)
                Column(
                  children: [
                    Container(
                      height: widget.currentheight-20,
                      child: ListView.builder(
                        itemCount: pagosDelServicioSeleccionado.length,
                        itemBuilder: (context, index) {
                          RegistrarPago registrarpago = pagosDelServicioSeleccionado[index];

                          return Container(
                            height: 100,
                            child: Card(
                              child: Column(
                                children: [
                                  Text(registrarpago.id),
                                  Text(registrarpago.valor.toString()),
                                  Text(registrarpago.tipopago),
                                  Text("${registrarpago.fechapago.month}-${registrarpago.fechapago.day}")
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
      },
    );
  }
}



