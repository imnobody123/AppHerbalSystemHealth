import 'package:app_registro_rendimientos/config/api_config.dart';
import 'package:flutter/material.dart';
import '../services/controles_proceso_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const LiberacionCalidad());

class ControlProceso {
  final int idProcesoMolino;
  final String controlMP;

  ControlProceso({required this.idProcesoMolino, required this.controlMP});

  factory ControlProceso.fromJson(Map<String, dynamic> json) {
    return ControlProceso(
      idProcesoMolino: json['idProcesoMolino'], 
      controlMP: json['controlMP'],
    );
  }
}

class LiberacionCalidad extends StatelessWidget {
  const LiberacionCalidad({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
      ),
      home: const DashboardMultiArea(idsAreas: []), 
    );
  }
}

class DashboardMultiArea extends StatefulWidget {
  final List<int> idsAreas;
  const DashboardMultiArea({super.key, required this.idsAreas});

  @override
  State<DashboardMultiArea> createState() => _DashboardMultiAreaState();
}

class _DashboardMultiAreaState extends State<DashboardMultiArea> {
  List<dynamic> controles = []; 
  List<int> idsAreasActivas = [];
  List<int> idsProcesosMolinosDetalles = [];
  bool cargandoControles = true;
  bool cargandoAreas = false;
  String? idSeleccionado;

  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _observacionesController = TextEditingController();

  final Map<int, String> nombresAreas = {
    1: "Selección",
    2: "Molienda",
    3: "Tamizador",
    4: "Metales",
    5: "Sanitización",
  };

  final List<Map<String, dynamic>> opcionesTamizador = [
    {'idEquipoTrabajo': 5, 'nombre': 'Tamiz'},
    {'idEquipoTrabajo': 8, 'nombre': 'Tamizador'},
  ];

  final Map<String, String> siglasMateriaExtrana = {
    'Plástico': 'P',
    'Plaga': 'I',
    'Vidrio': 'V',
    'Pelo': 'E',
    'Tierra': 'T',
    'Piedras': 'R',
    'Heces': 'H',
    'Metal': 'M',
    'Animal Muerto': 'AM',
  };

  Map<int, Map<String, bool>> materiasSeleccionadas = {}; // Agrega esta variable de estado arriba

