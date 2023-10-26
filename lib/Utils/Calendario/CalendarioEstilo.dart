import 'package:dashboard_admin_flutter/Objetos/AgendadoServicio.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter/material.dart' as dialog;
import 'package:fluent_ui/fluent_ui.dart' hide CalendarView;
import 'package:intl/intl.dart';


class CalendarioStyle{

  dialog.Color colortarjetaTutor(ServicioAgendado servicio){
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

  //amarillo no aplica
  //rojo sin entrega de tutor
  //naranaja entregado por tutor
  //ver entregado a cliente
  //gris significa que no aplica

  dialog.Color colortarjetaAdmin(ServicioAgendado servicio){
    if(servicio!.fechasistema.isBefore(DateTime(2023,9,29))){
      return dialog.Colors.yellow;
    }else if(servicio.identificadorcodigo == "A" || servicio.identificadorcodigo == "P" || servicio.identificadorcodigo == "Q"){
      return dialog.Colors.grey;
    } else if(servicio.entregadotutor=="ENTREGADO"){
      return dialog.Colors.orange;
    }else{
    return dialog.Colors.red;
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


  void calendario_oprimido(CalendarTapDetails details,String _subject,String _notes,BuildContext context){
    ServicioAgendado? servicioseleccionado;
    if(details.targetElement == CalendarElement.appointment || details.targetElement == CalendarElement.agenda){
      final Appointment appointmentdetails = details.appointments![0];
      _subject = appointmentdetails.subject;
      _notes = appointmentdetails.notes!;
      //servicioseleccionado = appointmentToServicioMap[appointmentdetails] as ServicioAgendado?;

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
                GestureDetector(
                  onTap: () {
                    final textToCopy = servicioseleccionado!.codigo
                        .toString();
                    Clipboard.setData(
                        ClipboardData(text: textToCopy));
                  },
                  child: Text(servicioseleccionado!.codigo),
                ),
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

}