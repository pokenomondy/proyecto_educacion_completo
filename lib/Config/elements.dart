import 'package:dashboard_admin_flutter/Config/theme.dart';
import 'package:dashboard_admin_flutter/Objetos/Solicitud.dart';
import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';

class TarjetaSolicitudes extends StatelessWidget{

  final Solicitud solicitud;
  final double width;
  final Color cardColor;
  final double tamanio;

  TarjetaSolicitudes({
    Key?key,
    required this.solicitud,
    this.width = 400,
    this.cardColor = const Color(0xFF235FD9),
    this.tamanio = 15,
  }):super(key: key);

  static const double definedWidth = 320;
  static const double constant = -1/830;

  @override
  Widget build(BuildContext context){
    final double numeroLetras = 1/3000 * ( width * width);
    final int contarSaltos = solicitud.resumen.isEmpty ? 0 : (solicitud.resumen.length / numeroLetras).floor() + solicitud.resumen.split('\n').length - 1;
    final double resumenHeigth = (-1/8000 * (width * width)) + 70 + (contarSaltos * tamanio);
    final double height = width >= 448 ? 75 + resumenHeigth: (constant * (width * width) + definedWidth) + resumenHeigth;
    final ThemeApp theme = ThemeApp();
    return ItemsCard(
      width: width,
      height: height,
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
              height: resumenHeigth,
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
                Text(solicitud.resumen.isEmpty ? "Sin resumen" : solicitud.resumen, style: theme.styleText(tamanio - 1, false, theme.whitecolor),)
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

class MensajeTextBox extends StatelessWidget{

  final TextEditingController controller;
  final String placeholder;
  final double width;
  final double heigth;

  const MensajeTextBox({
    Key?key,
    required this.controller,
    required this.placeholder,
    this.width = 410,
    this.heigth = 150,
  }):super(key: key);

  @override
  Widget build(BuildContext context){
    const double tamanio = 12;
    return SizedBox(
      width: width,
      child: Column(
        children: [
          Column(
              children: [
                Row(
                  children: [
                    PrimaryStyleButton(
                        tamanio: tamanio,
                        function: (){
                          controller.text += "/servicio/";
                        },
                        text: "Servicio"
                    ),
                    PrimaryStyleButton(
                        tamanio: tamanio,
                        function: (){
                          controller.text += "/idcotizacion/";
                        },
                        text: "Id Cotizacion"
                    ),
                    PrimaryStyleButton(
                        tamanio: tamanio,
                        function: (){
                          controller.text += "/materia/";
                        },
                        text: "Materia"
                    ),
                    PrimaryStyleButton(
                        tamanio: tamanio,
                        function: (){
                          controller.text += "/resumen/";
                        },
                        text: "Resumen"
                    ),
                  ],
                ),
                Row(
                  children: [
                    PrimaryStyleButton(
                      width: 110,
                        tamanio: tamanio,
                        function: (){
                          controller.text += "/fechaentrega/";
                        },
                        text: "Fecha de Entrega"
                    ),
                    PrimaryStyleButton(
                        width: 110,
                        tamanio: tamanio,
                        function: (){
                          controller.text += "/horaentrega/";
                        },
                        text: "Hora de Entrega"
                    ),
                    PrimaryStyleButton(
                        tamanio: tamanio,
                        width: 140,
                        function: (){
                          controller.text += "/infocliente/";
                        },
                        text: "Informacion Cliente"
                    ),
                  ],
                ),
              ]
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: width,
            height: heigth,
            child: TextBox(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20)
              ),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              textAlignVertical: TextAlignVertical.top,
              placeholder: placeholder,
              controller: controller,
              maxLines: null,
            ),
          ),
        ]
      ),
    );
  }

}