  // MAPAS PARA GUARDAR DATOS SEGÚN EL ID DEL ÁREA
  Map<int, Map<String, TextEditingController>> controllers = {};
  Map<int, bool> estadosLiberacion = {};
  final TextEditingController ctrlObservaciones = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarControlesIniciales();
  }

  Future<void> _cargarControlesIniciales() async {
    try {
      final data = await fetchControles('/LiberacionCalidad/Obtener_Controles_Procesos');
      setState(() {
        controles = data;
        cargandoControles = false;
      });
    } catch (e) {
      setState(() => cargandoControles = false);
      debugPrint('Error controles: $e');
    }
  }

  Future<void> _enviarProceso() async {
    if (!_validarCampos()) return;

    final connfirmado = await _mostrarConfirmacion("¿Está seguro que desea registrar esta liberación");

    if (connfirmado != true) return;

    if (idSeleccionado == null) return;

    List<DetalleDTO> listaDetalles = [];

    for (int i = 0; i < idsAreasActivas.length; i++) {
      int idArea = idsAreasActivas[i];
      
      // EXTRAEMOS EL ID DE LA BASE DE DATOS USANDO EL MISMO ÍNDICE
      int idDetalleDB = idsProcesosMolinosDetalles[i]; 
      
      final c = controllers[idArea]!;

      // Creamos el detalle base incluyendo el ID de la base de datos
      DetalleDTO detalle = DetalleDTO(
        idProcesoMolinosDetalles: idDetalleDB, // <--- CAMPO CLAVE
        liberado: estadosLiberacion[idArea] ?? false,
      );

      // LLENADO TÉCNICO POR ÁREA
      if (idArea == 1) { // SELECCIÓN
        // 1. Creamos un String vacío para ir acumulando las letras
          String stringMaterias = "";

          // 2. Recorremos el mapa de estados (materiasSeleccionadas)
          // 'nombre' es "Plástico", 'seleccionado' es true o false
          materiasSeleccionadas[idArea]?.forEach((nombre, seleccionado) {
            if (seleccionado == true) {
              stringMaterias += siglasMateriaExtrana[nombre]!; // Si está marcado, buscamos su sigla (P, I, V, etc.) y la sumamos
            }
          });

          debugPrint(stringMaterias);

          // 3. Ahora enviamos el string final (ej: "PVM") al DTO
          detalle.detallesSeleccion = DetallesSeleccionDTO(
            nivelInspeccion: int.tryParse(c['nivel']!.text) ?? 0,
            poblacionTotal: int.tryParse(c['poblacion']!.text) ?? 0,
            muestraTotal: int.tryParse(c['muestra']!.text) ?? 0,
            bolsasRechazadas: int.tryParse(c['rechazadas']!.text) ?? 0,
            materiaExtrana: stringMaterias, // <--- Aquí ya va solo el texto limpio
            activo: true,
          );
      } 
      else if (idArea == 2) { // MOLIENDA
        detalle.detallesMolienda = DetallesMoliendaDTO(
          cantidadPolvo: int.tryParse(c['polvo']!.text) ?? 0,
          cantidadTe: int.tryParse(c['te']!.text) ?? 0,
          activo: true
        );
      }
      else if (idArea == 3) { // TAMIZADOR
        detalle.detallesTamizador = DetallesTamizadorDTO(
          idEquipoTrabajoMolinos: int.tryParse(c['equipo']!.text) ?? 0,
          activo: true
        );
      }
      else if (idArea == 4) { // METALES
        detalle.detallesMetales = DetallesMetalesDTO(
          fasesProceso: int.tryParse(c['fases']!.text) ?? 0,
          nivelInspeccion: int.tryParse(c['nivel']!.text) ?? 0,
          poblacionTotal: int.tryParse(c['poblacion']!.text) ?? 0,
          muestraTotal: int.tryParse(c['muestra']!.text) ?? 0,
          bolsasRechazadas: int.tryParse(c['rechazadas']!.text) ?? 0,
          activo: true
        );
      }

      listaDetalles.add(detalle);
    }

    final request = DTOLiberacionesMPCalidad(
      idProcesoMolino: int.parse(idSeleccionado!),
      kilosSalida: double.tryParse(_numeroController.text) ?? 0,
      observaciones: _observacionesController.text,      
      detalles: listaDetalles,
    );

    // Llamada HTTP
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/LiberacionCalidad/CrearRegistrosLiberacionCalidad'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        _mostrarExito(response.body);
        _limpiarPantalla();
      }
      else{
        _mostrarError("Ha ocurrido un error el intentar agregar estos registros");
      }
    } catch (e) {
      _mostrarError("Ha ocurrido un error en la conexión o en el servidor");
    }
  }

    void _limpiarPantalla() {
    setState(() {
      idSeleccionado = null;
      idsAreasActivas.clear();
      _observacionesController.clear();
      controllers.clear();
      materiasSeleccionadas.clear();
      estadosLiberacion.clear();
    });
  }

  bool _validarCampos() {
    if (idSeleccionado == null) {
      _mostrarAdvertencia("Debe seleccionar un Proceso Maestro.");
      return false;
    }

    for (var id in idsAreasActivas) {
      final c = controllers[id]!;
      final nombreArea = nombresAreas[id] ?? "Área $id";

      // --- VALIDACIÓN ESPECÍFICA POR ÁREA ---
      
      if (id == 1) { // SELECCIÓN
        // 1. Validar los 4 campos numéricos obligatorios
        if (c['nivel']!.text.isEmpty || c['poblacion']!.text.isEmpty || 
            c['muestra']!.text.isEmpty || c['rechazadas']!.text.isEmpty) {
          _mostrarAdvertencia("Faltan datos numéricos en $nombreArea (Nivel, Población, Muestra o Rechazadas).");
          return false;
        }
        // 2. Validar que al menos un checkbox de materia extraña esté marcado
        bool algunaMateria = materiasSeleccionadas[id]?.values.any((v) => v) ?? false;
        if (!algunaMateria) {
          _mostrarAdvertencia("Debe seleccionar al menos una opción en Materias Extrañas para $nombreArea.");
          return false;
        }
      }

      else if (id == 2) { // MOLIENDA
        if (c['polvo']!.text.isEmpty || c['te']!.text.isEmpty) {
          _mostrarAdvertencia("Debe ingresar las cantidades de Corte Polvo y Corte Té en $nombreArea.");
          return false;
        }
      }

      else if (id == 3) { // TAMIZADOR
        // Validar el Combobox (Dropdown)
        if (c['equipo']!.text.isEmpty || c['equipo']!.text == '0') {
          _mostrarAdvertencia("Debe seleccionar un Equipo de Trabajo en $nombreArea.");
          return false;
        }
      }

      else if (id == 4) { // METALES
        // Validar los 5 campos numéricos
        if (c['fases']!.text.isEmpty || c['nivel']!.text.isEmpty || 
            c['poblacion']!.text.isEmpty || c['muestra']!.text.isEmpty || 
            c['rechazadas']!.text.isEmpty) {
          _mostrarAdvertencia("Faltan datos en $nombreArea. Por favor revise todos los campos numéricos.");
          return false;
        }
      }
      
      // El Área 5 (Sanitización) usualmente solo tiene el Radio de Estado, 
      // el cual ya se inicializa en 'true' (Liberado), así que no requiere validación extra.
    }

    return true;
  }

  Future<void> _obtenerAreasPorProceso(String idProceso) async {
    setState(() => cargandoAreas = true);

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/LiberacionCalidad/Obtener_Ids_Areas_Trabajo/$idProceso')
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          // EXTRACCIÓN SEGURA DE LOS IDS DEL JSON
          idsAreasActivas = data.map<int>((item) {
            return item['idAreaTrabajo'] as int; 
          }).toList();

          idsProcesosMolinosDetalles = data.map<int>((item) {
            return item['idProcesoMolinoDetale'] as int;
          }).toList();

          // INICIALIZAR CONTROLLERS PARA CADA ÁREA QUE LLEGÓ
          controllers.clear();
          for (var id in idsAreasActivas) {
            estadosLiberacion[id] = true;
            controllers[id] = {
              'fases': TextEditingController(text: ''),
              
              'nivel': TextEditingController(text: ''),
              'poblacion': TextEditingController(text: ''),
              'muestra': TextEditingController(text: ''),
              'rechazadas': TextEditingController(text: ''),
              'materia': TextEditingController(text: ''),
              'polvo': TextEditingController(text: ''),
              'te': TextEditingController(text: ''),
              'equipo': TextEditingController(text: ''),
            };

            // INICIALIZACIÓN DE LOS CHECKBOXES (SOLO SI ES ÁREA 1)
            if (id == 1) {
              materiasSeleccionadas[id] = {
                for (var nombre in siglasMateriaExtrana.keys) nombre: false,
              };
            }
          }

          cargandoAreas = false;
        });
      }
    } catch (e) {
      setState(() => cargandoAreas = false);
      _mostrarError('Error obteniendo áreas');
    }
  }

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

  void _mostrarAdvertencia(String mensaje) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(
                Icons.warning_amber_rounded, // Icono de advertencia
                color: Colors.orange,        // Color naranja/ámbar
                size: 30,
              ),
              SizedBox(width: 8),
              Text(
                'Atención',
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
                'Entendido',
                style: TextStyle(
                  fontFamily: "CenturyGothicSS"
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Liberación Calidad",
          style: TextStyle(
            fontFamily: "CenturyGothic"
          ),  
        ),
        backgroundColor: Color.fromARGB(255, 0, 80, 40),
        foregroundColor: Colors.white,
        ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Center(
                child: Text(
                  'Registro de Liberaciones de Materia Prima',
                  style: TextStyle(
                    fontFamily: "CenturyGothic",
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 23),

              cargandoControles 
                ? const LinearProgressIndicator() 
                : DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: idSeleccionado,
                    decoration: const InputDecoration(
                      labelText: "Seleccionar Proceso Maestro",
                      labelStyle: TextStyle(
                        fontFamily: "CenturyGothic"
                      )
                    ),
                    items: controles.map((c) => DropdownMenuItem(
                      value: c.idProcesoMolino.toString(),
                      child: Text(
                        c.controlMP,
                        style: TextStyle(
                          fontFamily: "CenturyGothic"
                        ),
                      ),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => idSeleccionado = val);
                        _obtenerAreasPorProceso(val);
                      }
                    },
                  ),

              const SizedBox(height: 20),

              TextField(
                controller: _numeroController,
                keyboardType: TextInputType.number, // Abre el teclado numérico
                decoration: InputDecoration(
                  labelText: 'Kilos Salida',
                  labelStyle: TextStyle(
                      fontFamily: "CenturyGothic"
                  )
                ),
              ),
              const SizedBox(height: 20),

              if (cargandoAreas)
                const Center(child: CircularProgressIndicator())
              else if (idsAreasActivas.isEmpty && idSeleccionado != null)
                const Text("No hay áreas configuradas para este proceso.")
              else
                ...idsAreasActivas.map((id) => _buildExpandableSection(id)).toList(),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _observacionesController,
                  style: TextStyle(
                    fontFamily: "CenturyGothic"
                  ),
                  maxLines: 3, // Esto lo hace multilínea
                  decoration: const InputDecoration(
                    labelText: 'Observaciones Generales',
                    labelStyle: TextStyle(
                      fontFamily: "CenturyGothic"
                    ),
                    hintText: 'Ingrese detalles adicionales del proceso...',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true, // Alinea el texto arriba
                  ),
                ),
              ),

              SizedBox
              (
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon
                (
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'Registrar',
                    style: TextStyle(
                      fontFamily: "CenturyGothic"
                    ),
                  ),
                          
                  style: ElevatedButton.styleFrom
                  (
                    backgroundColor: const Color.fromARGB(255, 0, 80, 40),
                    foregroundColor: const Color(0XFFF4F4F4),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                  onPressed: _enviarProceso,
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableSection(int id) {
    // Obtenemos el nombre del mapa, si no existe usamos un genérico
    final String nombreArea = nombresAreas[id] ?? "Área Desconocida";
    
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text(id.toString()), radius: 15),
                const SizedBox(width: 10),
                Text(
                  nombreArea, 
                  style: const TextStyle(
                    fontFamily: "CenturyGothic",
                    fontWeight: FontWeight.bold, 
                    fontSize: 16)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),
            _getAreaWidget(id),
          ],
        ),
      ),
    );
  }

  Widget _getAreaWidget(int id) {
    final areaControllers = controllers[id]!;

    switch (id) {
      case 1: // Supongamos que 1 es Selección
        return Column(children: [
          
          _buildNumericField("Nivel de inspección", areaControllers['nivel']!),
          _buildNumericField("Población Total", areaControllers['poblacion']!),
          _buildNumericField("Muestra Total", areaControllers['muestra']!),
          _buildNumericField("Bolsas Rechazadas", areaControllers['rechazadas']!),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text("Materias Extrañas Encontradas:", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          
          // Generamos la cuadrícula de checkboxes
          Wrap(
            spacing: 10,
            runSpacing: 0,
            children: siglasMateriaExtrana.keys.map((nombre) {
              return FilterChip(
                label: Text(
                  nombre,
                  style: TextStyle(
                    fontFamily: "CenturyGothic"
                  ),
                ),
                selected: materiasSeleccionadas[id]?[nombre] ?? false,
                onSelected: (bool selected) {
                  setState(() {
                    materiasSeleccionadas[id]![nombre] = selected;
                  });
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: 15),
          _buildDecisionRadios("Estado:", id),
        ]);

        case 2: // MOLIENDA
          return Column(children: [
            _buildNumericField("Corte Polvo", areaControllers['polvo']!),
            _buildNumericField("Corte Té", areaControllers['te']!),
            _buildDecisionRadios("Estado:", id),
          ]);

        case 3: // TAMIZADOR
          // 1. Intentamos obtener el ID del controlador
          int? valorEquipo = int.tryParse(areaControllers['equipo']!.text);

          // 2. Verificación de seguridad:
          // Si el valor no es 5 ni 8, lo forzamos a null.
          if (valorEquipo != 5 && valorEquipo != 8) {
            valorEquipo = null;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<int>(
                isExpanded: true,
                // Al ser null si no es 5 u 8, mostrará el labelText sin errores
                value: valorEquipo,
                style: TextStyle(
                  fontFamily: "CenturyGothic"
                ),
                decoration: const InputDecoration(
                  labelText: "Seleccionar Equipo de Trabajo",
                  labelStyle: TextStyle(
                    fontFamily: "CenturyGothic"
                  ),
                  border: OutlineInputBorder(),
                ),
                // IMPORTANTE: Asegúrate de que los IDs aquí sean exactamente int
                items: const [
                  DropdownMenuItem(value: 5, child: Text("Tamiz")),
                  DropdownMenuItem(value: 8, child: Text("Tamizador")),
                ],
                onChanged: (nuevoId) {
                  setState(() {
                    areaControllers['equipo']!.text = nuevoId.toString();
                  });
                },
              ),
              const SizedBox(height: 15),
              _buildDecisionRadios("Estado:", id),
            ],
          );

        case 4: // METALES (DETECTOR DE METALES)
          return Column(children: [
            _buildNumericField("Fases de proceso", areaControllers['fases']!),
            _buildNumericField("Nivel de inspección", areaControllers['nivel']!),
            _buildNumericField("Población Total", areaControllers['poblacion']!),
            _buildNumericField("Muestra Total", areaControllers['muestra']!),
            _buildNumericField("Bolsas rechazadas", areaControllers['rechazadas']!),
            _buildDecisionRadios("Estado:", id),
          ]);

        case 5:
        return Column(children: [
          _buildDecisionRadios("Estado:", id)
        ]);
      default: return Text("Área $id pendiente.");
    }
  }

  // --- HELPERS REINSTALADOS ---

  Widget _buildNumericField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontFamily: "CenturyGothic"
          ), 
          isDense: true),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          filled: true,
          fillColor: Colors.blue.withOpacity(0.05),
        ),
      ),
    );
  }

  Widget _buildDecisionRadios(String titulo, int idArea) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: [
            // Opción LIBERADO
            Radio<bool>(
              value: true,
              groupValue: estadosLiberacion[idArea],
              onChanged: (bool? val) {
                setState(() {
                  estadosLiberacion[idArea] = val!;
                });
              },
            ),
            const Text(
              "Liberado",
              style: TextStyle(
                fontFamily: "CenturyGothic"
              ),  
            ),
            const SizedBox(width: 10),
            // Opción RECHAZADO
            Radio<bool>(
              value: false,
              groupValue: estadosLiberacion[idArea],
              onChanged: (bool? val) {
                setState(() {
                  estadosLiberacion[idArea] = val!;
                });
              },
            ),
            const Text(
              "Rechazado",
              style: TextStyle(
                fontFamily: "CenturyGothic"
              ),
            ),
          ],
        ),
      ],
    );
    }
  }

