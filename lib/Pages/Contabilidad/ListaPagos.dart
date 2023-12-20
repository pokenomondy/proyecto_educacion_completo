import 'package:dashboard_admin_flutter/Utils/Firebase/StreamBuilders.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';
import '../../Objetos/AgendadoServicio.dart';
import '../../Objetos/Objetos Auxiliares/OrganizadorPagos.dart';
import '../Estadisticas/Contabilida.dart';

class ListaPagosDash extends StatefulWidget {

  @override
  ListaPagosDashState createState() => ListaPagosDashState();

}

class ListaPagosDashState extends State<ListaPagosDash> {

  @override
  Widget build(BuildContext context) {
    final currentwidth = MediaQuery.of(context).size.width;
    final tamanowidth = (currentwidth/2)-30;
    return Container(
      child: Row(
        children: [
          PrimaryListaPagosDash(),
        ],
      ),
    );
  }
}

class PrimaryListaPagosDash extends StatefulWidget {

  @override
  PrimaryListaPagosDashState createState() => PrimaryListaPagosDashState();

}

class PrimaryListaPagosDashState extends State<PrimaryListaPagosDash> {
  String motivopagos = "";
  List<ServicioAgendado> serviciosAgendadoList = [];
  bool dataLoaded = false;

  @override
  void initState() {
    loadDataTablasMaterias(); // Cargar los datos al inicializar el widget
    super.initState();
  }

  Future<void> loadDataTablasMaterias() async {
    //serviciosAgendadoList = (await stream_builders().cargarserviciosagendados())!;
    setState(() {
      dataLoaded=true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentwidth = MediaQuery.of(context).size.width;
    final currentHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Row(
          children: [
            FilledButton(child: Text('PAGOS CLIENTES'), onPressed: (){
              motivopagos = "CLIENTES";
            }),
            FilledButton(child: Text('PAGOS TUTORES'), onPressed: (){
              motivopagos = "TUTORES";
            }),
          ],
        ),
        if(dataLoaded==true)
          //Contabilidad state
          Container(
            width: currentwidth-100,
            height: currentHeight-300 ,
            child: SfDataGrid(
              source: ServicioDataSourceModifiqued(servicioAgendadoData: serviciosAgendadoList),
              allowSorting: true,
              allowFiltering: true,
              columnWidthMode: ColumnWidthMode.fitByCellValue,
              columns: getcolumns(),
            ),
          ),
      ],
    );
  }

  List<GridColumn> getcolumns(){
    return <GridColumn>[
      GridColumn(
          columnName: 'fechaentrega',
          label: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'fechaentrega',
              ))),
      GridColumn(
          columnName: 'codigo',
          label: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'codigo',
              ))),
      GridColumn(
          columnName: 'materia',
          label: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'materia',
              ))),
      GridColumn(
          columnName: 'cliente',
          label: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'cliente',
              ))),
      GridColumn(
          columnName: 'preciocobrado',
          label: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'preciocobrado',
              ))),
      GridColumn(
          columnName: 'PAGOCLIENTE',
          label: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'PAGOCLIENTE',
              ))),
      GridColumn(
          columnName: 'preciotutor',
          label: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'preciotutor',
              ))),
      GridColumn(
          columnName: 'PAGOTUTOR',
          label: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'PAGOTUTOR',
              ))),
    ];
  }

}

class ServicioDataSourceModifiqued extends DataGridSource {
  final List<ServicioAgendado> servicioAgendadoData;

