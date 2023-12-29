import 'package:fluent_ui/fluent_ui.dart';
import '../../Config/elements.dart';
import '../../Config/strings.dart';
import '../../Config/theme.dart';
import '../../Utils/Firebase/UploadAdmin.dart';

class DashboardAdmin extends StatefulWidget {

  @override
  DashboardAdminState createState() => DashboardAdminState();

}

class DashboardAdminState extends State<DashboardAdmin> {
  final TextEditingController tiempoLicencia = TextEditingController();
  final TextEditingController contrasena = TextEditingController();
  final TextEditingController nombreempresa = TextEditingController();
  DateTime fechaActual= DateTime.now();
  final TextEditingController correoGmail = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController numCelular = TextEditingController();

  @override
  Widget build(BuildContext context) {


    return Column(
      children: [
        //CREAR CLAVE Y CONTRASEÑA
        Text('Hoy es $fechaActual'),
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text('------ CREAR CLAVE EN SISTEMA -----',
            style: TextStyle(fontWeight: FontWeight.bold),),
        ),
        //Nombre empresa
        Row(
          children: [
            Text('Nombre nueva empresa ='),
            Expanded(
              child: RoundedTextField(
                controller: nombreempresa,
                placeholder: "Nombre empresa",
              ),
            ),
          ],
        ),
        //contraseña de empresa
        Row(
          children: [
            Text('Contraseña'),
            Expanded(
              child: RoundedTextField(
                controller: contrasena,
                placeholder: "tiempo de licencia",
              ),
            ),
          ],
        ),
        // AGREGUAMOS BASISCO FECHA DE TIEMPO, UN INT
        Row(
          children: [
            Text('Tiempo de licencia'),
            Expanded(
              child: RoundedTextField(
                  controller: tiempoLicencia,
                  placeholder: "tiempo de licencia"
              ),
            ),
            Text('Un mes tiene 30 días, agregar 30')
          ],
        ),

        PrimaryStyleButton(function: crearClave, text: "CREAR CLAVE"),

        //AGREGAR TUTOR
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text('------ AGREGAR TUTOR A EMPRESA -----',
            style: TextStyle(fontWeight: FontWeight.bold),),
        ),
        //Nombre empresa
        Row(
          children: [
            Text('Poner nombre de empresa para agregar'),
            Expanded(
              child: RoundedTextField(
                controller: nombreempresa,
                placeholder: "Nombre empresa",
              ),
            ),
          ],
        ),
        //correo gmail
        RoundedTextField(
            controller: correoGmail,
            placeholder: "Correo Gmail"
        ),
        //contraseña
        RoundedTextField(
            controller: password,
            placeholder: "Contraseña"
        ),
        //Numero de celular
        Row(
          children: [
            Text('Numero de celular'),
            Expanded(
              child: RoundedTextField(
                  controller: numCelular,
                  placeholder: "numero celular"
              ),
            ),
          ],
        ),
        //Crear nuevo administrador
        PrimaryStyleButton(function: crearAdministraddor, text: "CREAR NUEVO TUTOR"),
        //TUTOR LO AGREGAMOS AQUI APARTE
      ],
    );
  }

  Future crearClave() async{
    UtilDialogs dialogs = UtilDialogs(context : context);
    if(nombreempresa.text == "" || contrasena.text == "" || int.parse(tiempoLicencia.text) == 0){
      dialogs.error(Strings().errroDebeLLenarTodo, Strings().errorglobalText);
    }else{
      await UploadAdmin().addNuevaEmpresa(nombreempresa.text, contrasena.text,int.parse(tiempoLicencia.text));
      dialogs.exito(Strings().exitoglobal, Strings().exitoglobaltitulo);
    }
  }

  Future crearAdministraddor() async{
    UtilDialogs dialogs = UtilDialogs(context : context);
    if(correoGmail.text == "" || password.text == "" || nombreempresa == ""){
      dialogs.error(Strings().errroDebeLLenarTodo, Strings().errorglobalText);
    }else{
      await UploadAdmin().createUserWithEmailAndPassword(correoGmail, password, nombreempresa.text,int.parse(numCelular.text));
      dialogs.exito(Strings().exitoglobal, Strings().exitoglobaltitulo);
    }
  }



}