class DTOLiberacionesMPCalidad {
  int idProcesoMolino;
  double kilosSalida;
  String observaciones;
  List<DetalleDTO> detalles;

  DTOLiberacionesMPCalidad({
    required this.idProcesoMolino,
    required this.kilosSalida,
    required this.observaciones,
    required this.detalles,
  });

  Map<String, dynamic> toJson() => {
    "idProcesoMolino": idProcesoMolino,
    'kilosSalida': kilosSalida,
    "observaciones": observaciones,
    "detalles": detalles.map((x) => x.toJson()).toList(),
  };
}

class DetalleDTO {
  int idProcesoMolinosDetalles; // <--- AGREGAR ESTO
  bool liberado;
  DetallesMetalesDTO detallesMetales;
  DetallesMoliendaDTO detallesMolienda;
  DetallesSeleccionDTO detallesSeleccion;
  DetallesTamizadorDTO detallesTamizador;

  DetalleDTO({
    required this.idProcesoMolinosDetalles, // <--- Y ESTO
    required this.liberado,
    DetallesMetalesDTO? metales,
    DetallesMoliendaDTO? molienda,
    DetallesSeleccionDTO? seleccion,
    DetallesTamizadorDTO? tamizador,
  }) : 
    detallesMetales = metales ?? DetallesMetalesDTO(),
    detallesMolienda = molienda ?? DetallesMoliendaDTO(),
    detallesSeleccion = seleccion ?? DetallesSeleccionDTO(),
    detallesTamizador = tamizador ?? DetallesTamizadorDTO();

