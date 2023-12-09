import '../../Objetos/AgendadoServicio.dart';
import '../../Objetos/Cotizaciones.dart';
import '../../Objetos/Objetos Auxiliares/Materias.dart';
import '../../Objetos/Solicitud.dart';
import '../../Objetos/Tutores_objet.dart';

class TutorEvaluator {
  List<Solicitud> solicitudesList;
  List<ServicioAgendado> serviciosagendadosList;
  List<Tutores> tutoresFiltrados;
  Materia? selectedMateria;
  Map<String, Map<String, double>> tutorNotas = {};

  TutorEvaluator(this.solicitudesList, this.serviciosagendadosList,
      this.tutoresFiltrados, this.selectedMateria){
    tutorcalificacion(); // Call a method to calculate tutorNotas upon initialization
  }

  //# de cotizaciones globales
  int getNumeroCotizacionesGlobal(String tutorName) {
    int cotizacionCount = 0;

    for (Solicitud solicitud in solicitudesList) {
      for (Cotizacion cotizacion in solicitud.cotizaciones) {
        if (cotizacion.nombretutor == tutorName) {
          cotizacionCount++;
        }
      }
    }

    return cotizacionCount;
  }
  void getnotanumcotizacionesglobal(){
    //# de cotizaciones tutores Global
      int numcotizacionesglobalmax = tutoresFiltrados.isNotEmpty
          ? tutoresFiltrados.map((tutor) => getNumeroCotizacionesGlobal(tutor.nombrewhatsapp)).reduce((a, b) => a > b ? a : b)
          : 0;
      int numcotizacionesglobalmin = tutoresFiltrados.isNotEmpty
          ? tutoresFiltrados
          .map((tutor) => getNumeroCotizacionesGlobal(tutor.nombrewhatsapp))
          .where((cotizaciones) => cotizaciones >= 0) // Filtrar valores mayores a cero
          .reduce((a, b) => a < b ? a : b)
          : 0;

    int rangenumcotizacionesglobal = numcotizacionesglobalmax-numcotizacionesglobalmin;
    tutoresFiltrados.forEach((tutor) {
      int cotizaciones = getNumeroCotizacionesGlobal(tutor.nombrewhatsapp);

      double nota = 1+ ((cotizaciones - numcotizacionesglobalmin) / rangenumcotizacionesglobal) * 4;
      tutorNotas.putIfAbsent(tutor.nombrewhatsapp, () => {});

      //ver si tiene < de 10 cotizaciones cotizadas
      tutorNotas[tutor.nombrewhatsapp]?['num_materiasglobal'] = nota;
    });
  }
  //# dw cotizaciones materia
  int getNumeroCotizaciones(String tutorName, String materia) {
    int cotizacionCount = 0;

    for (Solicitud solicitud in solicitudesList) {
      if (solicitud.materia == null) {
        // Verifica si solicitud.materia es nulo y salta esta solicitud
        continue;
      }
      for (Cotizacion cotizacion in solicitud.cotizaciones) {
        if (cotizacion.nombretutor == tutorName && solicitud.materia == materia) {
          cotizacionCount++;
        }
      }
    }


    return cotizacionCount;
  }
  void getnotanumcotizaciones(){

    int numcotizacionesmateriamax = tutoresFiltrados.isNotEmpty
        ? tutoresFiltrados.map((tutor) => getNumeroCotizaciones(tutor.nombrewhatsapp, selectedMateria!.nombremateria)).reduce((a, b) => a > b ? a : b)
        : 0;
    int numcotizacionesmateriamin = tutoresFiltrados.isNotEmpty
        ? tutoresFiltrados
        .map((tutor) => getNumeroCotizaciones(tutor.nombrewhatsapp, selectedMateria!.nombremateria))
        .where((cotizaciones) => cotizaciones >= 0) // Filtrar valores mayores a cero
        .reduce((a, b) => a < b ? a : b)
        : 0;


    int rangenumcotizacioneslocal = numcotizacionesmateriamax-numcotizacionesmateriamin;
    tutoresFiltrados.forEach((tutor) {
      int cotizaciones = getNumeroCotizaciones(tutor.nombrewhatsapp,selectedMateria!.nombremateria);
      if(cotizaciones == 0 && numcotizacionesmateriamin == 0 && numcotizacionesmateriamax == 0){
        double nota = 1+ ((cotizaciones - numcotizacionesmateriamin) / rangenumcotizacioneslocal) * 4;
        tutorNotas.putIfAbsent(tutor.nombrewhatsapp, () => {});
        tutorNotas[tutor.nombrewhatsapp]?['num_materiaslocal'] = 5;
      }else{
        double nota = 1+ ((cotizaciones - numcotizacionesmateriamin) / rangenumcotizacioneslocal) * 4;
        tutorNotas.putIfAbsent(tutor.nombrewhatsapp, () => {});
        tutorNotas[tutor.nombrewhatsapp]?['num_materiaslocal'] = nota;
      }

    });
  }
  //promedio de respuesta tutor global
  double getPromedioRespuesta(String tutorName) {
    int totalResponseTime = 0;
    int cotizacionCount = 0;

    for (Solicitud solicitud in solicitudesList) {
      for (Cotizacion cotizacion in solicitud.cotizaciones) {
        if (cotizacion.nombretutor == tutorName) {
          totalResponseTime += cotizacion.tiempoconfirmacion ?? 0;
          cotizacionCount++;
        }
      }
    }

    if (cotizacionCount > 0) {
      return totalResponseTime / cotizacionCount;
    } else {
      return 0.0;
    }
  }
  void getnotapromediorespuesta(){
    //%respuesta de tutor global
    double promrespuestamaxglobal = tutoresFiltrados.isNotEmpty
        ? tutoresFiltrados.map((tutor) => getPromedioRespuesta(tutor.nombrewhatsapp)).reduce((a, b) => a > b ? a : b)
        : 0;
    double promrespuestaminglobal = tutoresFiltrados.isNotEmpty
        ? tutoresFiltrados
        .map((tutor) => getPromedioRespuesta(tutor.nombrewhatsapp))
        .where((cotizaciones) => cotizaciones >= 0) // Filtrar valores mayores a cero
        .reduce((a, b) => a < b ? a : b)
        : 0;

    double rangepromrespuiestaglobal = promrespuestamaxglobal-promrespuestaminglobal;
    tutoresFiltrados.forEach((tutor) {
      double cotizaciones = getPromedioRespuesta(tutor.nombrewhatsapp);

      double nota = 0.0;
      if (cotizaciones == promrespuestaminglobal) {
        nota = 5.0;
      } else if(getPromedioRespuesta(tutor.nombrewhatsapp)==0){
        nota = 1.0;
      } else {
        nota = 5.0 - (4.0 * (cotizaciones / promrespuestamaxglobal));
      }
      tutorNotas.putIfAbsent(tutor.nombrewhatsapp, () => {});
      tutorNotas[tutor.nombrewhatsapp]?['prom_respuestaglobal'] = nota.abs();

    });

  }

