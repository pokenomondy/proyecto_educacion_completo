import 'package:dashboard_admin_flutter/Objetos/Solicitud.dart';
import 'package:fluent_ui/fluent_ui.dart';
import '../../Objetos/AgendadoServicio.dart';
import '../../Utils/Firebase/Load_Data.dart';
import '../../Utils/Firebase/StreamBuilders.dart';

class Ventas extends StatefulWidget {

  @override
  _VentasState createState() => _VentasState();

}

class _VentasState extends State<Ventas> {
  List<Solicitud> solicitudesList = [];
  DateTime fecha_actual = DateTime.now();
  bool dataLoaded = false;
  int conteosolicitudesmensual = 0;
  List<ServicioAgendado> servicioagendadoList = [];
  int conteocontabilidad = 0;
  int preciocobradogeneral = 0;
  int costostutores = 0;
  int ganancias = 0;




  @override
  void initState() {
    loadDataTablasMaterias();
    super.initState();
  }

  Future<void> loadDataTablasMaterias() async {
    //solicitudesList = await LoadData().obtenerSolicitudes();
    //servicioagendadoList = (await stream_builders().cargarserviciosagendados())!;
    //contabilidad arreglos
    for(ServicioAgendado contabilidad in servicioagendadoList){
      //sumanos numro de servicios
      if(contabilidad.fechasistema.year == fecha_actual.year && contabilidad.fechasistema.month == fecha_actual.month){
        conteocontabilidad = conteocontabilidad+1;
        preciocobradogeneral = contabilidad.preciocobrado + preciocobradogeneral;
        costostutores = contabilidad.preciotutor + costostutores;
      }
    }
    //numero de solicitudes solicitado este mes
    for(Solicitud solicitud in solicitudesList){
      if(solicitud.fechasistema.year == fecha_actual.year && solicitud.fechasistema.month == fecha_actual.month){
        conteosolicitudesmensual = conteosolicitudesmensual + 1;
        print(conteosolicitudesmensual);
      }
    }
    //Ganancias
    ganancias = preciocobradogeneral - costostutores;
    setState(() {
      dataLoaded = true; // Marcar que los datos ya se han cargado
    });
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text("mes : ${fecha_actual.month} de ${fecha_actual.year}"),
          //Datos que se cargan de analisis de datos
          if(dataLoaded==true)
          Column(
            children: [
              Text("Servicios solicitados este mes: $conteosolicitudesmensual"),
              Text("Servicios en contabilidad este mes : $conteocontabilidad"),
              Text("Precio cobrado este mes : $preciocobradogeneral"),
              Text("Precio cobrado por tutores este mes: $costostutores" ),
              Text("Las gaanacias son : $ganancias"),
              Text("----------------------------------------------"),
            ],
          ),
        ],
      ),
    );
  }
}