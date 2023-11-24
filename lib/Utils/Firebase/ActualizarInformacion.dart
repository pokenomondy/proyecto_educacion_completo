import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard_admin_flutter/Objetos/CuentasBancaraias.dart';
import 'package:dashboard_admin_flutter/Objetos/Solicitud.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/Load_Data.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Objetos/Clientes.dart';
import '../../Objetos/Cotizaciones.dart';
import '../../Objetos/Objetos Auxiliares/Materias.dart';
import '../../Objetos/Tutores_objet.dart';

class ActualizarInformacion {
  /*
  //Actualizar Tutores
  Future <void> actualizartutores({Function(Tutores)? onTutorAdded}) async {
    print("Actualizando información de tutores en firebase");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool datosDescargados = prefs.getBool('datos_descargados_tablatutores') ?? false;
    if (datosDescargados == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List tutoresList = await LoadData().obtenertutores();
      CollectionReference refenrecetablaTutores = await FirebaseFirestore.instance.collection("TUTORES");
      QuerySnapshot queryTutores = await refenrecetablaTutores.get();
      Set<String> localTutoresList = Set.from(tutoresList.map((tutores) => tutores.uid));
      //Aqui entramos a los tutoresDoc, y primero verificamos que si hay que actualizar o no
      for (var TutorDoc in queryTutores.docs) {
        DateTime actualizarTutoresFirebase = TutorDoc.data().toString().contains('actualizartutores') ? TutorDoc.get('actualizartutores').toDate() : DateTime(2023, 1, 1, 0, 0); //Number
        String uidFirebase = TutorDoc['uid'];
        print("revisando $uidFirebase");

        if(localTutoresList.contains(uidFirebase)){
          Tutores tutorEnLista = tutoresList.where((tutor) => tutor.uid == uidFirebase).first;
          if (onTutorAdded != null) {
            onTutorAdded(tutorEnLista);
          }
          if (tutorEnLista.actualizartutores != actualizarTutoresFirebase) {
            print("se actualiza el tutor ${tutorEnLista.nombrewhatsapp}");
            //Actualizar primero fecha de actualización
            tutorEnLista.actualizartutores = actualizarTutoresFirebase;
            //Actualizar demas variables
            tutorEnLista.nombrewhatsapp = TutorDoc['nombre Whatsapp'];
            tutorEnLista.nombrecompleto = TutorDoc['nombre completo'];
            tutorEnLista.numerowhatsapp = TutorDoc['numero whatsapp'];
            tutorEnLista.carrera = TutorDoc['carrera'];
            tutorEnLista.correogmail = TutorDoc['Correo gmail'];
            tutorEnLista.univerisdad = TutorDoc['Universidad'];
            tutorEnLista.activo = TutorDoc.data().toString().contains('activo') ? TutorDoc.get('activo') : true;
            tutorEnLista.rol = TutorDoc.data().toString().contains('rol') ? TutorDoc.get('rol') : "TUTOR";

            //Mas materias
            QuerySnapshot materiasDocs = await TutorDoc.reference.collection("MATERIA").get();
            List<Materia> materiaList = [];
            for (var materiaDoc in materiasDocs.docs) {
              String nombremateria = materiaDoc['nombremateria'];
              print(nombremateria);

              Materia newmateria = Materia(nombremateria);
              materiaList.add(newmateria);
            }

            //Cargamos cuentas Bancarias
            QuerySnapshot cuentaDocs = await TutorDoc.reference.collection("CUENTAS").get();
            List<CuentasBancarias> cuentasBancariasList = [];
            for (var cuentaDoc in cuentaDocs.docs) {
              String tipoCuenta = cuentaDoc['tipoCuenta'];
              String numeroCuenta = cuentaDoc['numeroCuenta'];
              String numeroCedula = cuentaDoc['numeroCedula'];
              String nombreCuenta = cuentaDoc['nombreCuenta'];

              CuentasBancarias newcuentaBancaria = CuentasBancarias(
                  tipoCuenta, numeroCuenta, numeroCedula, nombreCuenta);
              cuentasBancariasList.add(newcuentaBancaria);
            }

            tutorEnLista.cuentas = cuentasBancariasList;
            tutorEnLista.materias = materiaList;
          }
        }else{
          String nombrewhatsapp = TutorDoc['nombre Whatsapp'];
          String nombrecompleto = TutorDoc['nombre completo'];
          int numerowhatsapp = TutorDoc['numero whatsapp'];
          String carrera = TutorDoc['carrera'];
          String correogmail = TutorDoc['Correo gmail'];
          String univerisdad = TutorDoc['Universidad'];
          String uid = TutorDoc['uid'];
          bool activo = TutorDoc.data().toString().contains('activo') ? TutorDoc.get('activo') : true;
          DateTime actualizartutores = TutorDoc.data().toString().contains('actualizartutores') ? TutorDoc.get('actualizartutores').toDate() : DateTime(2023,1,1,0,0); //Number
          print("se agrega el nuevo tutor $uidFirebase");
          String rol = TutorDoc.data().toString().contains('rol') ? TutorDoc.get('rol') : "TUTOR";

          //Mas materias
          QuerySnapshot materiasDocs = await TutorDoc.reference.collection("MATERIA").get();
          List<Materia> materiaList = [];
          for (var materiaDoc in materiasDocs.docs) {
            String nombremateria = materiaDoc['nombremateria'];
            print(nombremateria);

            Materia newmateria = Materia(nombremateria);
            materiaList.add(newmateria);
          }

          //Cargamos cuentas Bancarias
          QuerySnapshot cuentaDocs = await TutorDoc.reference.collection("CUENTAS").get();
          List<CuentasBancarias> cuentasBancariasList = [];
          for (var cuentaDoc in cuentaDocs.docs) {
            String tipoCuenta = cuentaDoc['tipoCuenta'];
            String numeroCuenta = cuentaDoc['numeroCuenta'];
            String numeroCedula = cuentaDoc['numeroCedula'];
            String nombreCuenta = cuentaDoc['nombreCuenta'];

            CuentasBancarias newcuentaBancaria = CuentasBancarias(
                tipoCuenta, numeroCuenta, numeroCedula, nombreCuenta);
            cuentasBancariasList.add(newcuentaBancaria);
          }

          Tutores newtutor = Tutores(nombrewhatsapp, nombrecompleto, numerowhatsapp, carrera, correogmail, univerisdad, uid, materiaList, cuentasBancariasList, activo, actualizartutores,rol);
          tutoresList.add(newtutor);
          if (onTutorAdded != null) {
            onTutorAdded(newtutor);
          }
        }

      }
      String updatedTutoresJson = jsonEncode(tutoresList.map((tutor) => tutor.toJson()).toList());
      prefs.setString('tutores_list', updatedTutoresJson);
    }
  }

  /*
  Future <void> actualizarsolicitudes({Function(Solicitud)? onSolicitudAddedd}) async {
    print("Actualizando información de solicitudes en firebase");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool datosDescargados = prefs.getBool('datos_descargados_listasolicitudes') ?? false;

    if (datosDescargados == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List solicitudesList = await LoadData().obtenerSolicitudes();
      CollectionReference referencelistasolicitudes = FirebaseFirestore.instance.collection("SOLICITUDES");
      QuerySnapshot querySolicitudes = await referencelistasolicitudes.get();
      // Encuentra el valor máximo de idcotizacion en tu lista local
      int maxIdCotizacionLocal = 0;
      for (var solicitud in solicitudesList) {
        if (solicitud.idcotizacion > maxIdCotizacionLocal) {
          maxIdCotizacionLocal = solicitud.idcotizacion;
        }
      }
      // Crear un conjunto de IDs de solicitudes locales
      Set<int> localSolicitudIDs = Set.from(solicitudesList.map((solicitud) => solicitud.idcotizacion));
      for (var SolicitudDoc in querySolicitudes.docs) {
        DateTime actualizarsolicitudesFirebase = SolicitudDoc.data().toString().contains('actualizarsolicitudes')
            ? SolicitudDoc['actualizarsolicitudes'].toDate()
            : DateTime(2023, 1, 1, 0, 0);
        int idcotizacionfirebase = SolicitudDoc['idcotizacion'];
        //  bool solicitudExisteEnLocal = solicitudesList.any((solicitud) => solicitud.idcotizacion == idcotizacionfirebase);
        print("id cotizacion a revisar $idcotizacionfirebase");
        if (localSolicitudIDs.contains(idcotizacionfirebase)) {
          Solicitud solicitudEnLista = solicitudesList.where((solicitud) => solicitud.idcotizacion == idcotizacionfirebase).first;
          if (onSolicitudAddedd != null) {
            onSolicitudAddedd(solicitudEnLista);
          }
              if (solicitudEnLista.actualizarsolicitudes != actualizarsolicitudesFirebase) {
            solicitudEnLista.servicio = SolicitudDoc['Servicio'];
            solicitudEnLista.materia = SolicitudDoc['materia'];
            solicitudEnLista.fechaentrega = SolicitudDoc['fechaentrega'].toDate();
            solicitudEnLista.resumen = SolicitudDoc['resumen'];
            solicitudEnLista.infocliente = SolicitudDoc['infocliente'];
            solicitudEnLista.actualizarsolicitudes = actualizarsolicitudesFirebase;
            print("se actualizo la $idcotizacionfirebase");

            QuerySnapshot cotizacionDocs = await SolicitudDoc.reference.collection("COTIZACIONES").get();
            List<Cotizacion> cotizaciones = [];
            for(var cotizacionDoc in cotizacionDocs.docs){
              int cotizacionTutor = cotizacionDoc['Cotizacion'];
              String uidtutor = cotizacionDoc['uidtutor'];
              String nombretutor = cotizacionDoc['nombretutor'];
              int tiempoconfirmacion = cotizacionDoc['Tiempo confirmacion'];
              String comentariocotizacion = cotizacionDoc['Comentario Cotización'];
              String Agenda = cotizacionDoc['Agenda'];
              DateTime fechaconfirmacion = cotizacionDoc.data().toString().contains('fechaconfirmacion') ? cotizacionDoc.get('fechaconfirmacion').toDate() : DateTime.now(); //Number

              Cotizacion newcotizacion = Cotizacion(cotizacionTutor, uidtutor, nombretutor, tiempoconfirmacion, comentariocotizacion, Agenda, fechaconfirmacion);
              cotizaciones.add(newcotizacion);

            }
            solicitudEnLista.cotizaciones = cotizaciones;
          }else{
            print("no se hizo nada con $idcotizacionfirebase");
          }
        }else{
          print("nueva cotizacion por hacer $actualizarsolicitudesFirebase");
          String servicio = SolicitudDoc['Servicio'];
          int idcotizacion = SolicitudDoc['idcotizacion'];
          String materia = SolicitudDoc['materia'];
          DateTime fechaentrega = SolicitudDoc['fechaentrega'].toDate();
          String resumen = SolicitudDoc['resumen'];
          String infocliente = SolicitudDoc['infocliente'];
          int cliente = SolicitudDoc['cliente'];
          DateTime fechasistema = SolicitudDoc['fechasistema'].toDate();
          String estado = SolicitudDoc['Estado'];
          DateTime fechaactualizacion = SolicitudDoc.data().toString().contains('fechaactualizacion') ? SolicitudDoc.get('fechaactualizacion').toDate() : DateTime(2023,1,1,0,0); //Number
          String urlarchivo = SolicitudDoc.data().toString().contains('archivos') ? SolicitudDoc.get('archivos') : 'No tiene Archivos';
          DateTime actualizarsolicitudes = SolicitudDoc.data().toString().contains('actualizarsolicitudes') ? SolicitudDoc.get('actualizarsolicitudes').toDate() : DateTime(2023,1,1,0,0); //Number
          QuerySnapshot cotizacionDocs = await SolicitudDoc.reference.collection("COTIZACIONES").get();
          List<Cotizacion> cotizaciones = [];
          for(var cotizacionDoc in cotizacionDocs.docs){
            int cotizacionTutor = cotizacionDoc['Cotizacion'];
            String uidtutor = cotizacionDoc['uidtutor'];
            String nombretutor = cotizacionDoc['nombretutor'];
            int tiempoconfirmacion = cotizacionDoc['Tiempo confirmacion'];
            String comentariocotizacion = cotizacionDoc['Comentario Cotización'];
            String Agenda = cotizacionDoc['Agenda'];
            DateTime fechaconfirmacion = cotizacionDoc.data().toString().contains('fechaconfirmacion') ? cotizacionDoc.get('fechaconfirmacion').toDate() : DateTime.now(); //Number

            Cotizacion newcotizacion = Cotizacion(cotizacionTutor, uidtutor, nombretutor, tiempoconfirmacion, comentariocotizacion, Agenda, fechaconfirmacion);
            cotizaciones.add(newcotizacion);
          }
          Solicitud newsolicitud = Solicitud(servicio, idcotizacion, materia, fechaentrega, resumen, infocliente, cliente, fechasistema, estado, cotizaciones, fechaactualizacion, urlarchivo, actualizarsolicitudes);
          solicitudesList.add(newsolicitud);
          if (onSolicitudAddedd != null) {
            onSolicitudAddedd(newsolicitud);
          }
        }
      }
      String updatedTutoresJson = jsonEncode(solicitudesList.map((solicitud) => solicitud.toJson()).toList());
      prefs.setString('solicitudes_list', updatedTutoresJson);
    }
  }
   */

