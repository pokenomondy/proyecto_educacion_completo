import 'package:dashboard_admin_flutter/Utils/EnviarMensajesWhataspp.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:googleapis/cloudsearch/v1.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:whatsapp/whatsapp.dart';
import '../../Config/Config.dart';
import '../../Config/theme.dart';
import '../../Objetos/AgendadoServicio.dart';
import '../../Objetos/Solicitud.dart';
import '../../Providers/Providers.dart';
import '../../Utils/Disenos.dart';
import '../../Utils/Firebase/Load_Data.dart';
import '../../Utils/Firebase/StreamBuilders.dart';
import '../../Utils/FuncionesMaterial.dart';
import '../../Utils/Utiles/FuncionesUtiles.dart';
import 'package:intl/intl.dart';

class EstadisticaMain extends StatefulWidget{
  final double currentwidth;

  const EstadisticaMain({Key?key,
    required this.currentwidth,
  }) :super(key: key);

  @override
  _EstadisticaMainState createState() => _EstadisticaMainState();

}

class _EstadisticaMainState extends State<EstadisticaMain> {
  List<Solicitud> solicitudesList = [];
  List<ServicioAgendado> servicioagendadoList = [];
  bool carguechart = false;
  bool dataloaded = false;
  bool cargueagendado = false;
  Map<DateTime, int> ventasporDia = {};
  Map<DateTime, int> ventasPorDiaDelMes = {};
  Map<DateTime, int> GananciasporDia = {};
  Map<String, int> estadoCounts = {
    "AGENDADO": 0, //
    "DISPONIBLE": 0, //
    "EXPIRADO": 0, //
    "ESPERANDO": 0,
    'NO PODEMOS':0, //
    'NO CLASIFICADO' :0,
  };

  //NO podemos

  int totalestado = 0;
  double percentagendado = 0;
  double percendisponible = 0;
  double percenexpirado = 0;
  double percenteserando = 0;
  double percentrechazado = 0;
  double margen_solicitud = 10;

  //conteos filtrados
  DateTime fecha_actual_filtro = DateTime.now();
  int contesolicitudfiltro = 0;
  int conteoServiciosAgendadofiltro = 0;
  int ventasobtenidas = 0;
  int costotutoresobtenido = 0;
  int gananciasobtenidas = 0;
  double percentganacia = 0.0;
  double percetnsolicitudes = 0.0;
  late TooltipBehavior _tooltipBehavior; //Top sf chart

  final ThemeApp themeApp = ThemeApp();

  void initState() {
    _tooltipBehavior =  TooltipBehavior(enable: true);
    loadDataTablasMaterias();
    super.initState();
  }

  Future<void> loadDataTablasMaterias() async {
    print("cargando tablas amterias");
    final contabilidadProvider = Provider.of<ContabilidadProvider>(context, listen: false);
    reiniciarvariables();
    //solicitudesList = await LoadData().obtenerSolicitudes();
    servicioagendadoList = contabilidadProvider.todoslosServiciosAgendados;

    for (var solicitud in solicitudesList) {
      estadoCounts[solicitud.estado] = estadoCounts[solicitud.estado]! + 1;
    }
    int numeroAgendado = estadoCounts["AGENDADO"] ?? 0;
    totalestado = numeroAgendado ;
    percentagendado = numeroAgendado+100/totalestado* 100;

    for(Solicitud solicitud in solicitudesList){
      if(solicitud.fechasistema.year == fecha_actual_filtro.year && solicitud.fechasistema.month == fecha_actual_filtro.month){
        contesolicitudfiltro = contesolicitudfiltro + 1;
      }
    }

    for(ServicioAgendado servicioagendado in servicioagendadoList){
      if(servicioagendado.fechasistema.year == fecha_actual_filtro.year && servicioagendado.fechasistema.month == fecha_actual_filtro.month){
        conteoServiciosAgendadofiltro = conteoServiciosAgendadofiltro + 1;
        ventasobtenidas = ventasobtenidas + servicioagendado.preciocobrado;
        costotutoresobtenido = costotutoresobtenido + servicioagendado.preciotutor;
        gananciasobtenidas = ventasobtenidas - costotutoresobtenido;
        percentganacia = gananciasobtenidas/ventasobtenidas * 100;
        percetnsolicitudes = conteoServiciosAgendadofiltro/contesolicitudfiltro * 100;
      }
    }

    setState(() {
      carguechart = true;
      _procesarSolicitudesPorDia();
      dataloaded = true;
      print("data loaded is true");
    });
  }

