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
import '../../Utils/Disenos.dart';
import '../../Utils/Firebase/Load_Data.dart';
import '../../Utils/Firebase/StreamBuilders.dart';
import 'package:provider/provider.dart';


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
  final GlobalKey<_ContainerPagosDashboardState> dashboardKey = GlobalKey<_ContainerPagosDashboardState>();
  final GlobalKey<_ContainerPagosState> registrarpago = GlobalKey<_ContainerPagosState>();



  @override
  void initState() {
    loadTablaTutores(); // Cargar los datos al inicializar el widget
    super.initState();
  }


  Future<void> loadTablaTutores() async {
    servicioagendadList = (await stream_builders().cargarserviciosagendados())!;
    setState(() {
      dataloaded = true;
    });
  }


  @override
  Widget build(BuildContext context) {
    final currentwidth = MediaQuery.of(context).size.width;
    final tamanowidth = (currentwidth/2)-30;
    return Container(
      child: Row(
        children: [
          _ContainerPagos(currentwidth: tamanowidth,dataloaded: dataloaded,servicioagendadList: servicioagendadList,key: registrarpago),
          _ContainerPagosDashboard(currentwidth: tamanowidth,servicioagendadList: servicioagendadList,dataloaded: dataloaded,selectedCodigo: selectedCodigo,key: dashboardKey,),
        ],
      ),
    );
  }
}

class _ContainerPagos extends StatefulWidget{
  final double currentwidth;
  final bool dataloaded;
  final List<ServicioAgendado> servicioagendadList;



  const _ContainerPagos({Key?key,
    required this.currentwidth,
    required this.dataloaded,
    required this.servicioagendadList,
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
  
    // Utiliza fold para sumar los pagos con tipoPago 'CLIENTES'
    int sumaPagosClientes = 0;
    int sumaPagosTutores = 0;
    int sumaPagosReembolsoCliente = 0;
    int sumaPagosReembolsoTutores = 0;
    bool disabledbutton = false;
    List<PlatformFile>? selectedFiles ;
    List<ServicioAgendado> servicioagendadList = [];
  
  
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

    Future actualizarpagosporcodigo(String codigo) async{
      print("actualiamos pago por codigo");
      servicioagendadList.clear;
      servicioagendadList = (await stream_builders().cargarserviciosagendados())!;
      final pagosProvider = Provider.of<RegistrarPagosProvider>(context, listen: false);
      // Actualizar todos los pagos en el provider
      pagosProvider.clearPagos();
      pagosProvider.cargarTodosLosPagos(servicioagendadList.expand((servicio) => servicio.pagos).toList());
      // Actualizar los pagos según el código seleccionado
      pagosProvider.actualizarPagosPorCodigo(codigo);
      actualizarpagos(servicioagendadList);
    }

    void actualizarpagos(List<ServicioAgendado> servicioagendadListxx) {
      print("actualizando pagos");
      sumaPagosClientes = servicioagendadListxx
          .where((servicio) => servicio.codigo == selectedservicio!.codigo)
          .map((servicio) => servicio.pagos)
          .expand((pagos) => pagos)
          .where((pago) => pago.tipopago == 'CLIENTES')
          .fold(0, (prev, pago) => prev + pago.valor);
      sumaPagosTutores = servicioagendadListxx
          .where((servicio) => servicio.codigo == selectedservicio!.codigo)
          .map((servicio) => servicio.pagos)
          .expand((pagos) => pagos)
          .where((pago) => pago.tipopago == 'TUTOR')
          .fold(0, (prev, pago) => prev + pago.valor);
      sumaPagosReembolsoCliente = servicioagendadListxx
          .where((servicio) => servicio.codigo == selectedservicio!.codigo)
          .map((servicio) => servicio.pagos)
          .expand((pagos) => pagos)
          .where((pago) => pago.tipopago == 'REEMBOLSOCLIENTE')
          .fold(0, (prev, pago) => prev + pago.valor);
      sumaPagosReembolsoTutores = servicioagendadListxx
          .where((servicio) => servicio.codigo == selectedservicio!.codigo)
          .map((servicio) => servicio.pagos)
          .expand((pagos) => pagos)
          .where((pago) => pago.tipopago == 'REEMBOLSOTUTOR')
          .fold(0, (prev, pago) => prev + pago.valor);
    }
  
    @override
    Widget build(BuildContext context) {
      return Container(
        color: Colors.red,
        width: widget.currentwidth,
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
                    items: widget.servicioagendadList.map<AutoSuggestBoxItem<ServicioAgendado>>(
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
                        selectedservicio = item.value;
                        actualizarpagosporcodigo(selectedservicio!.codigo);
                        print("servicio seleccionado ${selectedservicio!.codigo}");
                        print("calcular pagos");
                      });
                    },
                    onChanged: (text, reason) {
                      if (text.isEmpty ) {
                        setState(() {
                          selectedservicio = null; // Limpiar la selección cuando se borra el texto
                        });
                      }
                    },
                  ),
                ),
              if(selectedservicio!=null)
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
                    placeholder: 'Valor de pago',
                    onChanged: (value){
                      setState(() {
                        valordepago = int.parse(value);
                      });
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
                    placeholder: 'Selecciona tu tipo pago',
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
                  FilledButton(child: Text('Seleccionar archivos'), onPressed: (){
                    selectFile();
                  }),
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
      await Uploads().addPago(selectedservicio!.idcontable, selectedservicio!, selectedtipopago, valordepago, referenciapago, fecharegistropago, selectedmetodopago,context);
      print("Registrar nuevo pago");
      // Actualiza la lista de pagos por servicio
      await DriveApiUsage().subirPago('1HVgOvC-Jg8f5d-KE_m9hffKRZHJYy33N', selectedFiles,referenciapago);
      actualizarpagosporcodigo(selectedservicio!.codigo);
      //Borrar todas las variables anteriores
      setState(() {
        selectedservicio=null;
        selectedFiles=null;
        selectedtipopago="";
        selectedmetodopago ="";
        referenciapago="null";
        valordepago=0;
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
          return Text('SE PUEDEN REEMBOLSAR XXXX');
        }
      }else{
        return Text('Seleccione el tipo de pago a revisar');
      }
    }
  }