  Map<String, dynamic> toJson() => {
    "idProcesoMolinoDetalles": idProcesoMolinosDetalles, // <--- INCLUIR EN JSON
    "liberado": liberado,
    "detallesMetales": detallesMetales.toJson(),
    "detallesMolienda": detallesMolienda.toJson(),
    "detallesSeleccion": detallesSeleccion.toJson(),
    "detallesTamizador": detallesTamizador.toJson(),
  };
}

// Sub-clases con valores por defecto en 0
class DetallesMetalesDTO {
  int fasesProceso;
  int nivelInspeccion;
  int poblacionTotal;
  int muestraTotal;
  int bolsasRechazadas;
  bool activo;

  DetallesMetalesDTO({
    this.fasesProceso = 0, 
    this.nivelInspeccion = 0, 
    this.poblacionTotal = 0, 
    this.muestraTotal = 0, 
    this.bolsasRechazadas = 0, 
    this.activo = false
  });
  Map<String, dynamic> toJson() => { 
    "fasesProceso": fasesProceso, 
    "nivelInspeccion": nivelInspeccion, 
    "poblacionTotal": poblacionTotal, 
    "muestraTotal": muestraTotal, 
    "bolsasRechazadas": bolsasRechazadas,
    "activo": activo };
}

class DetallesMoliendaDTO {
  int cantidadPolvo;
  int cantidadTe;
  bool activo;