  //promedio de respuesta tutor local
  double getPromedioRespuestaMateria(String tutorName, String materia)  {
    int totalResponseTime = 0;
    int cotizacionCount = 0;

    for (Solicitud solicitud in solicitudesList) {
      if (solicitud.materia == null ) {
        // Verifica si solicitud.materia es nulo y salta esta solicitud
        continue;
      }
      for (Cotizacion cotizacion in solicitud.cotizaciones) {
        if (cotizacion.nombretutor == tutorName &&
            solicitud.materia == materia) {
          totalResponseTime += cotizacion.tiempoconfirmacion ?? 0;
          cotizacionCount++;
        }
      }
    }

    return cotizacionCount > 0 ? totalResponseTime / cotizacionCount : 0.0;
  }
  void getnotapromediorespuestamateria(){
    //%respuesta de tutor materia local
    double promrespuestamaxlocal = tutoresFiltrados.isNotEmpty
        ? tutoresFiltrados.map((tutor) => getPromedioRespuestaMateria(tutor.nombrewhatsapp,selectedMateria!.nombremateria)).reduce((a, b) => a > b ? a : b)
        : 0;
    double promrespuestaminlocal = tutoresFiltrados.isNotEmpty
        ? tutoresFiltrados
        .map((tutor) => getPromedioRespuestaMateria(tutor.nombrewhatsapp,selectedMateria!.nombremateria))
        .where((cotizaciones) => cotizaciones >= 0) // Filtrar valores mayores a cero
        .reduce((a, b) => a < b ? a : b)
        : 0;

    double rangepromrespuiestalocal = promrespuestamaxlocal-promrespuestaminlocal;
    tutoresFiltrados.forEach((tutor) {
      double cotizaciones = getPromedioRespuestaMateria(tutor.nombrewhatsapp,selectedMateria!.nombremateria);

      double nota = 0.0;
      if (cotizaciones == promrespuestaminlocal) {
        nota = 5.0;
      } else {
        nota = 5.0 - (4.0 * (cotizaciones / promrespuestamaxlocal));
      }
      tutorNotas.putIfAbsent(tutor.nombrewhatsapp, () => {});
      tutorNotas[tutor.nombrewhatsapp]?['prom_respuestalocal'] = nota.abs();

    });

  }
  //obtener precio de tutor en solicitudes global

