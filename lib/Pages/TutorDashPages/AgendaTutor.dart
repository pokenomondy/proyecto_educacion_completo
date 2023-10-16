import 'package:dashboard_admin_flutter/Objetos/AgendadoServicio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluent_ui/fluent_ui.dart' hide CalendarView;
import 'package:syncfusion_flutter_calendar/calendar.dart' ;
import '../../Utils/Firebase/Load_Data.dart';
import 'package:flutter/material.dart' as dialog;
import 'package:intl/intl.dart';

import '../../Utils/Firebase/StreamBuilders.dart';

class AgendaTutor extends StatefulWidget{

  @override
  _AgendaTutorState createState() => _AgendaTutorState();

}

class _AgendaTutorState extends State<AgendaTutor> {

  @override
  Widget build(BuildContext context) {
    final currentwidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        PrimaryColumn(currentwidth: currentwidth),
      ],
    );
  }

}

class PrimaryColumn extends StatefulWidget{
  final double currentwidth;

  const PrimaryColumn({Key?key,
    required this.currentwidth,
  }) :super(key: key);
  @override
  _PrimaryColumnState createState() => _PrimaryColumnState();

}

class _PrimaryColumnState extends State<PrimaryColumn> {
  final currentUser = FirebaseAuth.instance.currentUser;
  String nombretutor = "";
  final List<CalendarView> _vistascalendario = <CalendarView>[
    CalendarView.month,
    CalendarView.week,
    CalendarView.schedule,
    ];
  final CalendarController _calendarController = CalendarController();
  String? _subject = '',_start = '',_end = '', _notes = '';
  Map<Appointment, ServicioAgendado> appointmentToServicioMap = {};
  ServicioAgendado? servicioseleccionado;


  @override
  void initState() {
    _calendarController.view = CalendarView.month;
    print("usuario iod ${currentUser?.uid}");
    loaddata().then((_) {
      setState(() {}); // Trigger a rebuild after data is loaded.
    });
    super.initState();
  }

