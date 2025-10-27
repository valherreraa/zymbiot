import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import '../services/analysis.dart';

class FilesScreen extends StatefulWidget {
  const FilesScreen({super.key});

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  final ZymbiotAnalysisService _analysisService = ZymbiotAnalysisService();
  List<Map<String, dynamic>> _analysisFiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocalFiles();
  }

  Future<void> _loadLocalFiles() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final analisis = await _analysisService.listarAnalisisGuardados();

      setState(() {
        _analysisFiles = analisis;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar archivos: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _abrirPDF(Map<String, dynamic> analysis) async {
    try {
      String nombrePDF;

      // Verificar si tenemos información de archivos generados
      if (analysis['archivos_generados'] != null &&
          analysis['archivos_generados']['pdf'] != null) {
        nombrePDF = analysis['archivos_generados']['pdf'];
      } else {
        // Fallback: construir nombre desde el timestamp o archivo JSON
        final String nombreArchivo = analysis['archivo']
            .split('/')
            .last
            .split('\\')
            .last;
        nombrePDF = nombreArchivo
            .replaceAll('analisis_completo_', 'reporte_halos_')
            .replaceAll('.json', '.pdf');
      }

      final String rutaPDF = await _analysisService.getRutaAnalisis(nombrePDF);
      final file = File(rutaPDF);

      if (await file.exists()) {
        final result = await OpenFile.open(rutaPDF);
        if (result.type != ResultType.done) {
          _mostrarError('No se pudo abrir el PDF: ${result.message}');
        }
      } else {
        // Verificar qué archivos existen para depuración
        final verificacion = await _analysisService.verificarArchivosExisten(
          analysis,
        );
        _mostrarError(
          'El archivo PDF no existe: $nombrePDF\nVerificación: JSON=${verificacion['json']}, PDF=${verificacion['pdf']}, Imagen=${verificacion['imagen']}',
        );
      }
    } catch (e) {
      _mostrarError('Error al abrir PDF: ${e.toString()}');
    }
  }

  Future<void> _abrirImagen(Map<String, dynamic> analysis) async {
    try {
      String nombreImagen;

      // Verificar si tenemos información de archivos generados
      if (analysis['archivos_generados'] != null &&
          analysis['archivos_generados']['imagen_anotada'] != null) {
        nombreImagen = analysis['archivos_generados']['imagen_anotada'];
      } else {
        // Fallback: construir nombre desde el archivo JSON
        final String nombreArchivo = analysis['archivo']
            .split('/')
            .last
            .split('\\')
            .last;
        nombreImagen = nombreArchivo
            .replaceAll('analisis_completo_', 'imagen_anotada_')
            .replaceAll('.json', '.png');
      }

      final String rutaImagen = await _analysisService.getRutaAnalisis(
        nombreImagen,
      );
      final file = File(rutaImagen);

      if (await file.exists()) {
        final result = await OpenFile.open(rutaImagen);
        if (result.type != ResultType.done) {
          _mostrarError('No se pudo abrir la imagen: ${result.message}');
        }
      } else {
        // Verificar qué archivos existen para depuración
        final verificacion = await _analysisService.verificarArchivosExisten(
          analysis,
        );
        _mostrarError(
          'El archivo de imagen no existe: $nombreImagen\nVerificación: JSON=${verificacion['json']}, PDF=${verificacion['pdf']}, Imagen=${verificacion['imagen']}',
        );
      }
    } catch (e) {
      _mostrarError('Error al abrir imagen: ${e.toString()}');
    }
  }

  Future<void> _abrirExcel(Map<String, dynamic> analysis) async {
    try {
      String nombreExcel;

      // Verificar si tenemos información de archivos generados
      if (analysis['archivos_generados'] != null &&
          analysis['archivos_generados']['excel'] != null) {
        nombreExcel = analysis['archivos_generados']['excel'];
      } else {
        // Fallback: construir nombre desde el archivo JSON
        final String nombreArchivo = analysis['archivo']
            .split('/')
            .last
            .split('\\')
            .last;
        nombreExcel = nombreArchivo
            .replaceAll('analisis_completo_', 'reporte_halos_')
            .replaceAll('.json', '.xlsx');
      }

      final String rutaExcel = await _analysisService.getRutaAnalisis(
        nombreExcel,
      );
      final file = File(rutaExcel);

      if (await file.exists()) {
        final result = await OpenFile.open(rutaExcel);
        if (result.type != ResultType.done) {
          _mostrarError('No se pudo abrir el Excel: ${result.message}');
        }
      } else {
        // Verificar qué archivos existen para depuración
        final verificacion = await _analysisService.verificarArchivosExisten(
          analysis,
        );
        _mostrarError(
          'El archivo Excel no existe: $nombreExcel\nVerificación: JSON=${verificacion['json']}, PDF=${verificacion['pdf']}, Excel=${verificacion['excel']}, Imagen=${verificacion['imagen']}',
        );
      }
    } catch (e) {
      _mostrarError('Error al abrir Excel: ${e.toString()}');
    }
  }

  void _mostrarError(String mensaje) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _mostrarOpcionesArchivo(Map<String, dynamic> analysis) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('Ver PDF'),
                subtitle: const Text('Abrir reporte completo en PDF'),
                onTap: () {
                  Navigator.pop(context);
                  _abrirPDF(analysis);
                },
              ),
              ListTile(
                leading: const Icon(Icons.table_chart, color: Colors.green),
                title: const Text('Ver Excel'),
                subtitle: const Text('Abrir datos en formato Excel'),
                onTap: () {
                  Navigator.pop(context);
                  _abrirExcel(analysis);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image, color: Colors.blue),
                title: const Text('Ver Imagen Anotada'),
                subtitle: const Text('Abrir imagen con halos marcados'),
                onTap: () {
                  Navigator.pop(context);
                  _abrirImagen(analysis);
                },
              ),
              ListTile(
                leading: const Icon(Icons.info, color: Colors.grey),
                title: const Text('Detalles'),
                subtitle: Text(
                  '${analysis['total_halos']} halos - ${_formatDate(analysis['fecha'])}',
                ),
                onTap: () {
                  Navigator.pop(context);
                  _mostrarDetalles(analysis);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _mostrarDetalles(Map<String, dynamic> analysis) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Análisis - ${analysis['total_halos']} halos'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Fecha:', _formatDate(analysis['fecha'])),
              _buildDetailRow('Total de halos:', '${analysis['total_halos']}'),
              _buildDetailRow(
                'Diámetro promedio:',
                '${analysis['diametro_promedio'].toStringAsFixed(2)} mm',
              ),
              _buildDetailRow(
                'Área total:',
                '${analysis['area_total'].toStringAsFixed(2)} mm²',
              ),
              _buildDetailRow('Archivo:', analysis['archivo']),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _abrirExcel(analysis);
              },
              child: const Text('Ver Excel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _abrirPDF(analysis);
              },
              child: const Text('Ver PDF'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Análisis Guardados'),
        backgroundColor: const Color(0xFF64316B),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLocalFiles,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _analysisFiles.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay análisis guardados',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Toma una foto y analízala para ver los resultados aquí',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _analysisFiles.length,
              itemBuilder: (context, index) {
                final analysis = _analysisFiles[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF64316B),
                      child: Text(
                        '${analysis['total_halos']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      '${analysis['total_halos']} halos detectados',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fecha: ${_formatDate(analysis['fecha'])}'),
                        Text(
                          'Diámetro promedio: ${analysis['diametro_promedio'].toStringAsFixed(2)} mm',
                        ),
                        Text(
                          'Área total: ${analysis['area_total'].toStringAsFixed(2)} mm²',
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _mostrarOpcionesArchivo(analysis),
                  ),
                );
              },
            ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Fecha inválida';
    }
  }
}
