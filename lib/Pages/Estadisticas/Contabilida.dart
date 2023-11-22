import 'dart:typed_data';
import 'dart:convert';
import 'dart:html';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as cloud;
import 'package:dashboard_admin_flutter/Objetos/Solicitud.dart';
import 'package:excel/excel.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../../Objetos/AgendadoServicio.dart';
import '../../Objetos/RegistrarPago.dart';
import '../../Utils/Firebase/Load_Data.dart';
import '../../Utils/Firebase/StreamBuilders.dart';

//Servicios agendados Data Source
class CrearContabilidad extends StatefulWidget{

  @override
  _CrearContainerState createState() => _CrearContainerState();

}

class _CrearContainerState extends State<CrearContabilidad> {
  List<ServicioAgendado> serviciosagendadosList = [];
  bool carguelistas = false;

  @override
  void initState() {
    loadDataTablasMaterias();
    super.initState();
  }

  Future<void> loadDataTablasMaterias() async {
    serviciosagendadosList = (await stream_builders().cargarserviciosagendados())!;
    setState(() {
      carguelistas = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentwidth = MediaQuery.of(context).size.width;
    final currentHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        FilledButton(child: Text('Descargar tabla'), onPressed: (){
          exportDataGridToExcel();
        }),
        Container(
          width: currentwidth,
          height: currentHeight-150 ,
          child: SfDataGrid(
            source: ServicioAgendadoDataSource(servicioAgendadoData: serviciosagendadosList),
            allowSorting: true,
            allowFiltering: true,
            columnWidthMode: ColumnWidthMode.fill,
            columns: getcolumns(),
          ),
        ),
      ],
      );


  }

  List<GridColumn> getcolumns(){
    return <GridColumn>[
      GridColumn(
          columnName: 'codigo',
          label: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'codigo',
              ))),
      GridColumn(
          columnName: 'sistema',
          label: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'sistema',
              ))),
      GridColumn(
          columnName: 'idcontable',
          label: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'idcontable',
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
          columnName: 'fechasistema',
          label: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'fechasistema',
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
          columnName: 'fechaentrega',
          label: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'fechaentrega',
              ))),
      GridColumn(
          columnName: 'tutor',
          label: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'tutor',
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
          columnName: 'ID SOL',
          label: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'idsolicitud',
              ))),

    ];
  }

  Future<void> exportDataGridToExcel() async {
    final Excel excel = Excel.createExcel();
    final Sheet sheet = excel['Contabilidad']; // Nombre de la hoja

    // Agrega encabezados
    final headers = [
      'codigo',
      'sistema',
      'idcontable',
      'materia',
      'fechasistema',
      'cliente',
      'preciocobrado',
      'fechaentrega',
      'tutor',
      'preciotutor',
      'idsolicitud',
    ];
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).value = headers[i];
    }

    // Agrega datos
    for (var i = 0; i < serviciosagendadosList.length; i++) {
      final servicio = serviciosagendadosList[i];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1)).value = servicio.codigo;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1)).value = servicio.sistema;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1)).value = servicio.idcontable;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1)).value = servicio.materia;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1)).value = DateFormat('dd/MM/yyyy').format(servicio.fechasistema);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1)).value = servicio.cliente;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: i + 1)).value = servicio.preciocobrado;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: i + 1)).value = DateFormat('dd/MM/yyyy').format(servicio.fechaentrega);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: i + 1)).value = servicio.tutor;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: i + 1)).value = servicio.preciotutor;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: i + 1)).value = servicio.idsolicitud;

    }

    // Obtiene el archivo Excel como bytes
    final excelFile = await excel.encode();

    // Convierte los bytes a una lista de enteros sin signo (Uint8List)
    final excelBytes = Uint8List.fromList(excelFile!);

    // Crea un objeto Blob a partir de los bytes
    final blob = Blob([Uint8List.fromList(excelBytes)]);

    // Crea una URL para el Blob
    final url = Url.createObjectUrlFromBlob(blob);

    // Crea un enlace (anchor) para descargar el archivo
    final anchor = AnchorElement(href: url)
      ..target = 'a'
      ..download = 'Contabilidad${DateTime.now()}.xlsx'; // Nombre del archivo que deseas

    // Simula un clic en el enlace para iniciar la descarga
    anchor.click();

    // Revoca la URL para liberar recursos
    Url.revokeObjectUrl(url);
  }
}

