import 'package:dashboard_admin_flutter/Utils/EnviarMensajesWhataspp.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:whatsapp/whatsapp.dart';
import '../../Config/Config.dart';
import '../../Objetos/AgendadoServicio.dart';
import '../../Objetos/Solicitud.dart';
import '../../Utils/Disenos.dart';
import '../../Utils/Firebase/Load_Data.dart';
import '../../Utils/Firebase/StreamBuilders.dart';

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
  Map<DateTime, int> GananciasporDia = {};
  Map<String, int> estadoCounts = {
    "AGENDADO": 0,
    "DISPONIBLE": 0,
    "EXPIRADO": 0,
    "ESPERANDO": 0,
    "RECHAZADO": 0,
    'NO PODEMOS':0,
  };

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

  void initState() {
    loadDataTablasMaterias();
    super.initState();
  }

  Future<void> loadDataTablasMaterias() async {
    //solicitudesList = await LoadData().obtenerSolicitudes();
    servicioagendadoList = (await stream_builders().cargarserviciosagendados())!;

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
    }
    }

    setState(() {
      carguechart = true;
      _procesarSolicitudesPorDia();
      dataloaded = true;
      print("data loaded is true");
    });
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

      // Procesar ventas por día
      if (ventasporDia.containsKey(fechaSolicitud)) {
        ventasporDia[fechaSolicitud] = ventasporDia[fechaSolicitud]! + solicitud.preciocobrado;
      } else {
        ventasporDia[fechaSolicitud] = solicitud.preciocobrado;
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

    print("Tabla de ventas por día:");
    print(ventasporDia);
    print("Tabla de Ganancias por día:");
    print(GananciasporDia);
  }



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60,vertical: 30),
      child: SingleChildScrollView(
        child: Column(
          children: [
            //Primera fila, superior
            Row(
              children: [
                //primera columna
                Container(
                  margin: EdgeInsets.only(top: margen_solicitud),
                  child: Column(
                    children: [
                      Text('Estadisticas',style: Disenos().aplicarEstilo(Config().primaryColor, 30, true),),
                      Container(
                        margin: EdgeInsets.only(top: margen_solicitud),
                        width: 180,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Disenos().textonuevasolicitudazul("Año"),
                            Container(
                              width: 80,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Config.colorazulventas,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(child: Disenos().textonuevasolicitudazul("2023")),

                            ),
                        ],),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: margen_solicitud),
                        width: 180,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Disenos().textonuevasolicitudazul("Mes"),
                            Container(
                              width: 80,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Config.colorazulventas,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(child: Disenos().textonuevasolicitudazul("2023")),

                            ),
                          ],),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: margen_solicitud),
                        width: 180,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Disenos().textonuevasolicitudazul("Escala"),
                            Container(
                              width: 80,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Config.colorazulventas,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(child: Disenos().textonuevasolicitudazul("2023")),

                            ),
                          ],),
                      ),
                    ],
                  ),
                ),
                //segunda columna
                Column(
                  children: [
                    // # ventas
                    Container(
                      width: 120,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Config.colorazulventas,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Disenos().textonuevasolicitudazul("$conteoServiciosAgendadofiltro"),
                            Disenos().textonuevasolicitudazul("ventas"),
                          ],
                        ),
                      ),

                    ),
                    // # solicitudes
                    Container (
                      width: 120,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Config.colorazulventas,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Disenos().textonuevasolicitudazul("$contesolicitudfiltro"),
                            Disenos().textonuevasolicitudazul("solicitudes"),
                          ],
                        ),
                      ),

                    ),
                  ],
                ),
                //Tercera columna
                Column(
                  children: [
                    // Ganancias brutas obtenidas
                    Container(
                      width: 120,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Config.colorazulventas,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Disenos().textonuevasolicitudazul("$gananciasobtenidas"),
                            Disenos().textonuevasolicitudazul("Ganancias obtenidas"),
                          ],
                        ),
                      ),

                    ),
                    // Dinero de ventas
                    Container (
                      width: 120,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Config.colorazulventas,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Disenos().textonuevasolicitudazul("$ventasobtenidas"),
                            Disenos().textonuevasolicitudazul("Dinero de ventas"),
                          ],
                        ),
                      ),

                    ),
                  ],
                ),
                //Cuarta columna
                Column(
                  children: [
                    // Costo de ventas
                    Container(
                      width: 120,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Config.colorazulventas,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Disenos().textonuevasolicitudazul("$costotutoresobtenido"),
                            Disenos().textonuevasolicitudazul("Costos de ventas"),
                          ],
                        ),
                      ),

                    ),
                    // % de rentabilidad
                    Container (
                      width: 120,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Config.colorazulventas,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Disenos().textonuevasolicitudazul("$percentganacia"),
                            Disenos().textonuevasolicitudazul("% Ganancias"),
                          ],
                        ),
                      ),

                    ),
                  ],
                ),
                /*
                Container(
                    width: widget.currentwidth,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if(carguechart==true)
                            Column(
                              children: [
                                SfCartesianChart(
                                  primaryXAxis: DateTimeAxis(
                                    labelIntersectAction: AxisLabelIntersectAction.rotate45, // Rotar las etiquetas para evitar superposiciones
                                  ),
                                  series: <ChartSeries>[
                                    LineSeries<MapEntry<DateTime, int>, DateTime>(
                                        dataSource: solicitudesPorDia.entries.toList(),
                                        xValueMapper: (entry, _) => entry.key,
                                        yValueMapper: (entry, _) => entry.value,
                                        name: "Solicitudes",
                                        width: 2,
                                        markerSettings: const MarkerSettings(isVisible: true)
                                    ),
                                  ],
                                ),
                                SfCircularChart(
                                  legend: Legend(isVisible: true),
                                  series: <CircularSeries>[
                                    PieSeries<MapEntry<String, int>, String>(
                                      dataSource: estadoCounts.entries.toList(),
                                      xValueMapper: (entry, _) => entry.key,
                                      yValueMapper: (entry, _) => entry.value,
                                      dataLabelSettings: DataLabelSettings(
                                        isVisible: true,
                                      ),
                                    ),
                                  ],
                                ),
                                Text("Agendado = ${percentagendado.toString()}"),
                                Text(percentrechazado.toString()),
                                Text(percenteserando.toString()),
                                Text("Expirado = ${percenexpirado.toString()}"),
                                Text(percendisponible.toString()),
                              ],
                            ),



                        ],
                      ),
                    )),
                 */
              ],
            ),
            //Segunda fila, gráficas
            Row(
              children: [
                Column(
                  children: [
                    Text('Ventas',style: Disenos().aplicarEstilo(Config().primaryColor, 30, true),),
                    SfCartesianChart(
                      primaryXAxis: DateTimeAxis(
                        labelIntersectAction: AxisLabelIntersectAction.rotate45, // Rotar las etiquetas para evitar superposiciones
                        intervalType: DateTimeIntervalType.days,
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
                Column(
                  children: [
                    Text('Ganancias',style: Disenos().aplicarEstilo(Config().primaryColor, 30, true),),
                    SfCartesianChart(
                      primaryXAxis: DateTimeAxis(
                        labelIntersectAction: AxisLabelIntersectAction.rotate45, // Rotar las etiquetas para evitar superposiciones
                        intervalType: DateTimeIntervalType.days,
                        edgeLabelPlacement: EdgeLabelPlacement.values.first,
                      ),
                      series: <ChartSeries>[
                        LineSeries<MapEntry<DateTime, int>, DateTime>(
                            dataSource: GananciasporDia.entries.toList(),
                            xValueMapper: (entry, _) => entry.key,
                            yValueMapper: (entry, _) => entry.value,
                            name: "Solicitudes",
                            width: 2,
                            markerSettings: const MarkerSettings(isVisible: true),
                            dataLabelSettings: DataLabelSettings(
                            labelAlignment: ChartDataLabelAlignment.top,
                            labelPosition: ChartDataLabelPosition.outside,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}