import 'package:flutter/material.dart';

class ProcesoSalida
{
  String nombre;
  bool seleccionado;
  DateTime? fechsEntrada;
  DateTime? fechaSalida;
  TimeOfDay? horaSalida;
  TimeOfDay? horaEntrada;
  TextEditingController cantidadEntradaController;
  TextEditingController cantidadSalidaController;

  ProcesoSalida({
    required this.nombre,
    this.seleccionado = false,
    this.fechsEntrada,
    this.fechaSalida,
    this.horaEntrada,
    this.horaSalida,
  }) : cantidadEntradaController = TextEditingController(),
        cantidadSalidaController = TextEditingController();
}