  double getPromedioPrecioTutor(String tutorName) {
    int totalCotizacionPrice = 0;
    int cotizacionCount = 0;

    for (Solicitud solicitud in solicitudesList) {
      for (Cotizacion cotizacion in solicitud.cotizaciones) {
        if (cotizacion.nombretutor == tutorName) {
          totalCotizacionPrice += cotizacion.cotizacion;
          cotizacionCount++;
        }
      }
    }

    if (cotizacionCount > 0) {
      return totalCotizacionPrice / cotizacionCount.toDouble();
    } else {
      return 0.0;
    }
  }
  void getnotapromediopreciotutroglobalsolicitudes(){
    //% precio global, promedio
    double promprecioglobalmax = tutoresFiltrados.isNotEmpty
        ? tutoresFiltrados.map((tutor) => getPromedioPrecioTutor(tutor.nombrewhatsapp)).reduce((a, b) => a > b ? a : b)
        : 0;
    double promprecioglobalmin = tutoresFiltrados.isNotEmpty
        ? tutoresFiltrados
        .map((tutor) => getPromedioPrecioTutor(tutor.nombrewhatsapp))
        .where((cotizaciones) => cotizaciones >= 0) // Filtrar valores mayores a cero
        .reduce((a, b) => a < b ? a : b)
        : 0;


    double rangepromprecioglobal = promprecioglobalmax-promprecioglobalmin;
    tutoresFiltrados.forEach((tutor) {
      double cotizaciones = getPromedioPrecioTutor(tutor.nombrewhatsapp);
      double nota = 0.0;
      if (cotizaciones == promprecioglobalmin) {
        nota = 5.0;
      } else {
        nota = 5.0 - (4.0 * (cotizaciones / promprecioglobalmax));
      }

      tutorNotas.putIfAbsent(tutor.nombrewhatsapp, () => {});
      tutorNotas[tutor.nombrewhatsapp]?['prom_precioglobal'] = nota.abs();
    });

  }

  //obtener precio de tutor en solicitudes de la matería
  double getPromedioPrecioTutorMateria(String tutorName, String materia) {
    int totalCotizacionPrice = 0;
    int cotizacionCount = 0;

    for (Solicitud solicitud in solicitudesList) {
      if (solicitud.materia == null ) {
        // Verifica si solicitud.materia es nulo y salta esta solicitud
        continue;
      }
      for (Cotizacion cotizacion in solicitud.cotizaciones) {
        if (cotizacion.nombretutor == tutorName &&
            solicitud.materia == materia) {
          totalCotizacionPrice += cotizacion.cotizacion;
          cotizacionCount++;
        }
      }
    }

    if (cotizacionCount > 0) {
      return totalCotizacionPrice / cotizacionCount.toDouble();
    } else {
      return 0.0;
    }
  }
  void getnotapromediopreciotutormateria(){
    //% precio global materia, promedio
    double promprecioglobalmaxmateria = tutoresFiltrados.isNotEmpty
        ? tutoresFiltrados.map((tutor) => getPromedioPrecioTutorMateria(tutor.nombrewhatsapp,selectedMateria!.nombremateria)).reduce((a, b) => a > b ? a : b)
        : 0;
    double promprecioglobalminmateria = tutoresFiltrados.isNotEmpty
        ? tutoresFiltrados.map((tutor) => getPromedioPrecioTutorMateria(tutor.nombrewhatsapp,selectedMateria!.nombremateria)).reduce((a, b) => a < b ? a : b)
        : 0;

    double rangepromprecioglobalmateria = promprecioglobalmaxmateria-promprecioglobalminmateria;
    tutoresFiltrados.forEach((tutor) {
      double cotizaciones = getPromedioPrecioTutorMateria(tutor.nombrewhatsapp,selectedMateria!.nombremateria);
      double nota = 0.0;
      if (cotizaciones == promprecioglobalminmateria) {
        nota = 5.0;
      } else {
        nota = 5.0 - (4.0 * (cotizaciones / promprecioglobalmaxmateria));
      }
      tutorNotas.putIfAbsent(tutor.nombrewhatsapp, () => {});
      tutorNotas[tutor.nombrewhatsapp]?['prom_precioglobalmateria'] = nota.abs();
    });
  }

