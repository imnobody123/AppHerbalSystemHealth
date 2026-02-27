import 'package:flutter/material.dart';

class ControlEntradaMolino {
  final int id;
  int? idProcesoMolino;
  String controlMP;
  final double KG;

  TextEditingController controlMPCtrl;

  ControlEntradaMolino({
    required this.id,
    this.idProcesoMolino,
    required this.controlMP,
    required this.KG
  }) : controlMPCtrl = TextEditingController();

  factory ControlEntradaMolino.fromJson(Map<String, dynamic> json) {
    return ControlEntradaMolino(
      id: json['idEntradaMolinoDetalle'],
      idProcesoMolino: json['idProcesoMolino'],
      controlMP: json['controlMP'],
      KG: json['kg'] ?? json['cantidadEntrada'] ?? 0
    );
  }
}

