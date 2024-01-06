import 'package:dashboard_admin_flutter/Config/elements.dart';
import 'package:dashboard_admin_flutter/Config/strings.dart';
import 'package:dashboard_admin_flutter/Objetos/Tutores_objet.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/StreamBuilders.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:provider/provider.dart';
import '../../Config/Config.dart';
import '../../Config/theme.dart';
import '../../Objetos/Objetos Auxiliares/CuentasBancaraias.dart';
import '../../Objetos/Objetos Auxiliares/Carreras.dart';
import '../../Objetos/Objetos Auxiliares/Materias.dart';
import '../../Objetos/Objetos Auxiliares/Universidad.dart';
import '../../Providers/Providers.dart';
import '../../Utils/Disenos.dart';
import '../../Utils/Firebase/Uploads.dart';
import '../Tutores.dart';

class DetallesTutores extends StatefulWidget {

  const DetallesTutores({Key?key,
  }) :super(key: key);

  @override
  DetallesTutoresState createState() => DetallesTutoresState();
}

class DetallesTutoresState extends State<DetallesTutores> {
  
  @override
  Widget build(BuildContext context) {
    //Completo
    final widthCompleto = MediaQuery.of(context).size.width;
    //tamaño para computador y tablet
    final tamanowidthTripleComputador = (widthCompleto/3)-Config.responsivepc/3;
    //currentheight completo
    final heightCompleto = MediaQuery.of(context).size.height-Config.tamanoHeightnormal;

    return Column(
      children: [
        if(widthCompleto >= 1200)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PrimaryColumnTutores(currentwith: tamanowidthTripleComputador,currenheight:heightCompleto ,),
              SecundaryColumnTutores(currentwith: tamanowidthTripleComputador,currenheight: heightCompleto,),
              TercerColumnTutores(currentwith: tamanowidthTripleComputador,currenheight: heightCompleto,)
            ],
          ),
        if(widthCompleto < 1200 && widthCompleto > 620)
          SizedBox(
            height: heightCompleto,
            child: material.SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  PrimaryColumnTutores(currentwith: widthCompleto,currenheight:-1),
                  SecundaryColumnTutores(currentwith: widthCompleto,currenheight: -1,),
                  TercerColumnTutores(currentwith: widthCompleto,currenheight: -1,)
                ],
              ),
            ),
          ),
        if(widthCompleto <= 620)
          SizedBox(
            height: heightCompleto,
            child: material.SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  PrimaryColumnTutores(currentwith: widthCompleto,currenheight:-1),
                  SecundaryColumnTutores(currentwith: widthCompleto,currenheight: -1,),
                  TercerColumnTutores(currentwith: widthCompleto,currenheight: -1,)
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class PrimaryColumnTutores extends StatefulWidget {
  final double currentwith;
  final double currenheight;

  const PrimaryColumnTutores({Key?key,
    required this.currentwith,
    required this.currenheight
  }) :super(key: key);

  @override
  PrimaryColumnTutoresState createState() => PrimaryColumnTutoresState();

}

class PrimaryColumnTutoresState extends State<PrimaryColumnTutores> {
  final GlobalKey<TutoresVistaVistaState> tutoresVistaState = GlobalKey<TutoresVistaVistaState>();
  List<bool> editarcasilla = List.generate(10, (index) => false);
  String datoscambiostext = "";
  List<Materia> materiasList = [];
  Materia? selectedMateria ;
  bool cargadotablamaterias = false;

  //Cuentas bancarias
  String? selectedTipoCuenta;
  List<String> tipoCuentaList = ['NEQUI','PAYPAL','BANCOLOMBIA','DAVIPLATA','BINANCE'];

  final TextEditingController numeroCuentaBancaria = TextEditingController();
  final TextEditingController cedulaTutor = TextEditingController();
  final TextEditingController nombreCedulaTutor = TextEditingController();

  List<Carrera> CarrerasList = [];
  Carrera? selectedCarreraobject;

  List<Universidad> UniversidadList = [];
  Universidad? selectedUniversidadobject;
  final ThemeApp themeApp = ThemeApp();

  //Para cambios
  String cambio = "";
  int cambionum = 0;
  //variables consumer
  String uidtutor = "";
  bool activo = false;
  bool volveraconsultar = false;
  List<Materia> materiaListTutor = [];
  List<CuentasBancarias> cuentasBancariasTutor = [];
  late bool construct = false;

  @override
  void initState(){
    super.initState();
    loaddata();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        volveraconsultar = true;
      });
    });
    WidgetsFlutterBinding.ensureInitialized(); // Asegura que Flutter esté inicializado
    themeApp.initTheme().then((_) {
      setState(()=>construct = true);
    });
  }



  @override
  void dispose() {
    super.dispose();
  }

  Future <void> loaddata()async{
    materiasList = await stream_builders().cargarMaterias();
    CarrerasList = await stream_builders().cargarCarreras();
    UniversidadList = await stream_builders().cargarUniversidades();
    setState(() {
      cargadotablamaterias = true;
    });
    //materias provider
    /*
    final materiasProvider = Provider.of<MateriasProvider>(context, listen: false);
    // Eliminar todas las materias
    materiasProvider.clearMaterias();
    for (Materia materia in widget.tutor.materias) {
      materiasProvider.addMateria(materia);
    }
    //Cuentas provider
    final cuentasProvider = Provider.of<CuentasProvider>(context, listen: false);
    //eliminar primero
    cuentasProvider.clearCuentas();
    for (CuentasBancarias cuentita in widget.tutor.cuentas) {
      cuentasProvider.addCuenta(cuentita);
    }

     */
  }

  @override
  Widget build(BuildContext context) {
    if(construct){
      return Consumer<VistaTutoresProvider>(
          builder: (context, tutorProvider, child) {
            Tutores tutorseleccionado = tutorProvider.tutorSeleccionado;
            uidtutor = tutorseleccionado.uid;
            materiaListTutor = tutorseleccionado.materias;
            cuentasBancariasTutor = tutorseleccionado.cuentas;

            if(!volveraconsultar){
              activo = tutorseleccionado.activo;
            }

            return ItemsCard(
              height: widget.currenheight,
              alignementColumn: MainAxisAlignment.start,
              shadow: false,
              width: widget.currentwith,
              verticalPadding: 20,
              horizontalPadding: 15,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text("Añadir Tutor", style: themeApp.styleText(24, true, themeApp.primaryColor)),
                ),

                textoymodificable("Nombre Whatsap", tutorseleccionado.nombrewhatsapp,0 , true),
                textoymodificable("Nombre Completo", tutorseleccionado.nombrecompleto,1, false),
                textoymodificable("Numero de Whatsapp",tutorseleccionado.numerowhatsapp.toString() ,2, false),
                textoymodificable("Carrera",tutorseleccionado.carrera ,3, false),
                textoymodificable("Correo gmail",tutorseleccionado.correogmail, 4, true),
                textoymodificable("Universidad",tutorseleccionado.univerisdad ,5, false),
                textoymodificable("Estado",tutorseleccionado.activo ? "Activo" : "Inactivo",6, false),

                //Agregar nueva matería
                if(cargadotablamaterias)
                  Column(
                    children: [
                      //MATERIAS
                      Container(
                        height: 30,
                        margin: const EdgeInsets.symmetric(vertical: 10.0),
                        width: widget.currentwith-50,
                        child: AutoSuggestBox<Materia>(
                          items: materiasList.map<AutoSuggestBoxItem<Materia>>(
                                (materia) => AutoSuggestBoxItem<Materia>(
                              value: materia,
                              label: materia.nombremateria,
                            ),
                          )
                              .toList(),
                          decoration: Disenos().decoracionbuscador(),
                          onSelected: (item) {
                            setState(() {
                              selectedMateria = item.value;
                            });
                          },
                          onChanged: (text, reason) {
                            if (text.isEmpty ) {
                              setState(() {
                                selectedMateria = null;
                              });
                            }
                          },
                        ),
                      ),
                      PrimaryStyleButton(
                        buttonColor: themeApp.primaryColor,
                          function: () async{
                            verificarUploadMateria();
                          },
                          text: "Subir materia"
                      ),

                      //CUENTAS BANCARÍAS
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: Text('Cuentas Bancarias', style: themeApp.styleText(24, true, themeApp.primaryColor)),
                          ),
                          ComboBox<String>(
                            value: selectedTipoCuenta,
                            items: tipoCuentaList.map<ComboBoxItem<String>>((e) {
                              return ComboBoxItem<String>(
                                value: e,
                                child: Text(e),
                              );
                            }).toList(),
                            onChanged: (text) {
                              setState(() {
                                selectedTipoCuenta = text; // Update the local variable
                              });
                            },
                            placeholder: const Text('Tipo de cuenta'),
                          ),
                          RoundedTextField(
                              topMargin: 3,
                              bottomMargin: 3,
                              controller: numeroCuentaBancaria,
                              placeholder: "Numero Cuenta Bancaria"
                          ),
                          RoundedTextField(
                              topMargin: 3,
                              bottomMargin: 3,
                              controller: cedulaTutor,
                              placeholder: "Cedula Cuenta Bancaria"
                          ),
                          RoundedTextField(
                              topMargin: 3,
                              bottomMargin: 3,
                              controller: nombreCedulaTutor,
                              placeholder: "Nombre Cedula"
                          ),
                          PrimaryStyleButton(
                            buttonColor: themeApp.primaryColor,
                              function: (){
                                verificarUploadCuentaBancaria();
                              },
                              text: "Subir Cuenta"
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            );
          }
      );
    }else{
      return const Center(child: material.CircularProgressIndicator());
    }
  }

  Row textoymodificable(String text,String valor,int index, bool active){

    final TextStyle styleText = themeApp.styleText(14, false, themeApp.blackColor);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (!editarcasilla[index])
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  width: widget.currentwith-60,
                  padding: const EdgeInsets.only(bottom: 5.5, right: 10.0, top: 5.5),
                  margin: const EdgeInsets.only(left: 10),
                  child: Text("$text : $valor", style: styleText,)),
              if(!active)
                GestureDetector(
                  onTap: (){
                    setState(() {
                      editarcasilla[index] = !editarcasilla[index]; // Alterna entre los modos de visualización y edición
                    });
                  },
                  child: const Icon(FluentIcons.edit),
                )
            ],
          ),
        if (editarcasilla[index])
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if(index == 1)
                  Flexible(
                    child: TextBox(
                      placeholder: valor,
                      onChanged: (value){
                        setState(() {
                          cambio = value;
                        });
                      },
                      maxLines: null,
                    ),
                  ),
                if(index == 2)
                  Flexible(
                    child: TextBox(
                      placeholder: valor,
                      onChanged: (value){
                        setState(() {
                          cambionum = int.parse(value);
                          cambio = value;
                        });
                      },
                      maxLines: null,
                    ),
                  ),
                if(index == 3)
                  Flexible(
                    child: SizedBox(
                      height: 30,
                      child: AutoSuggestBox<Carrera>(
                        items: CarrerasList.map<AutoSuggestBoxItem<Carrera>>(
                              (carrera) => AutoSuggestBoxItem<Carrera>(
                            value: carrera,
                            label: carrera.nombrecarrera,
                          ),
                        )
                            .toList(),
                        onSelected: (item) {
                          setState(() {
                            selectedCarreraobject = item.value; // Actualizar el valor seleccionado
                            cambio = item.value!.nombrecarrera;
                          });
                        },
                      ),
                    ),
                  ),
                if(index == 5)
                  Flexible(
                    child: SizedBox(
                      height: 30,
                      child: AutoSuggestBox<Universidad>(
                        items: UniversidadList.map<AutoSuggestBoxItem<Universidad>>(
                              (universidad) => AutoSuggestBoxItem<Universidad>(
                            value: universidad,
                            label: universidad.nombreuniversidad,
                          ),
                        )
                            .toList(),
                        onSelected: (item) {
                          setState(() {
                            selectedUniversidadobject = item.value;
                            cambio = item.value!.nombreuniversidad;
                          });
                        },
                      ),
                    ),
                  ),
                if(index==6)
                  ToggleSwitch(
                    checked: activo,
                    onChanged: (bool value) {
                      setState(() {
                        cambio = value.toString();
                        activo = value;
                      });
                    },),

                //actualizar variable
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    CircularButton(
                        iconData: FluentIcons.check_list,
                        function: () async{
                      verificarUploadTutor(index,cambio);
                    }),

                    CircularButton(
                        buttonColor: themeApp.redColor,
                        iconData: FluentIcons.cancel,
                        function: (){
                          setState(() {
                            editarcasilla[index] = !editarcasilla[index];
                          });
                        }),
                  ],
                )

              ],
            ),
          )
      ],
    );
  }

  Future verificarUploadTutor(int index, String cambiotextlocal) async{
    UtilDialogs dialogs = UtilDialogs(context : context);
    if(cambiotextlocal == ""){
      //mensaje de error
      dialogs.error(Strings().errorTextoNulo,Strings().errorglobalText);
    }else{
      await Uploads().modifyinfotutor(index, cambio!, uidtutor,cambionum,context);
      //mensaje de exito
      dialogs.exito(Strings().exitoglobal ,Strings().exitoglobaltitulo);
      setState(() {
        editarcasilla[index] = !editarcasilla[index];
        cambionum = 0;
        cambio = "";
      });
    }
  }

  void verificarUploadMateria(){
    UtilDialogs dialogs = UtilDialogs(context : context);
    if(selectedMateria== null){
      dialogs.error(Strings().errorseleccionemateria,Strings().errorglobalText);
    }else if( materiaListTutor.any((materia) => materia.nombremateria == selectedMateria!.nombremateria)){
      dialogs.error(Strings().errorMateriaRegistrada,Strings().errorglobalText);
    }else{
      Uploads().addMateriaTutor(uidtutor, selectedMateria!.nombremateria);
      dialogs.exito(Strings().exitoglobal ,Strings().exitoglobaltitulo);
    }
  }

  void verificarUploadCuentaBancaria(){
    UtilDialogs dialogs = UtilDialogs(context : context);
    if(selectedTipoCuenta == null || numeroCuentaBancaria == "" || cedulaTutor == "" || nombreCedulaTutor == ""){
      dialogs.error(Strings().errroCuentasBancaria,Strings().errorglobalText);
    }else{
      Uploads().addCuentaBancaria(uidtutor, selectedTipoCuenta!, numeroCuentaBancaria.text, cedulaTutor.text, nombreCedulaTutor.text);
      dialogs.exito(Strings().exitoglobal ,Strings().exitoglobaltitulo);
      setState(() {
        numeroCuentaBancaria.dispose();
        cedulaTutor.dispose();
        nombreCedulaTutor.dispose();
        selectedTipoCuenta = null;
        //Toca reiniciar todas las variables y meter waiting cargando
      });
    }
  }
}