class ServicioAgendadoDataSource extends DataGridSource {
  ServicioAgendadoDataSource({required List<ServicioAgendado> servicioAgendadoData}) {
    _servicioAgendadoData = servicioAgendadoData
        .map<DataGridRow>((e) => DataGridRow(cells: [
      DataGridCell<String>(columnName: 'codigo', value: e.codigo),
      DataGridCell<String>(columnName: 'sistema', value: e.sistema),
      DataGridCell<int>(columnName: 'idcontable ', value: e.idcontable),
      DataGridCell<String>(columnName: 'materia', value: e.materia),
      DataGridCell<DateTime>(columnName: 'fechasistema', value: e.fechasistema),
      DataGridCell<String>(columnName: 'cliente', value: e.cliente),
      DataGridCell<int>(columnName: 'preciocobrado', value: e.preciocobrado),
      DataGridCell<DateTime>(columnName: 'fechaentrega', value: e.fechaentrega),
      DataGridCell<String>(columnName: 'tutor', value: e.tutor),
      DataGridCell<int>(columnName: 'preciotutor', value: e.preciotutor),
      DataGridCell<String>(columnName: 'identificadorcodigo', value: e.identificadorcodigo),


    ]))
        .toList();
  }

  List<DataGridRow> _servicioAgendadoData = [];

  @override
  List<DataGridRow> get rows => _servicioAgendadoData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
          return Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(8.0),
            child: Text(e.value.toString()),
          );
        }).toList());
  }
}

//Solicitudes Data source
class CrearSolciitudes extends StatefulWidget{

  @override
  _CrearSolicitudesState createState() => _CrearSolicitudesState();

}

class _CrearSolicitudesState extends State<CrearSolciitudes> {
  List<Solicitud> solicitudesList = [];
  bool carguelistas = false;

  @override
  void initState() {
    loadDataTablasMaterias();
    super.initState();
  }

  Future<void> loadDataTablasMaterias() async {
    solicitudesList = await LoadData().obtenerSolicitudes();
    setState(() {
      carguelistas = true;
    });
  }


  @override
  Widget build(BuildContext context) {
    final currentwidth = MediaQuery.of(context).size.width;
    final currentHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        FilledButton(child: Text('Descargar tabla'), onPressed: (){
          exportDataGridToExcel();
        }),
        Container(
          width: currentwidth,
          height: currentHeight-150,
          child: SfDataGrid(
            source: SolicitudesDataSource(servicioAgendadoData: solicitudesList),
            allowSorting: true,
            allowFiltering: true,
            columnWidthMode: ColumnWidthMode.fill,
            columns: getcolumns(),
          ),
        ),
      ],
    );
  }

  List<GridColumn> getcolumns(){
    return <GridColumn>[
      GridColumn(
          columnName: 'ID',
          label: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'ID',
              ))),
      GridColumn(
          columnName: 'Matería',
          label: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'Matería',
              ))),
      GridColumn(
          columnName: 'Servicio',
          label: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'Servicio',
              ))),
      GridColumn(
          columnName: 'fechaentrega',
          label: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'fechaentrega',
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
          columnName: 'fechasistema',
          label: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'fechasistema',
              ))),
      GridColumn(
          columnName: 'Estado',
          label: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'Estado',
              ))),
      GridColumn(
          columnName: 'resumen',
          label: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'resumen',
              ))),
      GridColumn(
          columnName: 'infocliente',
          label: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'infocliente',
              ))),
      GridColumn(
          columnName: 'urlarchivos',
          label: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'URL',
              ))),
    ];
  }

  Future<void> exportDataGridToExcel() async {
    final Excel excel = Excel.createExcel();
    final Sheet sheet = excel['Solicitudes']; // Nombre de la hoja

    // Agrega encabezados
    final headers = [
      'ID',
      'Materia',
      'Tipo servicio',
      'fecha entrega',
      'cliente',
      'fecha sistema',
      'estado',
      'resumen',
      'info cliente',
      'URL',
    ];
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).value = headers[i];
    }

    // Agrega datos
    for (var i = 0; i < solicitudesList.length; i++) {
      final solicitud = solicitudesList[i];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1)).value = solicitud.idcotizacion;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1)).value = solicitud.materia;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1)).value = solicitud.servicio;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1)).value = solicitud.fechaentrega;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1)).value = solicitud.cliente;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1)).value = solicitud.fechasistema;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: i + 1)).value = solicitud.estado;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: i + 1)).value = solicitud.resumen;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: i + 1)).value = solicitud.infocliente;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: i + 1)).value = solicitud.urlArchivos;

    }

    // Obtiene el archivo Excel como bytes
    final excelFile = await excel.encode();

    // Convierte los bytes a una lista de enteros sin signo (Uint8List)
    final excelBytes = Uint8List.fromList(excelFile!);

    // Crea un objeto Blob a partir de los bytes
    final blob = Blob([Uint8List.fromList(excelBytes)]);

    // Crea una URL para el Blob
    final url = Url.createObjectUrlFromBlob(blob);

    // Crea un enlace (anchor) para descargar el archivo
    final anchor = AnchorElement(href: url)
      ..target = 'a'
      ..download = 'Solicitudes${DateTime.now()}.xlsx'; // Nombre del archivo que deseas

    // Simula un clic en el enlace para iniciar la descarga
    anchor.click();

    // Revoca la URL para liberar recursos
    Url.revokeObjectUrl(url);
  }

}