  Future<void> loaddata() async {
    Map<String, dynamic> datos_tutor = await LoadData().getinfotutor(currentUser!);
    nombretutor = datos_tutor['nametutor'];
    print("agenda tutores la verga");
    print(nombretutor);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Agenda tutores'),
        StreamBuilder<List<ServicioAgendado>>(
          stream: stream_builders().getServiciosAgendadosTutor(nombretutor),
          builder: (context, snapshot){
            List<ServicioAgendado>? servicioagendadoList= [];
            if (snapshot.hasError) {
              return Center(child: Text('Error al cargar las solicitudes'));
            }
            if (!snapshot.hasData) {
              return Center(child: Text('cargando'));
            }
            servicioagendadoList = snapshot.data;
            List<Appointment>? meetings = servicioagendadoList
                ?.map((servicio) {
              final appointment = Appointment(
                startTime: tiempotarjetastart(servicio),
                endTime: tiempotarjetaend(servicio),
                subject: "${servicio.identificadorcodigo} - ${servicio.materia} - ${servicio.idcontable}",
                notes: servicio.materia,
                color: colortarjeta(servicio),
              );
              appointmentToServicioMap[appointment] = servicio;
              return appointment;
            }).toList();

            print("meetings $meetings");
            return Container(
              height: 800,
              child: SfCalendar(
                controller: _calendarController,
                showDatePickerButton: true,
                allowedViews: _vistascalendario,
                dataSource: meetings != null ? _DataSource(meetings) : null,
                initialDisplayDate: DateTime.now(),
                initialSelectedDate: DateTime.now(),
                showNavigationArrow: true,
                monthViewSettings: MonthViewSettings(
                  appointmentDisplayMode: MonthAppointmentDisplayMode.appointment
                ),
                scheduleViewSettings: ScheduleViewSettings(
                  appointmentItemHeight: 70,
                    monthHeaderSettings: MonthHeaderSettings(
                        monthFormat: 'MMMM, yyyy',
                        height: 100,
                        textAlign: TextAlign.left,
                        backgroundColor: Colors.green,
                        monthTextStyle: TextStyle(
                            color: Colors.red,
                            fontSize: 25,
                            fontWeight: FontWeight.w400))
                ),
                onTap: calendario_oprimido,
              ),
            );
          },
        ),
      ],
    );
  }

  void calendario_oprimido(CalendarTapDetails details){
    if(details.targetElement == CalendarElement.appointment || details.targetElement == CalendarElement.agenda){
      final Appointment appointmentdetails = details.appointments![0];
      _subject = appointmentdetails.subject;
      _notes = appointmentdetails.notes;
      servicioseleccionado = appointmentToServicioMap[appointmentdetails];

    }else{

    }
    dialog.showDialog(
        context: context,
        builder: (BuildContext context){
          return dialog.AlertDialog(
            title: Text('Agenda $_subject'),
            content: Column(
              children: [
                Text(_notes!),
                Text(servicioseleccionado!.materia),
                Text(servicioseleccionado!.preciotutor.toString()),
                Text(servicioseleccionado!.codigo),
                Text(DateFormat('dd/MM/yyyy hh:mm a').format(servicioseleccionado!.fechaentrega)),
                Text(servicioseleccionado!.idcontable.toString()),
                Text(servicioseleccionado!.idsolicitud.toString()),
                Text(servicioseleccionado!.entregadotutor), //Algun color, si tiene entrega o no?

                if(servicioseleccionado!.entregadotutor != "ENTREGADO")
                  Column(
                    children: [
                      StreamBuilder<int>(
                        stream: Stream.periodic(Duration(seconds: 1), (i) => i), // Actualiza cada minuto
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Text('sin datos'); // Manejar el caso en el que no hay datos aún
                          }

                          final now = DateTime.now();
                          final timeRemaining = servicioseleccionado!.fechaentrega.difference(now);

                          return Text(
                            'Tiempo restante: ${timeRemaining.inDays} días, ${timeRemaining.inHours.remainder(24)} horas '
                                ', ${timeRemaining.inMinutes.remainder(60)} minutos',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ],
                  ),
              ],
            ),
          );
        }
    );
  }

  dialog.Color colortarjeta(ServicioAgendado servicio){
    print("efectuando");
    if(servicio!.fechasistema.isBefore(DateTime(2023,9,29))){
      return dialog.Colors.yellow;
    }else if(servicio.entregadotutor == "ENTREGADO"){
      return dialog.Colors.green; //Ya esta entregado
    }else if(servicio.identificadorcodigo == "P"){
      return dialog.Colors.orange; //Ya esta entregado
    }else if(servicio.identificadorcodigo == "A"){
      return dialog.Colors.blue; //Ya esta entregado
    }else if(servicio.identificadorcodigo == "T"){
      return dialog.Colors.red; //Ya esta entregado
    }else{
      return dialog.Colors.grey;
    }
  }

  DateTime tiempotarjetastart(ServicioAgendado servicio){
    if(servicio.identificadorcodigo == "T"){
      return DateTime(servicio.fechaentrega.year, servicio.fechaentrega.month, servicio.fechaentrega.day, servicio.fechaentrega.hour -1, servicio.fechaentrega.minute, 0);
    }else if(servicio.identificadorcodigo == "P"){
      return DateTime(servicio.fechaentrega.year, servicio.fechaentrega.month, servicio.fechaentrega.day, servicio.fechaentrega.hour, servicio.fechaentrega.minute, 0);
    }else if(servicio.identificadorcodigo == "Q"){
      return DateTime(servicio.fechaentrega.year, servicio.fechaentrega.month, servicio.fechaentrega.day, servicio.fechaentrega.hour, servicio.fechaentrega.minute, 0);
    }else if(servicio.identificadorcodigo == "A"){
      return DateTime(servicio.fechaentrega.year, servicio.fechaentrega.month, servicio.fechaentrega.day, servicio.fechaentrega.hour, servicio.fechaentrega.minute, 0);
    }else{
      return DateTime(servicio.fechaentrega.year, servicio.fechaentrega.month, servicio.fechaentrega.day, servicio.fechaentrega.hour - 1, servicio.fechaentrega.minute, 0);
    }
  }

  DateTime tiempotarjetaend(ServicioAgendado servicio){
    if(servicio.identificadorcodigo == "T"){
      return DateTime(servicio.fechaentrega.year, servicio.fechaentrega.month, servicio.fechaentrega.day, servicio.fechaentrega.hour , servicio.fechaentrega.minute, 0);
    }else if(servicio.identificadorcodigo == "P"){
      return DateTime(servicio.fechaentrega.year, servicio.fechaentrega.month, servicio.fechaentrega.day, servicio.fechaentrega.hour+2, servicio.fechaentrega.minute, 0);
    }else if(servicio.identificadorcodigo == "Q"){
      return DateTime(servicio.fechaentrega.year, servicio.fechaentrega.month, servicio.fechaentrega.day, servicio.fechaentrega.hour+1, servicio.fechaentrega.minute, 0);
    }else if(servicio.identificadorcodigo == "A"){
      return DateTime(servicio.fechaentrega.year, servicio.fechaentrega.month, servicio.fechaentrega.day, servicio.fechaentrega.hour+1, servicio.fechaentrega.minute, 0);
    }else{
      return DateTime(servicio.fechaentrega.year, servicio.fechaentrega.month, servicio.fechaentrega.day, servicio.fechaentrega.hour - 1, servicio.fechaentrega.minute, 0);
    }
  }

//    endTime: DateTime(servicio.fechaentrega.year, servicio.fechaentrega.month, servicio.fechaentrega.day, servicio.fechaentrega.hour, servicio.fechaentrega.minute, 0),

}

class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> source) {
    appointments = source;
  }
}

