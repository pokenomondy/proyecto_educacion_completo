import 'package:dashboard_admin_flutter/Config/Config.dart';
import 'package:fluent_ui/fluent_ui.dart';

class Disenos{
  Config configuracion = Config();

  Disenos() {
    initializeConfig();
  }

  Future<void> initializeConfig() async {
    WidgetsFlutterBinding.ensureInitialized(); // Asegura que Flutter esté inicializado
    await configuracion.initConfig();
  }

  //Texto de demora de entrega de trabajo
  Text textoentregatrabajoTutor(DateTime fechaentrega){
    final now = DateTime.now();
    final timeRemaining = fechaentrega.difference(now);
    Color color = Colors.black;
    String texto = "Tiempo restante:";
    if(fechaentrega.isBefore(DateTime.now())){
      color = Colors.red;
      texto = "Retrasado:";
    }else{
      color = Colors.black;
    }
    return Text('$texto ${timeRemaining.inDays.abs()} días, ${timeRemaining.inHours.remainder(24).abs()} horas '
            ', ${timeRemaining.inMinutes.remainder(60).abs()} minutos',
        style: aplicarEstilo(color, 15, true),
    );

  }

  //Estilo para nuevas solicitudes
  Text textonuevasolicitudblanco(String text){
    return Text(text,style: aplicarEstilo(Config.secundaryColor, 15, true),);
  }

  Text textonuevasolicitudazul(String text){
    return Text(text,style: aplicarEstilo(configuracion.primaryColor, 15, true),textAlign: TextAlign.center,);
  }

  //Estilo carta de solicitudes
  Text textocardsolicitudes(String text){
    return Text(text,style: aplicarEstilo(Config.secundaryColor, 15, true),);
  }

  Text textocardsolicitudesnobold(String text){
    return Text(text,style: aplicarEstilo(Config.secundaryColor, 15, false),);
  }

  //Titulos encabezados importantes
  TextStyle aplicarEstilo(Color color, double fontSize,bool isBold){
    FontWeight fontWeight = (isBold) ? FontWeight.w700 : FontWeight.w300;
    return TextStyle(
        color: color,
        fontWeight: fontWeight,
        fontFamily: "Poppins",
        fontSize: fontSize);
  }

  //Decoración de caja de paneles
  BoxDecoration decoracionbuscador(){
    return BoxDecoration(
      color: Config.secundaryColor,
      borderRadius: BorderRadius.circular(10),
    );
  }

  //Estilos para panel de navegación de letra


  //Decoración de fechas y horas
  Container fecha_y_entrega(String text,double width){
    return Container(
      width: width-50,
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Config.secundaryColor,
      ),
        child:
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text),
          ],
        )
    );
  }

  //Decoracion para botones

  ButtonStyle boton_estilo(){
    return ButtonStyle(
      backgroundColor: ButtonState.all(Config.buttoncolor),
      shape: ButtonState.all(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Ajusta el valor del radio como desees
      )),

    );
  }

  //TEXTO









}