class SolicitudesDataSource extends DataGridSource {
  SolicitudesDataSource({required List<Solicitud> servicioAgendadoData}) {
    _servicioAgendadoData = servicioAgendadoData
        .map<DataGridRow>((e) => DataGridRow(cells: [
      DataGridCell<int>(columnName: 'idcotizacion', value: e.idcotizacion),
      DataGridCell<String>(columnName: 'materia', value: e.materia),
      DataGridCell<String>(columnName: 'Servicio', value: e.servicio),
      DataGridCell<DateTime>(columnName: 'fechaentrega', value: e.fechaentrega),
      DataGridCell<int>(columnName: 'cliente', value: e.cliente),
      DataGridCell<DateTime>(columnName: 'fechasistema', value: e.fechasistema),
      DataGridCell<String>(columnName: 'Estado', value: e.estado),
      DataGridCell<String>(columnName: 'resumen', value: e.resumen),
      DataGridCell<String>(columnName: 'infocliente', value: e.infocliente),
      DataGridCell<String>(columnName: 'urlarchivos', value: e.urlArchivos),
      //Falta poner la lista de cotizaciones, podría ser interesante

    ]))
        .toList();
  }

  List<DataGridRow> _servicioAgendadoData = [];

  @override
  List<DataGridRow> get rows => _servicioAgendadoData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
          return Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(8.0),
            child: Text(e.value.toString()),
          );
        }).toList());
  }
}

//Pagos
class PagosDatos extends StatefulWidget{

  @override
  _PagosDatosState createState() => _PagosDatosState();

}

class _PagosDatosState extends State<PagosDatos> {
  List<ServicioAgendado> contabilidadList = [];
  List<RegistrarPago> pagosList = [];
  bool carguelistas = false;

  @override
  void initState() {
    loadpagos();
    super.initState();
  }