  void reiniciarvariables(){
    estadoCounts = {
      "AGENDADO": 0,
      "DISPONIBLE": 0,
      "EXPIRADO": 0,
      "ESPERANDO": 0,
      'NO PODEMOS': 0,
      'NO CLASIFICADO': 0,
    };
    totalestado = 0;
    percentagendado = 0;
    percendisponible = 0;
    percenexpirado = 0;
    percenteserando = 0;
    percentrechazado = 0;
    contesolicitudfiltro = 0;
    conteoServiciosAgendadofiltro = 0;
    ventasobtenidas = 0;
    costotutoresobtenido = 0;
    gananciasobtenidas = 0;
    percentganacia = 0.0;
    percetnsolicitudes = 0.0;
  }

  void _procesarSolicitudesPorDia() {
    ventasporDia = {}; // Limpiar el mapa antes de procesar nuevamente
    GananciasporDia = {}; // Limpiar también GananciasporDia

    for (var solicitud in servicioagendadoList) {
      final fechaSolicitud = DateTime(
        solicitud.fechasistema.year,
        solicitud.fechasistema.month,
        solicitud.fechasistema.day,
      );

      if (ventasporDia.containsKey(fechaSolicitud) && fechaSolicitud.month == fecha_actual_filtro.month) {
        ventasporDia[fechaSolicitud] = ventasporDia[fechaSolicitud]! + solicitud.preciocobrado;
      } else {
        if(fechaSolicitud.month == fecha_actual_filtro.month){
          ventasporDia[fechaSolicitud] = solicitud.preciocobrado;
        }
      }

      // Procesar Ganancias por día
      if (GananciasporDia.containsKey(fechaSolicitud)) {
        GananciasporDia[fechaSolicitud] = GananciasporDia[fechaSolicitud]! + (solicitud.preciocobrado - solicitud.preciotutor);
      } else {
        GananciasporDia[fechaSolicitud] = solicitud.preciocobrado - solicitud.preciotutor;
      }
    }
    // Ordena las fechas en ventasporDia
    final ventasporDiaList = ventasporDia.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    ventasporDia.clear();
    for (var entry in ventasporDiaList) {
      ventasporDia[entry.key] = entry.value;
    }

    // Ordena las fechas en GananciasporDia
    final gananciasporDiaList = GananciasporDia.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    GananciasporDia.clear();
    for (var entry in gananciasporDiaList) {
      GananciasporDia[entry.key] = entry.value;
    }


  }

  @override
  Widget build(BuildContext context) {

    const double containerWidth = 240;

    Text descripText(String text, [Color? color]) => Text(text, style: themeApp.styleText(15, true, color ?? themeApp.primaryColor), textAlign: TextAlign.center,);

    Container campoText(String text) => Container(
      width: 140,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: themeApp.primaryColor,
        borderRadius: BorderRadius.circular(20)
      ),
      child: descripText(text, themeApp.whitecolor),
    );