  //obtener numero de servicios agendadas
  int getNumeroCotizacionesAgendado(String tutorName) {
    int cotizacionCount = 0;

    for (ServicioAgendado servicios in serviciosagendadosList) {
      if (servicios.tutor == tutorName) {
        cotizacionCount++;
      }
    }
    return cotizacionCount;
  }
  void getnotanumerocotizacionesagendado(){
    int numserviciosagendadosmax = tutoresFiltrados.isNotEmpty
        ? tutoresFiltrados.map((tutor) => getNumeroCotizacionesAgendado(tutor.nombrewhatsapp)).reduce((a, b) => a > b ? a : b)
        : 0;
    int numserviciosagendadosmin = tutoresFiltrados.isNotEmpty
        ? tutoresFiltrados
        .map((tutor) => getNumeroCotizacionesAgendado(tutor.nombrewhatsapp))
        .reduce((a, b) => a < b ? a : b)
        : 0;

    int rangenumeroserviciosagendados = numserviciosagendadosmax-numserviciosagendadosmin;
    tutoresFiltrados.forEach((tutor) {
      int cotizaciones = getNumeroCotizacionesAgendado(tutor.nombrewhatsapp);
      double nota = 1+ ((cotizaciones - numserviciosagendadosmin) / rangenumeroserviciosagendados) * 4;
      tutorNotas.putIfAbsent(tutor.nombrewhatsapp, () => {});
        tutorNotas[tutor.nombrewhatsapp]?['num_serviciosagedndados'] = nota;
    });
  }