  ServicioDataSourceModifiqued({required this.servicioAgendadoData}) {
    _servicioAgendadoData = servicioAgendadoData
        .where((servicio) => servicio.fechaentrega.isAfter(DateTime.now().subtract(Duration(days: 31))) && servicio.fechaentrega.isBefore(DateTime.now().add(Duration(days: 1))))
        .map<DataGridRow>((e) =>
        DataGridRow(cells: [
          DataGridCell<DateTime>(columnName: 'fechaentrega', value:  e.fechaentrega),
          DataGridCell<String>(columnName: 'codigo', value: e.codigo),
          DataGridCell<String>(columnName: 'materia', value: e.materia),
          DataGridCell<String>(columnName: 'cliente', value: e.cliente),
          DataGridCell<int>(columnName: 'preciocobrado', value: e.preciocobrado),
          DataGridCell<String>(columnName: 'PAGOCLIENTE', value: calculoDebeCliente(e.codigo, e.preciocobrado)),
          DataGridCell<int>(columnName: 'preciotutor', value: e.preciotutor),
          DataGridCell<String>(columnName: 'PAGOTUTOR', value: calculoDebeTutor(e.codigo, e.preciotutor)),

        ]))
        .toList();
  }

  List<DataGridRow> _servicioAgendadoData = [];
  int sumaPagosClientes = 0;
  int sumaPagosTutores = 0;
  int sumaPagosReembolsoCliente = 0;
  int sumaPagosReembolsoTutores = 0;


  String calculoDebeCliente(String codigo, int preciocobrado) {
    print("actualizando pagos");
    sumaPagosClientes = servicioAgendadoData
        .where((servicio) => servicio.codigo == codigo)
        .map((servicio) => servicio.pagos)
        .expand((pagos) => pagos)
        .where((pago) => pago.tipopago == 'CLIENTES')
        .fold(0, (prev, pago) => prev + pago.valor);
    sumaPagosReembolsoCliente = servicioAgendadoData
        .where((servicio) => servicio.codigo == codigo)
        .map((servicio) => servicio.pagos)
        .expand((pagos) => pagos)
        .where((pago) => pago.tipopago == 'REEMBOLSOCLIENTE')
        .fold(0, (prev, pago) => prev + pago.valor);


    int DEBECLIENTE = preciocobrado - sumaPagosClientes +
        sumaPagosReembolsoCliente;

    return "DEBE $DEBECLIENTE";
  }

  String calculoDebeTutor(String codigo, int preciotutor) {
    print("actualizando pagos");
    sumaPagosTutores = servicioAgendadoData
        .where((servicio) => servicio.codigo == codigo)
        .map((servicio) => servicio.pagos)
        .expand((pagos) => pagos)
        .where((pago) => pago.tipopago == 'TUTOR')
        .fold(0, (prev, pago) => prev + pago.valor);
    sumaPagosReembolsoTutores = servicioAgendadoData
        .where((servicio) => servicio.codigo == codigo)
        .map((servicio) => servicio.pagos)
        .expand((pagos) => pagos)
        .where((pago) => pago.tipopago == 'REEMBOLSOTUTOR')
        .fold(0, (prev, pago) => prev + pago.valor);

    int DEBETUTOR = preciotutor - sumaPagosTutores + sumaPagosReembolsoTutores;

    return "DEBE $DEBETUTOR";
  }


  @override
  List<DataGridRow> get rows => _servicioAgendadoData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
          return GestureDetector(
            child: Container(
              color: obtenercolor(dataGridCell),
              alignment: Alignment.center,
              padding: EdgeInsets.all(8.0),
              child:   Text(dataGridCell.value.toString()),
            ),onTap: (){
            Clipboard.setData(ClipboardData(text: dataGridCell.value.toString()));
          },
          );
        }).toList());
  }

  material.Color obtenercolor(DataGridCell<dynamic> dataGridCell){
    if(dataGridCell.columnName == "PAGOCLIENTE" || dataGridCell.columnName == "PAGOTUTOR"){
      if(dataGridCell.value != "DEBE 0"){
        return material.Colors.red;
      }else
        return material.Colors.green;
    }else{
      if(dataGridCell.value is DateTime){
        DateTime fecha = dataGridCell.value;
        if (fecha.day % 2 == 0) {
        return material.Colors.blue;
        } else {
        return material.Colors.orange;
        }
      }else{
        return material.Colors.white;
    }
    }
  }

}
