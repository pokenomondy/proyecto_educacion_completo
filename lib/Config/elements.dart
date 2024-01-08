import 'package:dashboard_admin_flutter/Config/theme.dart';
import 'package:flutter/material.dart' as dialog;
import 'package:fluent_ui/fluent_ui.dart';

class MensajeTextBox extends StatelessWidget{

  final TextEditingController controller;
  final String placeholder;
  final double width;
  final double heigth;
  final bool solicitud;

  const MensajeTextBox({
    Key?key,
    required this.controller,
    required this.placeholder,
    this.width = 450,
    this.heigth = 150,
    this.solicitud = true,
  }):super(key: key);

  @override
  Widget build(BuildContext context){
    const double tamanio = 12;
    return SizedBox(
      width: width,
      child: Column(
        children: [
          botones(tamanio),
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

  Column botones(double tamanio){
    if(solicitud){
      return Column(
        children: [
          Row(
            children: [
              PrimaryStyleButton(
                  tamanio: tamanio,
                  function: (){
                    int posicion = controller.selection.baseOffset;

                    controller.text = "${controller.text.substring(0, posicion)}/servicio/${controller.text.substring(posicion)}";

                    controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: posicion + "/servicio/".length)
                    );
                  },
                  text: "Servicio"
              ),
              PrimaryStyleButton(
                  tamanio: tamanio,
                  function: (){
                    int posicion = controller.selection.baseOffset;

                    controller.text = "${controller.text.substring(0, posicion)}/idcotizacion/${controller.text.substring(posicion)}";

                    controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: posicion + "/idcotizacion/".length)
                    );
                  },
                  text: "Id Cotizacion"
              ),
              PrimaryStyleButton(
                  tamanio: tamanio,
                  function: (){
                    int posicion = controller.selection.baseOffset;

                    controller.text = "${controller.text.substring(0, posicion)}/materia/${controller.text.substring(posicion)}";

                    controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: posicion + "/materia/".length)
                    );
                  },
                  text: "Materia"
              ),
              PrimaryStyleButton(
                  tamanio: tamanio,
                  function: (){
                    int posicion = controller.selection.baseOffset;

                    controller.text = "${controller.text.substring(0, posicion)}/resumen/${controller.text.substring(posicion)}";

                    controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: posicion + "/resumen/".length)
                    );
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
                    int posicion = controller.selection.baseOffset;

                    controller.text = "${controller.text.substring(0, posicion)}/fechaentrega/${controller.text.substring(posicion)}";

                    controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: posicion + "/fechaentrega/".length)
                    );
                  },
                  text: "Fecha de Entrega"
              ),
              PrimaryStyleButton(
                  width: 110,
                  tamanio: tamanio,
                  function: (){
                    int posicion = controller.selection.baseOffset;

                    controller.text = "${controller.text.substring(0, posicion)}/horaentrega/${controller.text.substring(posicion)}";

                    controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: posicion + "/horaentrega/".length)
                    );
                  },
                  text: "Hora de Entrega"
              ),
              PrimaryStyleButton(
                  tamanio: tamanio,
                  width: 140,
                  function: (){
                    int posicion = controller.selection.baseOffset;

                    controller.text = "${controller.text.substring(0, posicion)}/infocliente/${controller.text.substring(posicion)}";

                    controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: posicion + "/infocliente/".length)
                    );
                  },
                  text: "Informacion Cliente"
              ),
            ],
          ),
        ],
      );
    }else{
      return Column(
        children: [
          Row(
            children: [
              PrimaryStyleButton(
                  tamanio: tamanio,
                  function: (){
                    int posicion = controller.selection.baseOffset;

                    controller.text = "${controller.text.substring(0, posicion)}/servicioplural/${controller.text.substring(posicion)}";

                    controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: posicion + "/servicioplural/".length)
                    );
                  },
                  text: "Servicio Plural"
              ),
              PrimaryStyleButton(
                  tamanio: tamanio,
                  function: (){
                    int posicion = controller.selection.baseOffset;

                    controller.text = "${controller.text.substring(0, posicion)}/servicio/${controller.text.substring(posicion)}";

                    controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: posicion + "/servicio/".length)
                    );
                  },
                  text: "Servicio"
              ),
              PrimaryStyleButton(
                  tamanio: tamanio,
                  function: (){
                    int posicion = controller.selection.baseOffset;

                    controller.text = "${controller.text.substring(0, posicion)}/fecha de entrega/${controller.text.substring(posicion)}";

                    controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: posicion + "/fecha de entrega/".length)
                    );
                  },
                  text: "Fecha de Entrega"
              ),
            ],
          ),
          Row(
            children: [
              PrimaryStyleButton(
                  tamanio: tamanio,
                  function: (){
                    int posicion = controller.selection.baseOffset;

                    controller.text = "${controller.text.substring(0, posicion)}/materia/${controller.text.substring(posicion)}";

                    controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: posicion + "/materia/".length)
                    );
                  },
                  text: "Materia"
              ),
              PrimaryStyleButton(
                width: 50,
                  tamanio: tamanio,
                  function: (){
                    int posicion = controller.selection.baseOffset;

                    controller.text = "${controller.text.substring(0, posicion)}/rolusuario/${controller.text.substring(posicion)}";

                    controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: posicion + "/rolusuario/".length)
                    );
                  },
                  text: "Rol"
              ),
              PrimaryStyleButton(
                  tamanio: tamanio,
                  function: (){
                    int posicion = controller.selection.baseOffset;

                    controller.text = "${controller.text.substring(0, posicion)}/nombreusuario/${controller.text.substring(posicion)}";

                    controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: posicion + "/nombreusuario/".length)
                    );
                  },
                  text: "Nombre Usuario"
              ),
              PrimaryStyleButton(
                  tamanio: tamanio,
                  function: (){
                    int posicion = controller.selection.baseOffset;

                    controller.text = "${controller.text.substring(0, posicion)}/codigo/${controller.text.substring(posicion)}";

                    controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: posicion + "/codigo/".length)
                    );
                  },
                  text: "Codigo"
              ),
            ],
          ),
        ],
      );
    }
  }

}