  Future<void> loadpagos() async {
    contabilidadList = (await stream_builders().cargarserviciosagendados())!;
// Recorre la lista de contabilidadList
    contabilidadList.forEach((servicioAgendado) {
      print(servicioAgendado.codigo);
      pagosList.addAll(servicioAgendado.pagos);
    });
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    final currentwidth = MediaQuery.of(context).size.width;
    final currentHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        FilledButton(child: Text('Descargar tabla'), onPressed: (){
          exportDataGridToExcel();
        }),

        Container(
          width: currentwidth,
          height: currentHeight-150,
          child: SfDataGrid(
            source: PagosDataSource(RegistrarPagoData: pagosList),
            allowSorting: true,
            allowFiltering: true,
            columnWidthMode: ColumnWidthMode.fill,
            columns: getcolumns(),
          ),
        ),
      ],
    );
  }

  List<GridColumn> getcolumns(){
    return <GridColumn>[
      GridColumn(
          columnName: 'id',
          label: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'id',
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
          columnName: 'tipopago',
          label: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'tipopago',
              ))),
      GridColumn(
          columnName: 'valor',
          label: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'valor',
              ))),
      GridColumn(
          columnName: 'metodopago',
          label: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'metodopago',
              ))),
      GridColumn(
          columnName: 'referencia',
          label: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'referencia',
              ))),
      GridColumn(
          columnName: 'fechapago',
          label: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'fechapago',
              ))),
      GridColumn(
          columnName: 'fecharegistro',
          label: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'fecharegistro',
              ))),
    ];
  }

  Future<void> exportDataGridToExcel() async {
    final Excel excel = Excel.createExcel();
    final Sheet sheet = excel['PAGOS']; // Nombre de la hoja

    // Agrega encabezados
    final headers = [
      'ID',
      'CODIGO',
      'TUTOR/CLIENTE',
      'VALOR',
      'METODO PAGO',
      'REFERENCIA',
      'FECHA PAGO',
      'FECHA REGISTRO',
    ];
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).value = headers[i];
    }

    // Agrega datos
    for (var i = 0; i < pagosList.length; i++) {
      final solicitud = pagosList[i];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1)).value = solicitud.id;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1)).value = solicitud.codigo;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1)).value = solicitud.tipopago;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1)).value = solicitud.valor;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1)).value = solicitud.metodopago;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1)).value = solicitud.referencia;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: i + 1)).value = DateFormat('dd/MM/yyyy').format(solicitud.fechapago);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: i + 1)).value = DateFormat('dd/MM/yyyy').format(solicitud.fecharegistro);

    }

    // Obtiene el archivo Excel como bytes
    final excelFile = await excel.encode();

    // Convierte los bytes a una lista de enteros sin signo (Uint8List)
    final excelBytes = Uint8List.fromList(excelFile!);

    // Crea un objeto Blob a partir de los bytes
    final blob = Blob([Uint8List.fromList(excelBytes)]);

    // Crea una URL para el Blob
    final url = Url.createObjectUrlFromBlob(blob);

    // Crea un enlace (anchor) para descargar el archivo
    final anchor = AnchorElement(href: url)
      ..target = 'a'
      ..download = 'Pagos${DateTime.now()}.xlsx'; // Nombre del archivo que deseas

    // Simula un clic en el enlace para iniciar la descarga
    anchor.click();

    // Revoca la URL para liberar recursos
    Url.revokeObjectUrl(url);
  }

}

class PagosDataSource extends DataGridSource {
  PagosDataSource({required List<RegistrarPago> RegistrarPagoData}) {
    _servicioAgendadoData = RegistrarPagoData
        .map<DataGridRow>((e) => DataGridRow(cells: [
      DataGridCell<String>(columnName: 'id', value: e.id),
      DataGridCell<String>(columnName: 'codigo', value: e.codigo),
      DataGridCell<String>(columnName: 'tipopago', value: e.tipopago),
      DataGridCell<int>(columnName: 'valor', value: e.valor),
      DataGridCell<String>(columnName: 'metodopago', value: e.metodopago),
      DataGridCell<String>(columnName: 'referencia', value: e.referencia),
      DataGridCell<DateTime>(columnName: 'fechapago', value: e.fechapago),
      DataGridCell<DateTime>(columnName: 'fecharegistro', value: e.fecharegistro),

      //Falta poner la lista de cotizaciones, podría ser interesante

    ]))
        .toList();
  }

  List<DataGridRow> _servicioAgendadoData = [];

  @override
  List<DataGridRow> get rows => _servicioAgendadoData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
          return Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(8.0),
            child: Text(e.value.toString()),
          );
        }).toList());
  }
}




