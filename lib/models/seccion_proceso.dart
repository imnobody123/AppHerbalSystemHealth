import 'package:flutter/material.dart';
import 'equipo_trabajo.dart';

class SeccionProceso 
{
  final String nombre;
  final int idArea;
  int? idProcesoMolinoDetalle;
  bool activo;

  DateTime? fechaEntrada;
  TimeOfDay? horaEntrada;
  double? cantidadEntrada;

  DateTime? fechaSalida;
  TimeOfDay? horaSalida;
  double? cantidadSalida;
  double? cantidadPolvo;
  double? cantidadTe;

  List<int> operadoresIds = [];

  EquipoTrabajo? equipoSeleccionado;

  final TextEditingController cantidadEntradaCtrl =
      TextEditingController();
  final TextEditingController cantidadSalidaCtrl =
      TextEditingController();
  final TextEditingController cantidadPolvoCtrl =
      TextEditingController();
  final TextEditingController cantidadTeCtrl =
      TextEditingController();

  SeccionProceso
  ({
    required this.nombre,
    required this.idArea,
    this.activo = false,
  });
}