class UtilDialogs{

  final BuildContext context;
  late BuildContext contextCarga;

  UtilDialogs({
    required this.context,
  });

  void error (String text, String title) => showDialog(
      context: context,
      builder: (BuildContext errorContext) => _errorDialog(text, title, errorContext)
  );
  
  void exito(String text, String title) => showDialog(
    context: context,
    builder: (BuildContext exitoContext) => _successDialog(text, title, exitoContext)
  );

  void confirmar (String text, String title, VoidCallback function, [VoidCallback? cancelFunction]) => showDialog(
        context: context,
        builder: (BuildContext confirmContext) =>  _confirmDialog(confirmContext, text, title, function, cancelFunction ?? (){})
  );

  void cargar(String text, String title) => showDialog(
      context: context,
      builder: (BuildContext context) => _cargaDialog(text, title, context)
  );

  void terminarCarga() => Navigator.pop(contextCarga);

  dialog.Dialog _errorDialog(String text, String title, BuildContext errorContext){
    const double tamanioTitle = 20;
    const double tamanioText = 14;
    const double iconSize = 70;

    final ThemeApp themeApp = ThemeApp();
    final int espaciosText = text.split("\n").length;
    final double heightTitle = (title.length / 20).ceilToDouble() * tamanioTitle;
    final double heightText = ((text.length / 25).ceilToDouble() + espaciosText) * tamanioText;

    final double height = heightTitle + heightText + iconSize + 110.0;

    return dialog.Dialog(
      backgroundColor: themeApp.whitecolor.withOpacity(0),
      child: ItemsCard(
        shadow: true,
        width: 200,
        height: height,
        horizontalPadding: 15.0,
        verticalPadding: 10.0,
        children: [
          Icon(dialog.Icons.error, size: iconSize, color: themeApp.redColor,),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0),
            child: Text(title, style: themeApp.styleText(tamanioTitle, true, themeApp.grayColor), textAlign: TextAlign.center,),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0, bottom: 10.0),
            child: Text(text, style: themeApp.styleText(tamanioText, false, themeApp.grayColor), textAlign: TextAlign.center,),
          ),
          PrimaryStyleButton(
              width: 100,
              buttonColor: themeApp.redColor,
              function: (){
                Navigator.pop(errorContext);
              }, text: "Cerrar")
        ],
      ),
    );
  }

  dialog.Dialog _successDialog(String text, String title, BuildContext exitoContext){
    final ThemeApp themeApp = ThemeApp();
    return dialog.Dialog(
      backgroundColor: themeApp.whitecolor.withOpacity(0),
      child: ItemsCard(
        shadow: true,
        width: 200,
        height: 220,
        children: [
          Icon(dialog.Icons.check_circle_rounded, size: 70, color: themeApp.greenColor,),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0),
            child: Text(title, style: themeApp.styleText(20, true, themeApp.grayColor),),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0, bottom: 10.0),
            child: Text(text),
          ),
          PrimaryStyleButton(
              width: 100,
              buttonColor: themeApp.greenColor,
              function: (){
                Navigator.pop(exitoContext);
              }, text: "Cerrar")
        ],
      ),
    );
  }

  dialog.Dialog _confirmDialog(BuildContext confirmContext, String text, String title, VoidCallback function, VoidCallback cancelFunction){
    final ThemeApp themeApp = ThemeApp();
    return dialog.Dialog(
      backgroundColor: themeApp.whitecolor.withOpacity(0),
      child: ItemsCard(
        shadow: true,
        width: 250,
        height: 220 + 10,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Icon(dialog.Icons.info, size: 70, color: themeApp.primaryColor,),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0),
            child: Text(title, style: themeApp.styleText(20, true, themeApp.grayColor),),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0, bottom: 10.0,),
            child: SizedBox(
              width: 230,
              child: Text(
                text,
                maxLines: null,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 15.0),
            width: 180,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PrimaryStyleButton(
                      width: 80,
                      function: (){
                        Navigator.pop(confirmContext);
                        function();
                      }, text: "Aceptar"),
                  PrimaryStyleButton(
                      width: 80,
                      buttonColor: themeApp.redColor,
                      function: (){
                        Navigator.pop(context);
                        cancelFunction();
                      }, text: "Cerrar"),
                ]
            ),
          )
        ],
      ),
    );
  }

  dialog.Dialog _cargaDialog(String text, String title, BuildContext cargaDialog){
    final ThemeApp themeApp = ThemeApp();
    contextCarga = cargaDialog;
    return dialog.Dialog(
      backgroundColor: themeApp.blackColor.withOpacity(0),
      child: ItemsCard(
        width: 260,
        height: 220 - 50,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 10.0),
            child: dialog.CircularProgressIndicator(
              strokeWidth: 4.0,
              color: themeApp.primaryColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0),
            child: Text(title, style: themeApp.styleText(20, true, themeApp.primaryColor),),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0, bottom: 10.0),
            child: Text(text),
          ),
        ],
      ),
    );
  }

}

