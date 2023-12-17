import "package:dashboard_admin_flutter/Config/strings.dart";
import "package:dashboard_admin_flutter/Pages/Login%20page/LoginPage.dart";
import "package:dashboard_admin_flutter/Utils/Firebase/Load_Data.dart";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "../Config/elements.dart";
import "../Config/theme.dart";

class InitPage extends StatefulWidget{
  const InitPage({super.key});
  @override
  InitPageState createState() => InitPageState();
}

class InitPageState extends State<InitPage>{
  List<Map<String, dynamic>> listaClaves = [];

  @override
  void initState() {
    loadclaves();
    super.initState();
  }

  Future loadclaves() async{
    listaClaves = await LoadData().cargaListaEmpresas();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? nombre_empresa = prefs.getString("Nombre_Empresa");
    if (nombre_empresa != null) {
      _redireccionALogin(nombre_empresa);
    }
  }

  @override
  Widget build(BuildContext context){
    final ThemeApp theme = ThemeApp();
    late TextEditingController textController = TextEditingController();
    return Center(
      child: ItemsCard(
        width: 400,
        height: 500,
        children: [
          CircularLogo(asset: "logo.png", containerColor: theme.primaryColor, width: 150, height: 150,),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              "Empresa",
              style: theme.styleText(
                  18,
                  true,
                  theme.grayColor)
            ),
          ),
          RoundedTextField(
            topMargin: 6,
            bottomMargin: 8,
            width: 250,
            controller: textController,
            placeholder: "Ingrese el numero de empresa"
          ),
          PrimaryStyleButton(
              function: (){
                verificarEmpresa(textController.text);
              },
              text: "Iniciar con empresa"
          ),
          Text(
            Strings().appVersion,
            style: theme.styleText(12, false, theme.grayColor.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }

  void verificarEmpresa(String contrasena) async {
    UtilDialogs dialogs = UtilDialogs(context : context);
    bool contrasenaCorrecta = false;
    String nombreEmpresa = '';

    for (var empresa in listaClaves) {
      if (empresa['Contrasena'] == contrasena) {
        contrasenaCorrecta = true;
        nombreEmpresa = empresa['Empresa'];
        break;
      }
    }

    if (contrasenaCorrecta) {
      print("Contraseña correcta. Nombre de la empresa: $nombreEmpresa");
      //vamos a guardar de forma local esta contraseña
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("Nombre_Empresa", nombreEmpresa);
      RedireccionaALogin();
    } else {
      dialogs.error(Strings().errorcontrasena, 'Error');
      print("Contraseña incorrecta. Inténtelo de nuevo.");
    }
  }

  void RedireccionaALogin() async {
    // Si no está vacío, redirige a LoginPage
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _redireccionALogin(String nameEmpresa) async{
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }
}