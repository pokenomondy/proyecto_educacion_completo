import 'package:dashboard_admin_flutter/Objetos/AgendadoServicio.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/StreamBuilders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluent_ui/fluent_ui.dart' hide CalendarView,Colors;
import 'package:flutter/material.dart' as dialog;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart' ;

import '../../Utils/Calendario/CalendarioEstilo.dart';

class CalendarioData extends StatefulWidget{

  @override
  _CalendarioDataState createState() => _CalendarioDataState();

}

class _CalendarioDataState extends State<CalendarioData> {

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
  List<ServicioAgendado> servicioagendadoList = [];
  List<Appointment>? meetings = [];
  String? _subject = '',
      _start = '',
      _end = '',
      _notes = '';
  bool datosDescargados = false;
  bool cargarinterfaz = false;

  @override
  void initState() {
    loadchecks();
    _calendarController.view = CalendarView.month;
    super.initState();
  }

  void loadchecks() async {
    datosDescargados = false;
    setState(() {
      cargarinterfaz = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 800,
      child: Column(
        children: [
          if(cargarinterfaz == true)
            Column(
              children: [
                if(datosDescargados == false)
                  StreamBuilder<List<ServicioAgendado>>(
                    stream: stream_builders().getServiciosAgendados(),
                    builder: (context, snapshot) {
                      List<ServicioAgendado>? servicioagendadoList = [];
                      if (snapshot.hasError) {
                        return Center(
                            child: Text('Error al cargar las solicitudes'));
                      }
                      if (!snapshot.hasData) {
                        return Center(child: Text('cargando'));
                      }
                      servicioagendadoList = snapshot.data;
                      meetings = servicioagendadoList
                          ?.map((servicio) =>
                          Appointment(
                            startTime: CalendarioStyle().tiempotarjetastart(servicio),
                            endTime: CalendarioStyle().tiempotarjetaend(servicio),
                            subject: "${servicio.identificadorcodigo} - ${servicio.tutor  } - ${servicio.idcontable}",
                            notes: servicio.materia,
                            color: CalendarioStyle().colortarjetaAdmin(servicio),
                          ))
                          .toList();

                      return Container(
                        height: 800,
                        child: SfCalendar(
                          controller: _calendarController,
                          showDatePickerButton: true,
                          allowedViews: _vistascalendario,
                          dataSource: meetings != null
                              ? _DataSource(meetings!)
                              : null,
                          initialDisplayDate: DateTime.now(),
                          initialSelectedDate: DateTime.now(),
                          showNavigationArrow: true,
                          monthViewSettings: MonthViewSettings(
                              appointmentDisplayMode: MonthAppointmentDisplayMode
                                  .appointment
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
                          onTap: calendario_oprimido,
                        ),
                      );
                    },
                  ),
                if(datosDescargados == true)
                  Text('Descargados'),
              ],
            )

        ],
      ),
    );
  }

  void calendario_oprimido(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.appointment ||
        details.targetElement == CalendarElement.agenda) {
      final Appointment appointmentdetails = details.appointments![0];
      _subject = appointmentdetails.subject;
      _notes = appointmentdetails.notes;
    } else {

    }
    dialog.showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog.AlertDialog(
            title: Text('Agenda $_subject'),
            content: Column(
              children: [
                Text(_notes!),
              ],
            ),
          );
        }
    );
  }

}

class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> source) {
    appointments = source;
  }
}

