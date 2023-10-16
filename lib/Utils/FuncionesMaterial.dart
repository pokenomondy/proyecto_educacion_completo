import 'package:flutter/material.dart';

class FuncionesMaterial{

  Future<DateTime?> pickDate(BuildContext context,DateTime fechaagendado) => showDatePicker(
      context: context,
      initialDate: fechaagendado,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
  );
  
  Future<TimeOfDay?> pickTime(BuildContext context,DateTime fechaagendado) => showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: fechaagendado.hour, minute: fechaagendado.minute)
  );


}