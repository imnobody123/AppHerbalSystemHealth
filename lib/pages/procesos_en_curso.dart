import 'package:app_registro_rendimientos/config/api_config.dart';
import 'package:flutter/material.dart';
import '../models/control_entrada_molino.dart';
import '../services/controles_service.dart';
import 'rendimientos_molinos.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProcesosEnCursoPage extends StatefulWidget 
{
  const ProcesosEnCursoPage({super.key}); 
  
  @override
  State<ProcesosEnCursoPage> createState() => _ProcesosEnCursoPageState();
}

class _ProcesosEnCursoPageState extends State<ProcesosEnCursoPage> 
{
  List<ControlEntradaMolino> controles = [];
  bool cargando = true;
  
  // 1. VARIABLE DE ESTADO PARA EL FILTRO
  String _filtroPais = 'TODOS'; 

  @override
  void initState() 
  {
    super.initState();
    _cargarControles();
  }

  Future<void> _cargarControles() async {
    try {
      final List<ControlEntradaMolino> data =
          await fetchControles('/ProcesosMolinosRegistros/ObtenerProcesosMolinosRegistrados');

      setState(() {
        controles = data;
        cargando = false;
      });

    } catch (e) {
      debugPrint('Error: $e');
      setState(() => cargando = false);
    }
  }

  Future<void> _finalizarControl(int? idProcesoMolino) async {
    final confirmacion = await _mostrarConfirmacion("¿Está seguro/a que desea finalizar este control?");

    if (confirmacion != true) return;

    setState(() => cargando = true);

    final Map<String, dynamic> body = {
      "idProcesoMolino" : idProcesoMolino
    };

    final String url = '${ApiConfig.baseUrl}/ProcesosMolinosRegistros/FinalizarProceso';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        _mostrarExito("¡Proceso Finalizado Correctamente!");
        _cargarControles();
      }
      else {
        setState(() => cargando = false);
        _mostrarError("Error al realizar la operación ${response.statusCode}");
      }
    }
    catch (e) {
      setState(() => cargando = false);
      _mostrarError("Error al conectar al servidor $e");
    }
  }

  // ... (Tus métodos de _mostrarConfirmacion, _mostrarError y _mostrarExito se quedan exactamente igual)
  Future<bool?> _mostrarConfirmacion(String mensaje) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.help, color: Colors.blue, size: 30),
              SizedBox(width: 8),
              Text(
                'Confirmación',
                style: TextStyle(
                  fontFamily: "CenturyGothic"
                ),
              )
            ]
          ),
          content: Text(
            mensaje,
            style: TextStyle(
              fontFamily: "CenturyGothic"
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  fontFamily: "CenturyGothic"
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 0, 80, 40),
                foregroundColor: Colors.white 
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Confirmar',
                style: TextStyle(
                  fontFamily: "CenturyGothic",
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _mostrarError(String mensaje) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.error, color: Colors.red, size: 30),
              SizedBox(width: 8),
              Text(
                'Error',
                style: TextStyle(
                  fontFamily: "CenturyGothic"
                ),
              ),
            ],
          ),
          content: Text(
            mensaje,
            style: TextStyle(
              fontFamily: "CenturyGothic"
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cerrar',
                style: TextStyle(
                  fontFamily: "CenturyGothic"
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _mostrarExito(String mensaje) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 64),
                const SizedBox(height: 16),
                const Text(
                  '¡Operación exitosa!', 
                  style: TextStyle(
                    fontFamily: "CenturyGothic",
                    fontSize: 18, 
                    fontWeight: FontWeight.bold
                    )
                  ),
                const SizedBox(height: 12),
                Text(
                  mensaje,
                  style: TextStyle(
                    fontFamily: "CenturyGothic"
                  ),
                  textAlign: TextAlign.center
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Aceptar',
                    style: TextStyle(
                      fontFamily: "CenturyGothic"
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) 
  {
    if (cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final controlesFiltrados = controles.where((control) {
      if (_filtroPais == 'TODOS') return true;
      
      // Comparamos ignorando mayúsculas/minúsculas para evitar errores de captura en la BD
      return (control.pais ?? '').toUpperCase() == _filtroPais.toUpperCase();
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          // CARD DE FILTROS MODIFICADO CON TÍTULO
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.filter_alt, size: 18, color: Colors.grey),
                      SizedBox(width: 6),
                      Text(
                        'Filtrar por:',
                        style: TextStyle(
                          fontFamily: "CenturyGothic",
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // FILA DE RADIOS EN HORIZONTAL DISTRIBUIDA EN PARTES IGUALES
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Opción: Todos
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Radio<String>(
                              value: 'TODOS',
                              groupValue: _filtroPais,
                              onChanged: (value) {
                                setState(() => _filtroPais = value!);
                              },
                            ),
                            const Text(
                              'Todos', 
                              style: TextStyle(
                                fontFamily: "CenturyGothic",
                                fontSize: 13
                                )
                              ),
                          ],
                        ),
                      ),
                      
                      // Opción: México
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Radio<String>(
                              value: 'MÉXICO',
                              groupValue: _filtroPais,
                              onChanged: (value) {
                                setState(() => _filtroPais = value!);
                              },
                            ),
                            const Text(
                              'México', 
                              style: TextStyle(
                                fontFamily: "CenturyGothic",
                                fontSize: 13
                                )
                              ),
                          ],
                        ),
                      ),
                      
                      // Opción: USA
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Radio<String>(
                              value: 'USA',
                              groupValue: _filtroPais,
                              onChanged: (value) {
                                setState(() => _filtroPais = value!);
                              },
                            ),
                            const Text(
                              'USA', 
                              style: TextStyle(
                                fontFamily: "CenturyGothic",
                                fontSize: 13
                                )
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: controlesFiltrados.isEmpty
                ? const Center(
                    child: Text(
                      'No hay procesos en curso para este origen.',
                      style: TextStyle(
                        fontFamily: "CenturyGothic"
                      ),
                      )
                    )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controlesFiltrados.length,
                    itemBuilder: (context, index) {
                      final control = controlesFiltrados[index];

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.factory),
                                title: Text(
                                  control.controlMP,
                                  style: const TextStyle(
                                    fontFamily: "CenturyGothic",
                                    fontWeight: FontWeight.bold
                                    ),
                                ),
                                subtitle: Text(
                                  control.pais ?? 'Sin Especificar',
                                  style: const TextStyle(
                                    fontFamily: "CenturyGothic",
                                    fontWeight: FontWeight.normal
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              Align(
                                alignment: Alignment.centerRight,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.check_circle),
                                      label: const Text(
                                        "Finalizar",
                                        style: TextStyle(
                                          fontFamily: "CenturyGothic",
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color.fromARGB(255, 0, 80, 40),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        )
                                      ),
                                      onPressed: () {
                                        _finalizarControl(control.idProcesoMolino);
                                      }
                                    ),

                                    const SizedBox(width: 8),

                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.edit),
                                      label: const Text(
                                        'Editar / Continuar',
                                        style: TextStyle(
                                          fontFamily: "CenturyGothic",
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Color.fromARGB(255, 0, 80, 40),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),

                                          side: BorderSide(
                                            color: Color.fromARGB(255, 0, 80, 40),
                                            width: 1.0
                                          )
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => RendimientosMolinos(
                                              idProcesoMolino: control.idProcesoMolino,
                                              controlMPEditar: control.controlMP,
                                              kg: control.KG,
                                              ),
                                            ),
                                          );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}