  //obtener numero de servicios agendados de materia
  int getNumeroCotizacionesAgendadoMateria(String tutorName,String materia) {
    int cotizacionCount = 0;

    for (ServicioAgendado servicios in serviciosagendadosList) {
      if (servicios.materia == null) {
        // Verifica si solicitud.materia es nulo y salta esta solicitud
        continue;
      }
      if (servicios.tutor == tutorName && servicios.materia == materia) {
        cotizacionCount++;
      }
    }
    return cotizacionCount;
  }
  void getnotanumerocotizacionesagendadoMateria(){
    int numserviciosagendadosmaxmateria = tutoresFiltrados.isNotEmpty
        ? tutoresFiltrados.map((tutor) => getNumeroCotizacionesAgendadoMateria(tutor.nombrewhatsapp,selectedMateria!.nombremateria)).reduce((a, b) => a > b ? a : b)
        : 0;
    int numserviciosagendadosminmateria = tutoresFiltrados.isNotEmpty
        ? tutoresFiltrados.map((tutor) => getNumeroCotizacionesAgendadoMateria(tutor.nombrewhatsapp,selectedMateria!.nombremateria)).reduce((a, b) => a < b ? a : b)
        : 0;

    int rangenumeroserviciosagendados = numserviciosagendadosmaxmateria-numserviciosagendadosminmateria;
    tutoresFiltrados.forEach((tutor) {
      int cotizaciones = getNumeroCotizacionesAgendadoMateria(tutor.nombrewhatsapp,selectedMateria!.nombremateria);
      double nota = 1+ ((cotizaciones - numserviciosagendadosminmateria) / rangenumeroserviciosagendados) * 4;
      tutorNotas.putIfAbsent(tutor.nombrewhatsapp, () => {});
      if(rangenumeroserviciosagendados==0){
        tutorNotas[tutor.nombrewhatsapp]?['num_serviciosagedndadosmateria'] = 0;
      }else{
        tutorNotas[tutor.nombrewhatsapp]?['num_serviciosagedndadosmateria'] = nota;
      }
    });
  }
  //obtener promedio de preciocobradotutor
  double gerpromedioprecioglobalagendado(String tutorName){
    double totalCotizacionPrice = 0;
    double cotizacionCount = 0;

    for (ServicioAgendado servicio in serviciosagendadosList) {
      if (servicio.tutor == tutorName) {
        totalCotizacionPrice += servicio.preciotutor;
        cotizacionCount++;
      }
    }

    if (cotizacionCount > 0) {
      return totalCotizacionPrice / cotizacionCount.toDouble();
    } else {
      return 0.0;
    }
  }
  void getnotapromedioprecioglobalagendado(){
    double promprecioagendadomax = tutoresFiltrados.isNotEmpty
        ? tutoresFiltrados.map((tutor) => gerpromedioprecioglobalagendado(tutor.nombrewhatsapp)).reduce((a, b) => a > b ? a : b)
        : 0;
    double promprecioagendadomin = tutoresFiltrados.isNotEmpty
        ? tutoresFiltrados
        .map((tutor) => gerpromedioprecioglobalagendado(tutor.nombrewhatsapp))
        .where((cotizaciones) => cotizaciones >= 0) // Filtrar valores mayores a cero
        .reduce((a, b) => a < b ? a : b)
        : 0;


    double rangepromprecioglobal = promprecioagendadomax-promprecioagendadomin;
    tutoresFiltrados.forEach((tutor) {
      double cotizaciones = gerpromedioprecioglobalagendado(tutor.nombrewhatsapp);
      double nota = 0.0;
      if (cotizaciones == 0.0) {
        nota = 0.0;
      }else if (cotizaciones == promprecioagendadomin) {
        nota = 5.0;
      } else {
        nota = 5.0 - (4.0 * (cotizaciones / promprecioagendadomax));
      }

      tutorNotas.putIfAbsent(tutor.nombrewhatsapp, () => {});
      tutorNotas[tutor.nombrewhatsapp]?['prom_precioagendadosglobal'] = nota.abs();
    });
  }

  //obtener promedio de ganancias generadas
  double getpromediogananciasgeneradas(String tutorName){
    double totalCotizacionPrice = 0;
    double cotizacionCount = 0;

    for (ServicioAgendado servicio in serviciosagendadosList) {
      if (servicio.tutor == tutorName) {
        totalCotizacionPrice += (servicio.preciocobrado - servicio.preciotutor);
        cotizacionCount++;
      }
    }

    if (cotizacionCount > 0) {
      return totalCotizacionPrice / cotizacionCount.toDouble();
    } else {
      return 0.0;
    }
  }
  void getnotapromedioganancias(){
    double promprecioganaciamax = tutoresFiltrados.isNotEmpty
        ? tutoresFiltrados.map((tutor) => getpromediogananciasgeneradas(tutor.nombrewhatsapp)).reduce((a, b) => a > b ? a : b)
        : 0;
    double prompreciogananciamin = tutoresFiltrados.isNotEmpty
        ? tutoresFiltrados
        .map((tutor) => getpromediogananciasgeneradas(tutor.nombrewhatsapp))
        .where((cotizaciones) => cotizaciones >= 0) // Filtrar valores mayores a cero
        .reduce((a, b) => a < b ? a : b)
        : 0;

    double rangepromganancialobal = promprecioganaciamax-prompreciogananciamin;
    tutoresFiltrados.forEach((tutor) {
      double cotizaciones = getpromediogananciasgeneradas(tutor.nombrewhatsapp);
      double nota = 1+ ((cotizaciones-prompreciogananciamin)/rangepromganancialobal)*4;

      tutorNotas.putIfAbsent(tutor.nombrewhatsapp, () => {});
      tutorNotas[tutor.nombrewhatsapp]?['prom_preciogananciasglobal'] = nota.abs();
    });
  }