class SecundaryColumnTutores extends StatefulWidget {
  final double currentwith;
  final double currenheight;

  const SecundaryColumnTutores({Key?key,
    required this.currentwith,
    required this.currenheight
  }) :super(key: key);

  @override
  SecundaryColumnTutoresState createState() => SecundaryColumnTutoresState();

}

class SecundaryColumnTutoresState extends State<SecundaryColumnTutores> {

  final ThemeApp themeApp = ThemeApp();
  
  void updateData() {
    setState(() {
      print("actualizando tutor y materias, o eso se cree");
    });
  }

  late bool construct = false;

  @override
  void initState(){
    super.initState();
    WidgetsFlutterBinding.ensureInitialized(); // Asegura que Flutter esté inicializado
    themeApp.initTheme().then((_) {
      setState(()=>construct = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if(construct){
      return Consumer<VistaTutoresProvider>(
        builder: (context, tutorProvider, child) {
          Tutores tutor = tutorProvider.tutorSeleccionado;

          return Container(
            height: widget.currenheight == -1 ? tutor.materias.length*65 : widget.currenheight!,
            width: widget.currentwith,
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            decoration: BoxDecoration(
              color: themeApp.primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListView.builder(
              itemCount: tutor.materias.length,
              itemBuilder: (context, subindex) {
                Materia materia = tutor.materias[subindex];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: themeApp.whitecolor,
                          borderRadius: BorderRadius.circular(80),
                        ),
                        height: 50,
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text("Materia: ", style: themeApp.styleText(15, true, themeApp.grayColor),),
                                  Text(materia.nombremateria, style: themeApp.styleText(14, false, themeApp.grayColor),),
                                ],
                              ),

                              CircularButton(
                                  buttonColor: themeApp.redColor,
                                  iconData: material.Icons.cancel,
                                  function: (){

                                    //Añadir funcion

                                  }),

                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      );  
    }else{
      return const Center(child: material.CircularProgressIndicator());
    }
    
  }
}

class TercerColumnTutores extends StatefulWidget {
  final double currentwith;
  final double currenheight;

  const TercerColumnTutores({Key?key,
    required this.currentwith,
    required this.currenheight
  }) :super(key: key);

  @override
  TercerColumnTutoresState createState() => TercerColumnTutoresState();

}

class TercerColumnTutoresState extends State<TercerColumnTutores> {

  final ThemeApp themeApp = ThemeApp();
  late bool construct = false;

  @override
  void initState(){
    super.initState();
    WidgetsFlutterBinding.ensureInitialized(); // Asegura que Flutter esté inicializado
    themeApp.initTheme().then((_) {
      setState(()=>construct = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if(construct){
      return Consumer<VistaTutoresProvider>(
        builder: (context, tutorProvider, child) {
          Tutores tutor = tutorProvider.tutorSeleccionado;

          return SizedBox(
            height: widget.currenheight == -1 ? tutor.cuentas.length*220 : widget.currenheight!,
            width: widget.currentwith,
            child: ListView.builder(
              itemCount: tutor.cuentas.length,
              itemBuilder: (context, subindex) {
                CuentasBancarias cuenta = tutor.cuentas[subindex];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                  child: Card(
                    backgroundColor: themeApp.grayColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    child: ItemsCard(
                      cardColor: themeApp.grayColor.withOpacity(0),
                      alignementColumn: MainAxisAlignment.start,
                      verticalPadding: 10.0,
                      horizontalPadding: 8.0,
                      shadow: false,
                      children: [
                        Text("Cuenta ${[for(int letra=0; letra<cuenta.tipoCuenta.length; letra++) if(letra == 0) cuenta.tipoCuenta[letra].toUpperCase() else cuenta.tipoCuenta[letra].toLowerCase()].join()}", style: themeApp.styleText(18, true, themeApp.primaryColor),),
                        Column(
                          children: [
                            _textAndTitle(cuenta.nombreCuenta, "Nombre Cuenta:"),
                            _textAndTitle(cuenta.numeroCedula, "Numero Cedula: "),
                            _textAndTitle(cuenta.numeroCuenta, "Numero Cuenta: "),
                            _textAndTitle(cuenta.tipoCuenta, "Tipo Cuenta: "),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    }else{
      return const material.Center(child: material.CircularProgressIndicator(),);
    }
  }

  String _arreglarString(String text){
    final List<String> _arreglar = [];
    return "";
  }

  Padding _textAndTitle(String text, String title){
    final TextStyle styleText = themeApp.styleText(14, false, themeApp.grayColor);
    final TextStyle styleTextSub = themeApp.styleText(15, true, themeApp.grayColor);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: styleTextSub,),
          Text(text, style: styleText,),
        ],
      ),
    );
  }

}