  DetallesMoliendaDTO({
    this.cantidadPolvo = 0, 
    this.cantidadTe = 0,
    this.activo = false  
  });
  Map<String, dynamic> toJson() => { 
    "cantidadPolvo": cantidadPolvo, 
    "cantidadTe": cantidadTe,
    "activo": activo
  };
}

class DetallesSeleccionDTO {
  int nivelInspeccion;
  int poblacionTotal;
  int muestraTotal;
  int bolsasRechazadas;
  String materiaExtrana;
  bool activo;

  DetallesSeleccionDTO({
    this.nivelInspeccion = 0, 
    this.poblacionTotal = 0, 
    this.muestraTotal = 0, 
    this.bolsasRechazadas = 0, 
    this.materiaExtrana = "",
    this.activo = false
  });
  Map<String, dynamic> toJson() => { 
    "nivelInspeccion": nivelInspeccion, 
    "poblacionTotal": poblacionTotal, 
    "muestraTotal": muestraTotal, 
    "bolsasRechazadas": bolsasRechazadas, 
    "materiaExtrana": materiaExtrana,
    "activo": activo
  };
}

class DetallesTamizadorDTO {
  int idEquipoTrabajoMolinos;
  bool activo;

  DetallesTamizadorDTO({
    this.idEquipoTrabajoMolinos = 0,
    this.activo = false
  });
  Map<String, dynamic> toJson() => { 
    "idEquipoTrabajoMolinos": idEquipoTrabajoMolinos,
    "activo": activo
  };
}