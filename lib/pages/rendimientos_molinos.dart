import 'package:app_registro_rendimientos/models/equipo_trabajo.dart';
import 'package:app_registro_rendimientos/models/operadores.dart';
import 'package:app_registro_rendimientos/services/operadores_service.dart';
import 'package:flutter/material.dart';
import '../models/control_entrada_molino.dart';
import '../models/proceso_salida.dart';
import '../models/seccion_proceso.dart';
import '../services/controles_service.dart';
import '../config/api_config.dart';
import 'dart:convert';
import 'procesos_en_curso.dart';
import 'package:http/http.dart' as http;

class RendimientosMolinos extends StatefulWidget 
{
  final int? idProcesoMolino;
  final String? controlMPEditar;
  final double? kg;

  const RendimientosMolinos({
    super.key,
    this.idProcesoMolino,
    this.controlMPEditar,
    this.kg
  });

  @override
  State<RendimientosMolinos> createState() => _RendimientosMolinos();
}

class _RendimientosMolinos extends State<RendimientosMolinos> 
{
  String? tipoProceso;

  List<ControlEntradaMolino> controles = [];
  ControlEntradaMolino? controlSeleccionado;
  bool cargando = true;

  List<ProcesoSalida> procesos = 
  [
    ProcesoSalida(nombre: 'Mesa de Trabajo'),
    ProcesoSalida(nombre: 'Molino'),
    ProcesoSalida(nombre: 'Tamizador'),
    ProcesoSalida(nombre: 'Tolva de imanes'),
    ProcesoSalida(nombre: 'Charolas de desinfección'),
  ];
  TextEditingController observacionesController = TextEditingController();

  EquipoTrabajo? equipoTrabajoSeleccionado;
  List<EquipoTrabajo> equipoTrabajo = 
  [
    EquipoTrabajo(idEquipo: 1, descripcion: "MOLINO 1"),
    EquipoTrabajo(idEquipo: 2, descripcion: "MOLINO 2"),
    EquipoTrabajo(idEquipo: 4, descripcion: "MOLINO 4"),
    EquipoTrabajo(idEquipo: 5, descripcion: "TAMIZ"),
    EquipoTrabajo(idEquipo: 6, descripcion: "COLADOR"),
    EquipoTrabajo(idEquipo: 7, descripcion: "NUTRIBULLET"),
    EquipoTrabajo(idEquipo: 8, descripcion: "TAMIZADOR")
  ];

  List<Operadores> operadores = [];

  final List<SeccionProceso> secciones = 
  [
    SeccionProceso(nombre: 'Mesa de Trabajo', idArea: 1),
    SeccionProceso(nombre: 'Molino', idArea: 2),
    SeccionProceso(nombre: 'Tamizado', idArea: 3),
    SeccionProceso(nombre: 'Tolva de imanes', idArea: 4),
    SeccionProceso(nombre: 'Charolas de desinfección', idArea: 5),
  ];

  @override
  void initState() 
  {
    super.initState();
    _cargarControles();
    _cargarOperadores();

    if (widget.idProcesoMolino != null) {
          _cargarProcesoParaEditar(widget.idProcesoMolino!);
    }
  }

