import 'package:dashboard_admin_flutter/Config/theme.dart';
import 'package:dashboard_admin_flutter/Objetos/Solicitud.dart';
import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';

class TarjetaSolicitudes extends StatelessWidget{

  final Solicitud solicitud;
  final double width;
  final double heigth;
  final Color cardColor;
  final double tamanio;

  const TarjetaSolicitudes({
    Key?key,
    required this.solicitud,
    this.width = 400,
    this.heigth = 175,
    this.cardColor = const Color(0xFF235FD9),
    this.tamanio = 15,
  }):super(key: key);

  @override
  Widget build(BuildContext context){
    final double calculatedHeigth = heigth + (solicitud.resumen.length / 60).floor() * 20;
    final ThemeApp theme = ThemeApp();

    return ItemsCard(
      width: width,
      height: calculatedHeigth,
      shadow: false,
      verticalPadding: 15,
      horizontalPadding: 20,
      cardColor: cardColor,
      children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(solicitud.servicio, style: theme.styleText(tamanio, true, theme.whitecolor)),
          Text(DateFormat('dd/mm/yyyy').format(solicitud.fechaentrega), style: theme.styleText(tamanio, true, theme.whitecolor))
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(solicitud.materia, style: theme.styleText(tamanio - 1, false, theme.whitecolor),),
          Text(DateFormat('hh:mm a').format(solicitud.fechaentrega.toLocal()), style: theme.styleText(tamanio - 1, false, theme.whitecolor),)
        ],
      ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: ItemsCard(
              width: width,
              shadow: false,
              margin: 0,
              border: 10,
              horizontalPadding: 12,
              alignementCrossColumn: CrossAxisAlignment.start,
              verticalPadding: 8,
              cardColor: const Color(0xFF0A0A0A).withOpacity(0.2),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Resumen del Servicio", style: theme.styleText(tamanio - 1, true, theme.whitecolor),),
                    Container(
                        width: width * 0.2,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: theme.whitecolor,
                            borderRadius: BorderRadius.circular(40)
                        ),
                        child: Text(DateFormat('hh:mm a').format(solicitud.fechasistema.toLocal()), style: theme.styleText(tamanio - 1, false, cardColor),)
                    )
                  ],
                ),
                Text(solicitud.resumen, style: theme.styleText(tamanio - 1, false, theme.whitecolor),)
              ]
          ),
        ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("${solicitud.cliente} cotizaciones", style: theme.styleText(tamanio - 2, false, theme.whitecolor),),
          Text(solicitud.estado, style: theme.styleText(tamanio - 2, false, theme.whitecolor),),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(solicitud.cliente.toString(), style: theme.styleText(tamanio - 2, false, theme.whitecolor),),
          PrimaryStyleButton(function: (){}, text: "Copiar", invert: true, tamanio: tamanio - 2,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text("B", style: theme.styleText(tamanio - 2, false, theme.whitecolor),),
            ],
          )
        ],
      )
    ]
    );
  }


}