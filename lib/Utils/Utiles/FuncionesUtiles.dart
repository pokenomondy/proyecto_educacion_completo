import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../Disenos.dart';
import '../FuncionesMaterial.dart';

class Utiles{

  //Notificación
  void notificacion(String text,BuildContext context,bool error,String descripcion){
    InfoBarSeverity severity = (error) ? InfoBarSeverity.success : InfoBarSeverity.warning;
    print("mostrar infobar");
    displayInfoBar(context, builder: (context,close){
      return InfoBar(
        title:  Text(text),
        content:  Text(descripcion),
        action: IconButton(
          icon: const Icon(FluentIcons.clear),
          onPressed: close,
        ),
        severity: severity,
      );
    }
    );
  }

  //Retorno de horario de función
  String horariodeentrega(String servicio, DateTime fechaentrega,String identificadorcodigo) {
    String horaRealizada = "";

    if(servicio != ""){
      //Si el servicio es una solicitud =
      if(servicio=="TALLER"){
        horaRealizada = '${DateFormat('dd/MM/yyyy').format(fechaentrega)} ANTES DE LAS ${DateFormat('hh:mma').format(fechaentrega)}';
      }else{
        horaRealizada = '${DateFormat('dd/MM/yyyy').format(fechaentrega)} A LAS ${DateFormat('hh:mma').format(fechaentrega)}';
      }
    }else{
      //Si el servicio es un servicio agendado =
      if(identificadorcodigo == "T"){
        horaRealizada = '${DateFormat('dd/MM/yyyy').format(fechaentrega)} ANTES DE LAS ${DateFormat('hh:mma').format(fechaentrega)}';
      }else{
        horaRealizada = '${DateFormat('dd/MM/yyyy').format(fechaentrega)} A LAS ${DateFormat('hh:mma').format(fechaentrega)}';
      }
    }
    return horaRealizada;
  }

  //select picker para fechas y horas
  Future<DateTime?> pickDate(BuildContext context,DateTime fechaagendado) => material.showDatePicker(
    context: context,
    initialDate: fechaagendado,
    firstDate: DateTime(1900),
    lastDate: DateTime(2100),
  );
  Future<material.TimeOfDay?> pickTime(BuildContext context,DateTime fechaagendado) => material.showTimePicker(
      context: context,
      initialTime: material.TimeOfDay(hour: fechaagendado.hour, minute: fechaagendado.minute)
  );

  //Cortar pálabras
  String truncateLabel(String label) {
    const int maxLength = 30; // Define la longitud máxima permitida para la etiqueta
    if (label.length > maxLength) {
      return label.substring(0, maxLength - 3) + '...'; // Agrega puntos suspensivos
    }
    return label;
  }

  //Copiar colores
  Color hexToColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    return Color(int.parse(hexColor, radix: 16));
  }

  //LLamar mes
  String mes(int numeromes){
    if(numeromes == 1){
      return "Enero";
    }else if(numeromes == 2){
      return "Febrero";
    }else if(numeromes == 3){
      return "Marzo";
    }else if(numeromes == 4){
      return "Abril";
    }else if(numeromes == 5){
      return "Mayo";
    }else if(numeromes == 6){
      return "Junio";
    }else if(numeromes == 7){
      return "Julio";
    }else if(numeromes == 8){
      return "Agosto";
    }else if(numeromes == 9){
      return "Septiembre";
    }else if(numeromes == 10){
      return "Octubre";
    }else if(numeromes == 11){
      return "Noviembre";
    }else if(numeromes == 12){
      return "Diciembre";
    } else{
      return "NO DEBERIA LLEGAR ACA";
    }
  }

}