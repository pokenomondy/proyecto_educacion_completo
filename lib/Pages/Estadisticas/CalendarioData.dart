import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard_admin_flutter/Config/theme.dart';
import 'package:dashboard_admin_flutter/Objetos/AgendadoServicio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluent_ui/fluent_ui.dart' hide CalendarView,Colors;
import 'package:flutter/material.dart' as material;
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart' ;
import '../../Providers/Providers.dart';
import '../../Utils/Calendario/CalendarioEstilo.dart';

class CalendarioData extends StatefulWidget{
  const CalendarioData({super.key});

  @override
  CalendarioDataState createState() => CalendarioDataState();

}

class CalendarioDataState extends State<CalendarioData> {
  @override
  Widget build(BuildContext context) {
    final currentwidth = MediaQuery.of(context).size.width;
    return PrimaryColumn(currentwidth: currentwidth);
  }
}

class PrimaryColumn extends StatefulWidget{
  final double currentwidth;

  const PrimaryColumn({Key?key,
    required this.currentwidth,
  }) :super(key: key);
  @override
  PrimaryColumnState createState() => PrimaryColumnState();
}

class PrimaryColumnState extends State<PrimaryColumn> {
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
    return SizedBox(
      height: currentheight,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PrimaryStyleButton(
                    function: (){
                      setState(() {
                        motivosPagos = "ENTREGAS";
                      });
                    },
                    text: " Entregas "
                ),

                PrimaryStyleButton(
                    function: (){
                      setState(() {
                        motivosPagos = "PAGOSCLIENTES";
                      });
                    },
                    text: " Pagos Clientes "
                ),

                PrimaryStyleButton(
                    function: (){
                      setState(() {
                        motivosPagos = "PAGOSTUTORES";
                      });
                    },
                    text: " Pagos Tutores "
                ),
              ],
            ),
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

                        return SizedBox(
                          height: currentheight-50,
                          child: SfCalendar(
                            controller: _calendarController,
                            showDatePickerButton: true,
                            allowedViews: _vistascalendario,
                            dataSource: meetings != null ? _DataSource(meetings!) : null,
                            initialDisplayDate: DateTime.now(),
                            initialSelectedDate: DateTime.now(),
                            showNavigationArrow: true,
                            monthViewSettings: const MonthViewSettings(appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
                            scheduleViewSettings: const ScheduleViewSettings(
                                appointmentItemHeight: 70,
                                monthHeaderSettings: MonthHeaderSettings(
                                    monthFormat: 'MMMM, yyyy',
                                    height: 100,
                                    textAlign: TextAlign.left,
                                    backgroundColor: material.Colors.green,
                                    monthTextStyle: TextStyle(
                                      color: material.Colors.red,
                                      fontSize: 25,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: "Poppins"
                                    ))
                            ),
                            onTap: (CalendarTapDetails details) {
                              CalendarioStyle().calendario_oprimido(details, _subject!, _notes!, context, appointmentToServicioMap, "ADMIN");
                            },
                          ),
                        );

                      }
                  ),
                if(datosDescargados == true)
                  const Text('Descargados'),
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

