import 'package:flutter/material.dart';

class ControlProcesoMolino {
  final int idProcesoMolino;
  final String controlMP;

  TextEditingController controlMPCtrl;

  ControlProcesoMolino({
    required this.idProcesoMolino,
    required this.controlMP,
  }) : controlMPCtrl = TextEditingController();

  factory ControlProcesoMolino.fromJson(Map<String, dynamic> json) {
    return ControlProcesoMolino(
      idProcesoMolino: json['idProcesoMolino'],
      controlMP: json['controlMP']
    );
  }
}