    Container campoFecha(List<Widget> children) => Container(
        margin: EdgeInsets.only(top: margen_solicitud),
        width: containerWidth,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: children,
        )
    );

    Container campoInformacion(List<Widget> children) => Container(
      width: 120,
      height: 80,
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
      decoration: BoxDecoration(
          color: themeApp.primaryColor,
          borderRadius: BorderRadius.circular(20)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );

    return SingleChildScrollView(
      child: ItemsCard(
        shadow: true,
        horizontalPadding: 20.0,
        verticalPadding: 15.0,
        children: [
          //Primera fila, superior
          Row(
            children: [
              //primera columna
              Container(
                margin: EdgeInsets.only(top: margen_solicitud, right: margen_solicitud * 2.5),
                child: Column(
                  children: [
                    Text('Estadisticas',style: themeApp.styleText(22, true, themeApp.primaryColor),),

                    campoFecha([
                      descripText("Año"),
                      campoText(fecha_actual_filtro.year.toString()),
                    ]),

                    campoFecha([
                      descripText("Mes"),
                      campoText(Utiles().mes(fecha_actual_filtro.month)),
                    ]),

                    campoFecha([
                      descripText("Dia"),
                      campoText(fecha_actual_filtro.day.toString()),
                    ]),

                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                        width: containerWidth,
                        child: selectfecha()
                    ),
                  ],
                ),
              ),

              //segunda columna
              Column(
                children: [
                  // # ventas
                  campoInformacion([
                    descripText("$conteoServiciosAgendadofiltro", themeApp.whitecolor),
                    descripText("Ventas", themeApp.whitecolor),
                  ]),

                  // # solicitudes
                  campoInformacion([
                    descripText("$contesolicitudfiltro", themeApp.whitecolor),
                    descripText("Solicitudes", themeApp.whitecolor),
                  ]),
                ],
              ),

              //Tercera columna
              Column(
                children: [
                  // Ganancias brutas obtenidas
                  campoInformacion([
                    descripText(NumberFormat("#,###", "es_ES").format(gananciasobtenidas), themeApp.whitecolor),
                    descripText("Ganancias obtenidas", themeApp.whitecolor),
                  ]),

                  // Dinero de ventas
                  campoInformacion([
                    descripText(NumberFormat("#,###", "es_ES").format(ventasobtenidas), themeApp.whitecolor),
                    descripText("Dinero de ventas", themeApp.whitecolor),
                  ]),
                ],
              ),
              //Cuarta columna
              Column(
                children: [
                  // Costo de ventas
                  campoInformacion([
                    descripText(NumberFormat("#,###", "es_ES").format(costotutoresobtenido), themeApp.whitecolor),
                    descripText("Costos de ventas", themeApp.whitecolor),
                  ]),

                  // % de rentabilidad
                  campoInformacion([
                    descripText("$percentganacia", themeApp.whitecolor),
                    descripText("% Ganancias", themeApp.whitecolor),
                  ]),

                ],
              ),

              Column(
                children: [
                  campoInformacion([
                    descripText(percetnsolicitudes.toStringAsFixed(2), themeApp.whitecolor),
                    descripText("% solicitudes agendadas", themeApp.whitecolor),
                  ]),
                ],
              )

            ],
          ),
          //Segunda fila, gráficas
          Row(
            children: [
              //Ventas
              Column(
                children: [
                  Text('Ventas',style: Disenos().aplicarEstilo(Config().primaryColor, 30, true),),
                  SfCartesianChart(
                    primaryXAxis: DateTimeAxis(
                      labelIntersectAction: AxisLabelIntersectAction.rotate45, // Rotar las etiquetas para evitar superposiciones
                      intervalType: DateTimeIntervalType.days,
                      interval: 6,
                      minimum: DateTime(fecha_actual_filtro.year,fecha_actual_filtro.month,1),
                      maximum: DateTime(fecha_actual_filtro.year,fecha_actual_filtro.month,31),
                    ),
                    series: <ChartSeries>[
                      LineSeries<MapEntry<DateTime, int>, DateTime>(
                          dataSource: ventasporDia.entries.toList(),
                          xValueMapper: (entry, _) => entry.key,
                          yValueMapper: (entry, _) => entry.value,
                          name: "Solicitudes",
                          width: 2,
                          markerSettings: const MarkerSettings(isVisible: true)
                      ),
                    ],
                  ),
                ],
              ),
              //Ganancias
              Column(
                children: [
                  Text('Ganancias',style: Disenos().aplicarEstilo(Config().primaryColor, 30, true),),
                  SfCartesianChart(
                    primaryXAxis: DateTimeAxis(
                      labelIntersectAction: AxisLabelIntersectAction.rotate45, // Rotar las etiquetas para evitar superposiciones
                      intervalType: DateTimeIntervalType.days,
                      edgeLabelPlacement: EdgeLabelPlacement.values.first,
                      minimum: DateTime(fecha_actual_filtro.year,fecha_actual_filtro.month,1),
                      maximum: DateTime(fecha_actual_filtro.year,fecha_actual_filtro.month,31),
                      interval: 4,
                      rangePadding: ChartRangePadding.auto,
                    ),
                    title: ChartTitle(text: 'Gráfico de ganancias'),
                    tooltipBehavior: _tooltipBehavior,
                    series: <ChartSeries>[
                      LineSeries<MapEntry<DateTime, int>, DateTime>(
                        dataSource: GananciasporDia.entries.toList(),
                        xValueMapper: (entry, _) => entry.key,
                        yValueMapper: (entry, _) => entry.value,
                        name: "Solicitudes",
                        width: 2,
                        markerSettings: const MarkerSettings(isVisible: true),
                        dataLabelSettings: const DataLabelSettings(
                          labelAlignment: ChartDataLabelAlignment.top,
                          labelPosition: ChartDataLabelPosition.outside,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          //Tercera fila
          Row(
            children: [
              Column(
                children: [
                  Text('# AGENDADOS ${estadoCounts["AGENDADO"]}'),
                  Text('# DISPONIBLE ${estadoCounts["DISPONIBLE"]}'),
                  Text('# EXPIRADO ${estadoCounts["EXPIRADO"]}'),
                  Text('# ESPERANDO ${estadoCounts["ESPERANDO"]}'),
                  Text('# NO PODEMOS ${estadoCounts["NO PODEMOS"]}'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Column selectfecha(){
    return Column(
      children: [
        Container(
          child: GestureDetector(
            onTap: () async{
              final date = await FuncionesMaterial().pickDate(context,fecha_actual_filtro);
              if(date == null) return;

              final newDateTime = DateTime(
                date.year,
                date.month,
                date.day,
                fecha_actual_filtro.hour,
                fecha_actual_filtro.minute,
              );

              setState( () {
                fecha_actual_filtro = newDateTime;
                loadDataTablasMaterias();
                _procesarSolicitudesPorDia();
              }
              );
            },
            child: Disenos().fecha_y_entrega('${fecha_actual_filtro.day}/${fecha_actual_filtro.month}/${fecha_actual_filtro.year}',widget.currentwidth),
          ),
        ),
      ],
    );
  }

}