import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard_admin_flutter/Objetos/CuentasBancaraias.dart';
import 'package:dashboard_admin_flutter/Objetos/Solicitud.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/Load_Data.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Objetos/Cotizaciones.dart';
import '../../Objetos/Objetos Auxiliares/Materias.dart';
import '../../Objetos/Tutores_objet.dart';

class ActualizarInformacion {

  //Actualizar Tutores - Logrado
  void actualizartutores() async {
    print("Actualizando información de tutores en firebase");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool datosDescargados = prefs.getBool('datos_descargados_tablatutores') ??
        false;
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
        Tutores tutorEnLista = tutoresList.where((tutor) => tutor.uid == uidFirebase).first;
        print("tutlro en lista $tutorEnLista");

        if (localTutoresList.contains(uidFirebase)) {
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
          }
        } else {
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
          List<Materia> materias = [];
          List<CuentasBancarias> cuentas = [];

          Tutores newtutor = Tutores(nombrewhatsapp, nombrecompleto, numerowhatsapp, carrera, correogmail, univerisdad, uid, materias, cuentas, activo, actualizartutores);
          tutoresList.add(newtutor);
        }

      }
      String updatedTutoresJson = jsonEncode(tutoresList.map((tutor) => tutor.toJson()).toList());
      prefs.setString('tutores_list', updatedTutoresJson);
    }
  }

  //Actualizar solicitudes
  void actualizarsolicitudes() async {
    print("Actualizando información de solicitudes en firebase");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool datosDescargados = prefs.getBool('datos_descargados_listasolicitudes') ?? false;

    if (datosDescargados == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List solicitudesList = await LoadData().obtenerSolicitudes();
      CollectionReference referencelistasolicitudes = FirebaseFirestore.instance
          .collection("SOLICITUDES");
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
              if (solicitudEnLista.actualizarsolicitudes != actualizarsolicitudesFirebase) {
            solicitudEnLista.servicio = SolicitudDoc['Servicio'];
            solicitudEnLista.materia = SolicitudDoc['materia'];
            solicitudEnLista.fechaentrega = SolicitudDoc['fechaentrega'].toDate();
            solicitudEnLista.resumen = SolicitudDoc['resumen'];
            solicitudEnLista.infocliente = SolicitudDoc['infocliente'];
            solicitudEnLista.actualizarsolicitudes = actualizarsolicitudesFirebase;
            print("se actualizo la $idcotizacionfirebase");
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
          List<Cotizacion> cotizaciones = []; //meter cotizaciones dios mio
          Solicitud newsolicitud = Solicitud(servicio, idcotizacion, materia, fechaentrega, resumen, infocliente, cliente, fechasistema, estado, cotizaciones, fechaactualizacion, urlarchivo, actualizarsolicitudes);
          solicitudesList.add(newsolicitud);
        }
      }
      String updatedTutoresJson = jsonEncode(solicitudesList.map((solicitud) => solicitud.toJson()).toList());
      prefs.setString('solicitudes_list', updatedTutoresJson);
    }
  }
}