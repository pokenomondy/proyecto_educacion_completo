import 'package:dashboard_admin_flutter/Objetos/AgendadoServicio.dart';
import 'package:dashboard_admin_flutter/Utils/Calendario/CalendarioEstilo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluent_ui/fluent_ui.dart' hide CalendarView;
import 'package:flutter/services.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart' ;
import '../../Utils/Disenos.dart';
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
  bool llamarstream = false;


  @override
  void initState() {
    _calendarController.view = CalendarView.month;
    loaddata().then((_) {
      setState(() {
        llamarstream = true;
      }); // Trigger a rebuild after data is loaded.
    });
    super.initState();
  }

  Future<void> loaddata() async {
    Map<String, dynamic> datos_tutor = await LoadData().getinfotutor(currentUser!);
    nombretutor = datos_tutor['nombre Whatsapp'];
  }

  @override
  Widget build(BuildContext context) {
    final currentheight = MediaQuery.of(context).size.height-80;
    return Column(
      children: [
        if(llamarstream==true)
        StreamBuilder<List<ServicioAgendado>>(
          stream: stream_builders().getServicidosAgendadosTutor(nombretutor),
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
                startTime: CalendarioStyle().tiempotarjetastart(servicio),
                endTime: CalendarioStyle().tiempotarjetaend(servicio),
                subject: "${servicio.identificadorcodigo} - ${servicio.materia} - ${servicio.idcontable}",
                notes: servicio.materia,
                color: CalendarioStyle().colortarjetaTutor(servicio),
              );
              appointmentToServicioMap[appointment] = servicio;
              return appointment;
            }).toList();

            return Container(
              height: currentheight,
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
                        backgroundColor: dialog.Colors.green,
                        monthTextStyle: TextStyle(
                            color: dialog.Colors.red,
                            fontSize: 25,
                            fontWeight: FontWeight.w400))
                ),
                onTap: (CalendarTapDetails details) {
                  CalendarioStyle().calendario_oprimido(details, _subject!, _notes!, context, appointmentToServicioMap,"TUTOR");
                },
              ),
            );
          },
        ),
      ],
    );
  }


}

class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> source) {
    appointments = source;
  }
}