  //Actualziar lista de clientes
  Future<void> actualizarclientes({Function(Clientes)? onClienteAdded,Function(int)? TotalClientes}) async{
    print("Actualizando información de clientes en firebase");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool datosDescargados = prefs.getBool('datos_descargados_tablaclientes') ?? false;
    if (datosDescargados == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List clientList = await LoadData().obtenerclientes();
      CollectionReference refenrecetablaClientes = await FirebaseFirestore.instance.collection("CLIENTES");
      QuerySnapshot queryClientes = await refenrecetablaClientes.get();
      Set<String> localClienteList = Set.from(clientList.map((cliente) => cliente.numero.toString()));
      if (TotalClientes != null) {
        TotalClientes(queryClientes.size);
      }
      //Iteramos dentro de la lista de clientes de firebase para generar actualización
      for(var ClienteDoc in queryClientes.docs){
        DateTime fechaActualizacionfirebase = ClienteDoc.data().toString().contains('fechaActualizacion') ? ClienteDoc.get('fechaActualizacion').toDate() : DateTime(2023,1,1,0,0); //Number
        int numero = ClienteDoc['numero'];
        print("revisando tal numero $numero");

        if(localClienteList.contains(numero.toString())){
          Clientes clienteEnLista = clientList.where((cliente) => cliente.numero == numero).first;
          if (onClienteAdded != null) {
            onClienteAdded(clienteEnLista);
          }
          if (clienteEnLista.fechaActualizacion != fechaActualizacionfirebase) {
            print("se actualiza el tutor ${clienteEnLista.numero}");
            clienteEnLista.fechaActualizacion = fechaActualizacionfirebase;
            clienteEnLista.carrera = ClienteDoc['Carrera'];
            clienteEnLista.nombreCliente = ClienteDoc['nombreCliente'];
            clienteEnLista.nombrecompletoCliente =  ClienteDoc.data().toString().contains('nombrecompletoCliente') ? ClienteDoc.get('nombrecompletoCliente') : 'NO REGISTRADO';
            clienteEnLista.universidad = ClienteDoc['Universidadd'];

          }else{
            print("no se hace nada con el numero $numero");
          }
        }else{
          String Carreranew = ClienteDoc['Carrera'];
          String Universidadnew = ClienteDoc['Universidadd'];
          String nombreClientenew = ClienteDoc['nombreCliente'];
          int numeronew = ClienteDoc['numero'];
          String nombrecompletoClientenew = ClienteDoc.data().toString().contains('nombrecompletoCliente') ? ClienteDoc.get('nombrecompletoCliente') : 'NO REGISTRADO';
          DateTime fechaActualizacionnew = ClienteDoc.data().toString().contains('fechaActualizacion') ? ClienteDoc.get('fechaActualizacion').toDate() : DateTime(2023,1,1,0,0); //Number

          Clientes newClientes = Clientes(Carreranew, Universidadnew, nombreClientenew, numeronew,nombrecompletoClientenew,fechaActualizacionnew);
          clientList.add(newClientes);

          print("se agrega el tutor ${numero}");
          if (onClienteAdded != null) {
            onClienteAdded(newClientes);
          }

        }
      }
      String updatedTutoresJson = jsonEncode(clientList.map((cliente) => cliente.toJson()).toList());
      prefs.setString('clientes_list', updatedTutoresJson);
    }
  }

   */
}