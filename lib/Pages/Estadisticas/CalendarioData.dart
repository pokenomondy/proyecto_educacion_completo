import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard_admin_flutter/Objetos/AgendadoServicio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluent_ui/fluent_ui.dart' hide CalendarView,Colors;
import 'package:flutter/material.dart' as dialog;
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart' ;
import '../../Providers/Providers.dart';
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
  String? _subject = '', _start = '', _end = '', _notes = '';
  bool datosDescargados = false;
  bool cargarinterfaz = false;
  Map<Appointment, ServicioAgendado> appointmentToServicioMap = {};
  String motivosPagos = "ENTREGAS";
  final db = FirebaseFirestore.instance;
  int numpagos = 0;


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
    final currentheight = MediaQuery.of(context).size.height-100;
    return Container(
      height: currentheight,
      child: Column(
        children: [
          Row(
            children: [
              FilledButton(child: Text('ENTREGAS'), onPressed: (){
                setState(() {
                  motivosPagos = "ENTREGAS";
                });
              }),
              FilledButton(child: Text('PAGOS CLIENTES'), onPressed: (){
                setState(() {
                  motivosPagos = "PAGOSCLIENTES";
                });
              }),
              FilledButton(child: Text('PAGOS TUTORES'), onPressed: (){
                setState(() {
                  motivosPagos = "PAGOSTUTORES";
                });
              }),
            ],
          ),
          if(cargarinterfaz == true)
            Column(
              children: [
                if(datosDescargados == false)
                  Consumer<ContabilidadProvider>(
                      builder: (context, contabilidadProvider, child) {
                        List<ServicioAgendado> servicioagendadoList = contabilidadProvider.todoslosServiciosAgendados;

                        List<Appointment>? meetings = servicioagendadoList
                            ?.map((servicio) {
                          final appointment = Appointment(
                            startTime: CalendarioStyle().tiempotarjetastart(servicio),
                            endTime: CalendarioStyle().tiempotarjetaend(servicio),
                            subject: "${servicio.identificadorcodigo}  ${servicio.materia} - ${servicio.idcontable}",
                            notes: servicio.materia,
                            color: CalendarioStyle().colortarjetaAdmin(servicio,motivosPagos),
                          );
                          appointmentToServicioMap[appointment] = servicio;
                          return appointment;
                        }).toList();

                        return Container(
                          height: currentheight-50,
                          child: SfCalendar(
                            controller: _calendarController,
                            showDatePickerButton: true,
                            allowedViews: _vistascalendario,
                            dataSource: meetings != null ? _DataSource(meetings!) : null,
                            initialDisplayDate: DateTime.now(),
                            initialSelectedDate: DateTime.now(),
                            showNavigationArrow: true,
                            monthViewSettings: MonthViewSettings(appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
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
                              CalendarioStyle().calendario_oprimido(details, _subject!, _notes!, context, appointmentToServicioMap, "ADMIN");
                            },
                          ),
                        );

                      }
                  ),
                if(datosDescargados == true)
                  Text('Descargados'),
              ],
            )
        ],
      ),
    );
  }

}

class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> source) {
    appointments = source;
  }
}