  void tutorcalificacion(){
    getnotanumcotizacionesglobal();
    getnotanumcotizaciones();
    getnotapromediorespuesta();
    getnotapromediorespuestamateria();
    getnotapromediopreciotutroglobalsolicitudes();
    getnotapromediopreciotutormateria();
    getnotanumerocotizacionesagendado();
    getnotanumerocotizacionesagendadoMateria();
    getnotapromedioprecioglobalagendado();
    getnotapromedioganancias();
    //# de servicios agendados
  }
  double retornocalificacion(Tutores tutore){
    double numeroglobalcotizacion = tutorNotas[tutore.nombrewhatsapp]?['num_materiasglobal'] ?? 0.0;
    double numerolocalmateriacotizacion = tutorNotas[tutore.nombrewhatsapp]?['num_materiaslocal'] ?? 0.0;
    double promrespuestaglobal = tutorNotas[tutore.nombrewhatsapp]?['prom_respuestaglobal'] ?? 0.0;
    double promrespuestalocal = tutorNotas[tutore.nombrewhatsapp]?['prom_respuestalocal'] ?? 0.0;
    double promprecioglobal = tutorNotas[tutore.nombrewhatsapp]?['prom_precioglobal'] ?? 0.0;
    double prompreciolocal = tutorNotas[tutore.nombrewhatsapp]?['prom_precioglobalmateria'] ?? 0.0;
    double numeroserviciosagendados = tutorNotas[tutore.nombrewhatsapp]?['num_serviciosagedndados'] ?? 0.0;
    double numeroserviciosagendadosmateria = tutorNotas[tutore.nombrewhatsapp]?['num_serviciosagedndadosmateria'] ?? 0.0;
    double promprecioagendado = tutorNotas[tutore.nombrewhatsapp]?['prom_precioagendadosglobal'] ?? 0.0;
    double promprecioganancias = tutorNotas[tutore.nombrewhatsapp]?['prom_preciogananciasglobal'] ?? 0.0;
    DateTime? fechaultimacalificacion = ultimaFechaCotizacionTutor(tutore.nombrewhatsapp);
    //el periodo de prueba de un tutor debe ser de 1 mes, y minimo los 10, ahí les damos de nota 5.0 para dejarlos cotizar
    //y ver en que se destacan

    double notaoficial = (numeroglobalcotizacion+numerolocalmateriacotizacion+promrespuestaglobal
        +promrespuestalocal+promprecioglobal+prompreciolocal+numeroserviciosagendados+numeroserviciosagendadosmateria
    +promprecioagendado+promprecioganancias)/10;


    print("${tutore.nombrewhatsapp} cotizo la ultima vez $fechaultimacalificacion ${ultimos20dias(fechaultimacalificacion!)}");

    //Aqui tenemos <= 15 solicitudes, tambien toca meter un tiempo de pruegba de 1 mes puede ser tambien
    //Toca comprobar la fecha de enlistamiento del tutor, para poder saber cuantos osn
    if(getNumeroCotizacionesGlobal(tutore.nombrewhatsapp) <= 10){
      if(!ultimos20dias(fechaultimacalificacion)){
        return notaoficial;
      }else{
        return 5;
      }
    }else{
      return notaoficial;
    }
  }

  //ver la ultima cotización del tutor
  DateTime? ultimaFechaCotizacionTutor(String tutorname) {
    Cotizacion? ultimaCotizacion;
    DateTime? fechaUltimaCotizacion;

    for (Solicitud solicitud in solicitudesList) {
      for (Cotizacion cotizacion in solicitud.cotizaciones) {
        if (cotizacion.nombretutor == tutorname) {
          // Calcular la fecha de cotización
          DateTime fechaCotizacion = solicitud.fechasistema.add(Duration(minutes: cotizacion.tiempoconfirmacion ?? 0));

          // Comprobar si es la cotización más reciente
          if (ultimaCotizacion == null || fechaCotizacion.isAfter(fechaUltimaCotizacion!)) {
            ultimaCotizacion = cotizacion;
            fechaUltimaCotizacion = fechaCotizacion;
          }
        }
      }
    }

    // Verificar si se encontró alguna cotización
    if (ultimaCotizacion != null) {
      tutorNotas.putIfAbsent(tutorname, () => {});
      return fechaUltimaCotizacion;
    } else {
      return DateTime.now(); // Puedes manejar el caso cuando no hay cotizaciones, retornando null o una fecha predeterminada
    }
  }

  bool ultimos20dias(DateTime fecha) {
    DateTime fechaActual = DateTime.now();
    DateTime fechaLimite = fechaActual.subtract(Duration(days: 20));

    return fecha.isAfter(fechaLimite);
  }
}