class _ContainerPagosDashboard extends StatefulWidget{
  final double currentwidth;
  final bool dataloaded;
  final List<ServicioAgendado> servicioagendadList;
  final String selectedCodigo;

  const _ContainerPagosDashboard({
    Key?key,
    required this.currentwidth,
    required this.dataloaded,
    required this.servicioagendadList,
    required this.selectedCodigo,
  }) :super(key: key);

  @override
  _ContainerPagosDashboardState createState() => _ContainerPagosDashboardState();

}

class _ContainerPagosDashboardState extends State<_ContainerPagosDashboard> {


  @override
  Widget build(BuildContext context) {
    return Consumer<RegistrarPagosProvider>(
      builder: (context, pagosProvider, child) {
        // Obtener la lista de pagos del provider
        List<RegistrarPago> pagosDelServicioSeleccionado = pagosProvider.pagosDelServicioSeleccionado;

        return Container(
          color: Colors.green,
          width: widget.currentwidth,
          child: Column(
            children: [
              Text('Aquí tenemos historial'),
              if (widget.dataloaded == true)
                Column(
                  children: [
                    Container(
                      height: 800,
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

class RegistrarPagosProvider extends ChangeNotifier {
  List<RegistrarPago> _todosLosPagos = [];
  List<RegistrarPago> _pagosDelServicioSeleccionado = [];

  List<RegistrarPago> get pagosDelServicioSeleccionado => _pagosDelServicioSeleccionado;

  void cargarTodosLosPagos(List<RegistrarPago> pagos) {
    _todosLosPagos = pagos;
    actualizarPagosPorCodigo(""); // Inicialmente, cargamos todos los pagos
  }

  void actualizarPagosPorCodigo(String codigo) {
    // Filtra los pagos según el código seleccionado y actualiza la lista
    _pagosDelServicioSeleccionado = _todosLosPagos
        .where((pago) => pago.codigo == codigo)
        .toList();
    notifyListeners();
  }

  // Método para eliminar todas las pagos
  void clearPagos() {
    _todosLosPagos.clear();
    _pagosDelServicioSeleccionado.clear();
    pagosDelServicioSeleccionado.clear();
    notifyListeners();
  }

}