class CircularButton extends StatefulWidget{

  final IconData iconData;
  final double radio;
  final Color buttonColor;
  final Color iconColor;
  final Color tapButtonColor;
  final Color tapIconColor;
  final double horizontalPadding;
  final double verticalPadding;
  final int millis;
  final VoidCallback function;

  const CircularButton({
    Key? key,
    required this.iconData,
    required this.function,
    this.radio = 25.0,
    this.millis = 500,
    this.verticalPadding = 3.0,
    this.horizontalPadding = 5.0,
    this.buttonColor = const Color(0xFF235FD9),
    this.iconColor = const Color(0xFFFFFFFF),
    this.tapIconColor = const Color(0xFFFFFFFF),
    this.tapButtonColor = const Color(0xFF4B4B4B),
  }):super(key: key);

  @override
  CircularButtonState createState()=> CircularButtonState();

}

class CircularButtonState extends State<CircularButton>{

  late bool _isPressed = false;

  @override
  Widget build(BuildContext context){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding, vertical: widget.verticalPadding),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.function,
          onTapDown: (_)=>setState(()=>_isPressed=true),
          onTapUp: (_)=>setState(()=>_isPressed=false),

          child: AnimatedContainer(
            alignment: Alignment.center,
            padding: EdgeInsets.all(widget.radio * 0.1),
            width: widget.radio,
            height: widget.radio,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(360),
              color: !_isPressed? widget.buttonColor: widget.tapButtonColor,
            ),
            duration: Duration(milliseconds: widget.millis),
            child: Icon(widget.iconData, color: !_isPressed? widget.iconColor : widget.tapIconColor, size: widget.radio * 0.55,),
          ),
        ),
      ),
    );
  }

}