  Future<void> _cargarProcesoParaEditar(int idProcesoMolino) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/ProcesoMolinoCompleto/ObtenerProcesoCompleto/$idProcesoMolino'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        debugPrint('No se pudo cargar el proceso');
        return;
      }

      final json = jsonDecode(response.body);

      setState(() {
        final itemFantasma = ControlEntradaMolino(
          id: 0, // Lo marcamos con 0 o el ID que te sirva para identificarlo
          controlMP: widget.controlMPEditar ?? '',
          KG: widget.kg ?? 0
        );
    
        controles.add(itemFantasma); // Lo metemos a la lista para que el Dropdown lo reconozca
        controlSeleccionado = itemFantasma;
        observacionesController.text = json['observaciones'] ?? '';
      });

      final List detalles = json['detalles'] ?? [];

      for (final d in detalles) {
        final int idArea = d['idAreaTrabajoMolinos'];

        SeccionProceso? seccion;

        for (final s in secciones) {
          if (s.idArea == idArea) {
            seccion = s;
            break;
          }
        }

        if (seccion == null) continue;

        setState(() {
          seccion?.activo = true;

          seccion?.idProcesoMolinoDetalle = d["idProcesoMolinoDetalles"];

          // 📅 Fechas
          seccion?.fechaEntrada = DateTime.tryParse(d['fechaEntrada'] ?? '');
          seccion?.fechaSalida = DateTime.tryParse(d['fechaSalida'] ?? '');

          // ⏰ Horas (vienen como DateTime)
          seccion?.horaEntrada = parseTimeSpan(d['horaEntrada']);
          seccion?.horaSalida  = parseTimeSpan(d['horaSalida']);

          // ⚖ Cantidades
          seccion?.cantidadEntrada =
              (d['cantidadEntrada'] as num?)?.toDouble();

          seccion?.cantidadEntradaCtrl.text =
            seccion.cantidadEntrada?.toString() ?? '';

          seccion?.cantidadSalida =
              (d['cantidadSalida'] as num?)?.toDouble();

          seccion?.cantidadSalidaCtrl.text =
            seccion.cantidadSalida?.toString() ?? '';

          final polvo = (d['cantidadPolvo'] as num?)?.toDouble() ?? 0;
          final te = (d['cantidadTe'] as num?)?.toDouble() ?? 0;

          if (polvo > 0)
          {
            seccion?.cantidadPolvo = polvo;
            seccion?.cantidadPolvoCtrl.text = polvo.toString();
          } 
          if (te > 0)
          {
            seccion?.cantidadTe = te;
            seccion?.cantidadTeCtrl.text = te.toString();
          } 
          
          // 👷 Operadores
          seccion?.operadoresIds =
              List<int>.from(d['operadoresIds'] ?? []);

          // ⚙ Equipo de trabajo
          final int? idEquipo = d['idEquipoTrabajo'];

          if (idEquipo != null) {
            EquipoTrabajo? equipo;

            for (final e in equipoTrabajo) {
              if (e.idEquipo == idEquipo) {
                equipo = e;
                break;
              }
            }

            if (equipo != null) {
              seccion?.equipoSeleccionado = equipo;
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error cargando proceso: $e');
    }
  }

  TimeOfDay? parseTimeSpan(String? value) {
    if (value == null || value.isEmpty) return null;

    final parts = value.split(':');
    if (parts.length < 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return null;

    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> _cargarControles() async 
  {
    try 
    {
      final data = await fetchControles('/EntradasMolinosDetalles/controlesMP_EntradaMolinos');
      setState(()
      {
        controles = data;
        cargando = false;
      });
    } 
    catch (e)
    {
      cargando = false;
      debugPrint('Error: $e');
    }
  }

  Future<void> _cargarOperadores() async 
  {
    try 
    {
      final data = await fetchOperadores();
      setState(()
      {
        operadores = data;
      });
    } 
    catch (e)
    {
      cargando = false;
      debugPrint('Error: $e');
    }
  }

  Future<void> _enviarProceso() async {
  final mensajeError = _validarFormulario();
  
  if (mensajeError != null) {
    _mostrarError(mensajeError);
    return;
  }

  final confirmar = await _mostrarConfirmacion(
    widget.idProcesoMolino == null
        ? "¿Está seguro/a que desea registrar este proceso?"
        : "¿Está seguro/a que desea actualizar este proceso?"
  );

  if (confirmar != true) return;

  // 2️⃣ Armar lista de detalles según el DTO de C#
  final detalles = secciones
    // Enviamos todas las secciones que tengan un ID (ya existen) 
    // o que estén activas (son nuevas)
    .where((s) => s.activo || (s.idProcesoMolinoDetalle != null && s.idProcesoMolinoDetalle! > 0))
    .map((s) {
      // Formateo de horas (siempre intentamos formatear lo que haya en el controlador)
      String? horaEntradaStr = s.horaEntrada != null 
          ? "${s.horaEntrada!.hour.toString().padLeft(2, '0')}:${s.horaEntrada!.minute.toString().padLeft(2, '0')}:00"
          : null;
          
      String? horaSalidaStr = s.horaSalida != null
          ? "${s.horaSalida!.hour.toString().padLeft(2, '0')}:${s.horaSalida!.minute.toString().padLeft(2, '0')}:00"
          : null;

      return {
        "idProcesoMolinoDetalles": s.idProcesoMolinoDetalle ?? 0, 
        "idAreaTrabajoMolinos": s.idArea,
        "activo": s.activo, // 👈 Enviamos el valor real del checkbox (true/false)
        "fechaEntrada": s.fechaEntrada?.toIso8601String(), // 👈 Enviamos lo que tenga el objeto
        "horaEntrada": horaEntradaStr,
        "cantidadEntrada": s.cantidadEntrada ?? 0.0,
        "fechaSalida": s.fechaSalida?.toIso8601String(),
        "horaSalida": horaSalidaStr,
        "cantidadSalida": _usaDobleCantidad(s.nombre)
            ? (s.cantidadPolvo ?? 0.0) + (s.cantidadTe ?? 0.0)
            : (s.cantidadSalida ?? 0.0),
        "cantidadPolvo": s.cantidadPolvo ?? 0.0,
        "cantidadTe": s.cantidadTe ?? 0.0,
        "operadoresIds": s.operadoresIds,
        "idEquipoTrabajo": s.equipoSeleccionado?.idEquipo ?? 0
      };
    })
    .toList();

  // 3️⃣ Armar el Body principal (DTOEntradaProcesoMolino)
  final Map<String, dynamic> body = {
    "idProcesoMolino": widget.idProcesoMolino ?? 0,
    "idEntradaMolinoDetalle": controlSeleccionado?.id ?? 0, // El ID de la materia prima
    "observaciones": observacionesController.text,
    "detalles": detalles,
  };

  // 4️⃣ Definir URL
  final String url = widget.idProcesoMolino == null
      ? '${ApiConfig.baseUrl}/ProcesosMolinos' // Tu endpoint de creación
      : '${ApiConfig.baseUrl}/ProcesosMolinos/ActualizarProcesoMolinos'; // Tu nuevo endpoint

  // 5️⃣ Envío HTTP
  try {
    setState(() => cargando = true);
    
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      _mostrarExito(
        widget.idProcesoMolino == null
            ? 'Proceso guardado correctamente'
            : 'Proceso actualizado correctamente',
      );

      _limpiarFormulario();
    } else {
      // Si el backend devuelve un BadRequest con texto, lo mostramos
      _mostrarError('Error: ${response.body}');
    }
  } catch (e) {
    _mostrarError('Error de conexión: $e');
  } finally {
    setState(() => cargando = false);
  }
}

  Future<bool?> _mostrarConfirmacion(String mensaje) 
  {
    return showDialog<bool>
    (
      context: context,
      barrierDismissible: false,
      builder: (context) 
      {
        return AlertDialog
        (
          title: Row
          (
            children: 
            [
              Icon
              (
                Icons.help,
                color: Colors.blue,
                size: 30,
              ),
              SizedBox(width: 8),
              Text('Confirmación')
            ]
          ),
          content: Text(mensaje),
          shape: RoundedRectangleBorder
          (
            borderRadius: BorderRadius.circular(12),
          ),
          actions: 
          [
            TextButton
            (
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton
            (
              style: ElevatedButton.styleFrom
              (
                backgroundColor: const Color(0xFF66BB6A),
                foregroundColor: Colors.white 
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarError(String mensaje) 
  {
    showDialog
    (
      context: context,
      builder: (context) 
      {
        return AlertDialog
        (
          title: Row(
            children: const 
            [
              Icon
              (
                Icons.error, 
                color: Colors.red,
                size: 30,
              ),
              SizedBox(width: 8),
              
              Text('Error'),
            ],
          ),
          content: Text(mensaje),
          actions: 
          [
            TextButton
            (
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarExito(String mensaje) 
  {
    showDialog
    (
      context: context,
      builder: (context) 
      {
        return Dialog
        (
          shape: RoundedRectangleBorder
          (
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column
            (
              mainAxisSize: MainAxisSize.min,
              children: 
              [
                const Icon
                (
                  Icons.check_circle,
                  color: Colors.green,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text
                (
                  '¡Operación exitosa!',
                  style: TextStyle
                  (
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text
                (
                  mensaje,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton
                (
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Aceptar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String? _validarFormulario() {
    // 1. Validar que se haya seleccionado un Control (Materia Prima)
    if (controlSeleccionado == null) {
      return 'Debe seleccionar un Control de entrada.';
    }

    // 2. Filtrar solo las secciones activas para validar sus campos
    final seccionesActivas = secciones.where((s) => s.activo).toList();

    if (seccionesActivas.isEmpty) {
      return 'Debe activar al menos una sección del proceso.';
    }

    for (var s in seccionesActivas) {
      // A. Validar Fechas y Horas
      if (s.fechaEntrada == null || s.horaEntrada == null) {
        return 'Faltan datos de entrada en la sección: ${s.nombre}';
      }
      if (s.fechaSalida == null || s.horaSalida == null) {
        return 'Faltan datos de salida en la sección: ${s.nombre}';
      }

      // B. Validar Cantidades (Entrada y Salida)
      if (s.cantidadEntrada == null || s.cantidadEntrada! <= 0) {
        return 'La cantidad de entrada en ${s.nombre} debe ser mayor a 0.';
      }

      if (_usaDobleCantidad(s.nombre)) {
        if ((s.cantidadPolvo == null || s.cantidadPolvo! <= 0) && 
            (s.cantidadTe == null || s.cantidadTe! <= 0)) {
          return 'Debe ingresar cantidad de Polvo o Té en ${s.nombre}.';
        }
      } else {
        if (s.cantidadSalida == null || s.cantidadSalida! <= 0) {
          return 'La cantidad de salida en ${s.nombre} debe ser mayor a 0.';
        }
      }

      // C. Validar Equipo de trabajo (Solo para Molino y Tamizado)
      if (s.nombre == 'Molino' || s.nombre == 'Tamizado') {
        if (s.equipoSeleccionado == null) {
          return 'Debe seleccionar un equipo para la sección: ${s.nombre}';
        }
      }

      // D. Validar al menos un operador seleccionado
      if (s.operadoresIds.isEmpty) {
        return 'Debe seleccionar al menos un operador para la sección: ${s.nombre}';
      }
    }

    return null; // Si pasa todas las pruebas, no hay error
  }

  void _limpiarFormulario() {
    setState(() {
      // 1. Resetear el control principal
      controlSeleccionado = null;
      observacionesController.clear();

      // 2. Resetear cada sección
      for (var s in secciones) {
        s.activo = false;
        s.fechaEntrada = null;
        s.fechaSalida = null;
        s.horaEntrada = null;
        s.horaSalida = null;
        s.cantidadEntrada = null;
        s.cantidadSalida = null;
        s.cantidadPolvo = null;
        s.cantidadTe = null;
        s.equipoSeleccionado = null;
        s.operadoresIds = [];
        
        // Limpiar los controladores de texto de las secciones
        s.cantidadEntradaCtrl.clear();
        s.cantidadSalidaCtrl.clear();
        s.cantidadPolvoCtrl.clear();
        s.cantidadTeCtrl.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) 
  {
      return DefaultTabController
      (
        length: 2,
        child: Scaffold
        (
          backgroundColor: const Color(0xFFF2F2F2),
          appBar: AppBar(
            title: const Text('Procesos'),
            backgroundColor: const Color(0xFF66BB6A),
            foregroundColor: Colors.white,

            bottom: const TabBar(
              indicatorColor: Colors.white,
              tabs: [
                Tab(icon: Icon(Icons.add, color: Colors.white)),        // Proceso
                Tab(icon: Icon(Icons.view_list, color: Colors.white)),      // En curso
              ],
            ),
          ),    

          body: TabBarView
          (
            children: 
            [
              cargando
                ? const Center(
                  child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                            color: Color(0xFF66BB6A), // Color verde como tu AppBar
                          ),
                          SizedBox(height: 16),
                          Text('Cargando datos...'),
                        ],
                      ),
                    )
                  : SingleChildScrollView
              (
                padding: const EdgeInsets.all(16),
                child: Card
                (
                  elevation: 4,
                  shape: RoundedRectangleBorder
                  (
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding
                  (
                    padding: const EdgeInsets.all(20),
                    child: Column
                    (
                      children:
                      [ 
                        Align
                        (
                          alignment: Alignment.center,
                          child: Text
                          (
                            'Registro de nuevo proceso de molinos',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                      DropdownButtonFormField<ControlEntradaMolino>(
                        value: controlSeleccionado,
                        decoration: InputDecoration(
                          labelText: 'Control',
                          // Cambiamos el color de fondo para que el usuario vea que está bloqueado
                          filled: true,
                          fillColor: widget.idProcesoMolino != null ? Colors.grey[200] : Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: controles.map((control) {
                          return DropdownMenuItem<ControlEntradaMolino>(
                            value: control,
                            child: Text(control.controlMP),
                          );
                        }).toList(),

                        // Si idProcesoMolino NO es nulo, significa que es EDICIÓN -> pasamos null para bloquear.
                        // Si es nulo, significa que es NUEVO -> pasamos la función para permitir selección.
                        onChanged: widget.idProcesoMolino != null 
                          ? null 
                          : (value) {
                              setState(() {
                                controlSeleccionado = value;
                              });
                            },
                      ),
                      const SizedBox(height: 16),         

                      const Text
                      (
                        'Salidas del Proceso',
                        style: TextStyle
                        (
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Column
                      (
                        children: secciones.map(_seccionProceso).toList(),
                      ),
                      const SizedBox(height: 16),

                        TextFormField
                        (
                          controller: observacionesController,
                          maxLines: 4, // 🔥 multilínea
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration
                          (
                            labelText: 'Observaciones',
                            hintText: 'Escribe aquí cualquier comentario adicional...',
                            alignLabelWithHint: true, // 👈 importante en multiline
                            border: OutlineInputBorder
                            (
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.notes),
                          ),
                        ),
                        const SizedBox(height: 20),

                        SizedBox
                        (
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon
                          (
                            icon: const Icon(Icons.save),
                            label: const Text('Registrar'),
                          
                            style: ElevatedButton.styleFrom
                            (
                              backgroundColor: const Color(0xFF66BB6A),
                              foregroundColor: const Color(0XFFF4F4F4),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            ),
                            onPressed: _enviarProceso,
                          )
                        )
                      ],
                    ),
                  ),
                ),
              ),

              // Tab 2
              const ProcesosEnCursoPage(),
            ] 
          )
        ),
    );
  }

  Widget _seccionProceso(SeccionProceso s) {
    List<EquipoTrabajo> _equiposPorSeccion(String nombre) {
      if (nombre == 'Molino') {
        return equipoTrabajo.where((e) =>
          e.descripcion.contains('MOLINO') ||
          e.descripcion == 'NUTRIBULLET'
        ).toList();
      }

      if (nombre == 'Tamizado') {
        return equipoTrabajo.where((e) =>
          e.descripcion == 'TAMIZ' ||
          e.descripcion == 'COLADOR' ||
          e.descripcion == 'TAMIZADOR'
        ).toList();
      }

      return [];
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// CHECK PRINCIPAL
            CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              value: s.activo,
              title: Text(
                s.nombre,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              // Busca esto dentro de _seccionProceso -> CheckboxListTile -> onChanged
              onChanged: (value) {
                setState(() {
                  s.activo = value!;
                  
                  int idxActual = secciones.indexOf(s);

                  if (s.activo) {
                    // CASO A: Es la primera sección activa, toma el valor del Control (Materia Prima)
                    if (secciones.where((sec) => sec.activo).length == 1) {
                      s.cantidadEntrada = controlSeleccionado?.KG;
                      s.cantidadEntradaCtrl.text = controlSeleccionado?.KG.toString() ?? '';
                    } 
                    // CASO B: No es la primera, debe buscar la salida de la sección activa anterior
                    else {
                      double valorHeredado = 0;
                      // Buscamos hacia atrás la última sección activa
                      for (int i = idxActual - 1; i >= 0; i--) {
                        if (secciones[i].activo) {
                          if (_usaDobleCantidad(secciones[i].nombre)) {
                            valorHeredado = (secciones[i].cantidadPolvo ?? 0) + (secciones[i].cantidadTe ?? 0);
                          } else {
                            valorHeredado = secciones[i].cantidadSalida ?? 0;
                          }
                          break; // Encontramos la anterior, salimos del for
                        }
                      }
                      s.cantidadEntrada = valorHeredado;
                      s.cantidadEntradaCtrl.text = valorHeredado > 0 ? valorHeredado.toString() : '';
                    }
                  }
                });
              },
            ),

            if (s.activo && (s.nombre == 'Molino' || s.nombre == 'Tamizado')) ...[
              const SizedBox(height: 10),

              DropdownButtonFormField<EquipoTrabajo>(
                value: s.equipoSeleccionado,
                decoration: InputDecoration(
                  labelText: 'Equipo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: _equiposPorSeccion(s.nombre).map((eq) {
                  return DropdownMenuItem<EquipoTrabajo>(
                    value: eq,
                    child: Text(eq.descripcion),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    s.equipoSeleccionado = value;
                  });
                },
              ),
            ],

            if (s.activo) ...[
              const Divider(),

              _campoFecha('Fecha entrada', s.fechaEntrada, (v) {
                setState(() => s.fechaEntrada = v);
              }),

              _campoHora('Hora entrada', s.horaEntrada, (v) {
                setState(() => s.horaEntrada = v);
              }),

              _campoNumero('Cantidad entrada',
                s.cantidadEntradaCtrl,
                (v) {
                  setState(() {
                    s.cantidadEntrada = v;
                  });
                }
              ),

              _campoFecha('Fecha salida', s.fechaSalida, (v) {
                setState(() => s.fechaSalida = v);
              }),

              _campoHora('Hora salida', s.horaSalida, (v) {
                setState(() => s.horaSalida = v);
              }),

              if (_usaDobleCantidad(s.nombre)) ...[
                _campoNumero('Cantidad polvo', s.cantidadPolvoCtrl, (v) {
                  s.cantidadPolvo = v;
                  _propagarValorASiguiente(secciones.indexOf(s));
                }),

                _campoNumero('Cantidad té', s.cantidadTeCtrl, (v) {
                  s.cantidadTe = v;
                  _propagarValorASiguiente(secciones.indexOf(s));
                }),
              ] else ...[
                _campoNumero('Cantidad salida', s.cantidadSalidaCtrl, (v) {
                  s.cantidadSalida = v;
                  // Obtenemos el índice de la sección actual para saber a quién sigue
                  int idx = secciones.indexOf(s);
                  _propagarValorASiguiente(idx); 
                }),
              ],

              const SizedBox(height: 12),
              const Text('Operadores', style: TextStyle(fontWeight: FontWeight.bold)),

              ...operadores.map((op) {
              return CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                title: Text(op.nombre),
                value: s.operadoresIds.contains(op.idOperador),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      s.operadoresIds.add(op.idOperador);
                    } else {
                      s.operadoresIds.remove(op.idOperador);
                    }
                  });
                },
              );
            }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _campoFecha(String label, DateTime? valor, Function(DateTime) onPick) {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration
      (
        labelText: label,
        prefixIcon: const Icon(Icons.calendar_today, size: 19),
      ),
      controller: TextEditingController(
        text: valor == null ? '' : '${valor.day}/${valor.month}/${valor.year}',
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked != null) onPick(picked);
      },
    );
  }

  Widget _campoHora(String label, TimeOfDay? valor, Function(TimeOfDay) onPick) {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration
      (
        labelText: label,
        prefixIcon: const Icon(Icons.access_time, size: 19)
      ),
      controller: TextEditingController(
        text: valor == null ? '' : valor.format(context),
      ),
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (picked != null) onPick(picked);
      },
    );
  }

  Widget _campoNumero(
    String label,
    TextEditingController controller,
    Function(double?) onChange,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.scale, size: 19),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (v) => onChange(double.tryParse(v)),
    );
  }

  void _propagarValorASiguiente(int indexActual) {
    // Si no hay una siguiente sección, no hacemos nada
    if (indexActual + 1 >= secciones.length) return;

    // Calculamos la salida de la sección actual
    double salidaActual = 0.0;
    var s = secciones[indexActual];
    
    if (_usaDobleCantidad(s.nombre)) {
      salidaActual = (s.cantidadPolvo ?? 0) + (s.cantidadTe ?? 0);
    } else {
      salidaActual = s.cantidadSalida ?? 0;
    }

    // Buscamos la SIGUIENTE sección que esté ACTIVA
    for (int i = indexActual + 1; i < secciones.length; i++) {
      if (secciones[i].activo) {
        setState(() {
          secciones[i].cantidadEntrada = salidaActual;
          secciones[i].cantidadEntradaCtrl.text = salidaActual > 0 ? salidaActual.toString() : '15';
        });
        // Solo actualizamos la primera activa que encontremos y paramos
        break; 
      }
    }
  }
}

bool _usaDobleCantidad(String nombre) {
  return nombre == 'Tamizado' ||
         nombre == 'Tolva de imanes' ||
         nombre == 'Charolas de desinfección';
}