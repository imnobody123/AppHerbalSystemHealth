import 'package:flutter/material.dart';

class ControlEntradaMolino {
  final int id;
  int? idProcesoMolino;
  String controlMP;
  String? pais;
  final double KG;

  TextEditingController controlMPCtrl;

  ControlEntradaMolino({
    required this.id,
    this.idProcesoMolino,
    required this.controlMP,
    this.pais,
    required this.KG
  }) : controlMPCtrl = TextEditingController();

  factory ControlEntradaMolino.fromJson(Map<String, dynamic> json) {
    return ControlEntradaMolino(
      id: json['idEntradaMolinoDetalle'],
      idProcesoMolino: json['idProcesoMolino'],
      controlMP: json['controlMP'],
      pais: json['pais'],
      KG: json['kg'] ?? json['cantidadEntrada'] ?? 0
    );
  }
}