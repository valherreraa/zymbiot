import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;

class ZymbiotAnalysisService {
  
  // GESTIÓN DE DIRECTORIOS LOCALES

  Future<String> _getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final analysisDir = Directory('${directory.path}/analysis_results');
    if (!await analysisDir.exists()) {
      await analysisDir.create(recursive: true);
    }
    return analysisDir.path;
  }

  // FUNCIÓN PRINCIPAL PARA ANALIZAR RESULTADOS JSON

  Future<Map<String, dynamic>> analizarResultadosJSON(
    Map<String, dynamic> roboflowResponse,
    File imagenOriginal,
  ) async {
    try {
      print('Iniciando análisis de resultados JSON');

      // Generar timestamp único para todos los archivos
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Obtener dimensiones de la imagen
      final bytes = await imagenOriginal.readAsBytes();
      final img.Image imagen = img.decodeImage(bytes)!;
      final double anchoImagenPx = imagen.width.toDouble();

      print('Dimensiones de imagen: ${imagen.width}x${imagen.height}');

      // Procesar las predicciones del JSON
      final resultados = procesarResultados(roboflowResponse, anchoImagenPx);

      print('Predicciones procesadas: ${resultados.length}');

      // Generar imagen anotada con timestamp único
      final imagenAnotada = await generarImagenConIDs(
        imagenOriginal,
        resultados,
        timestamp,
      );

      // Generar PDF con timestamp único
      final pdfFile = await generarPDF(
        resultados,
        imagenOriginal,
        imagenAnotada,
        timestamp,
      );

      // Guardar resultados completos con timestamp único
      await guardarResultadosCompletos(
        roboflowResponse,
        resultados,
        imagenOriginal.path,
        timestamp,
      );

      return {
        'resultados': resultados,
        'total_detectado': resultados.length,
        'imagen_anotada': imagenAnotada.path,
        'pdf_reporte': pdfFile.path,
        'timestamp': timestamp,
      };
    } catch (e) {
      print('Error en análisis: $e');
      throw Exception('Error al analizar resultados: $e');
    }
  }

  // CONVERSIÓN DE ESCALA PIXELES → MILÍMETROS
  double calcularEscalaMM(double anchoPx) {
    const double diametroPlacaMM = 90.0; // diámetro real de la placa
    return diametroPlacaMM / anchoPx;
  }

  // CÁLCULOS GEOMÉTRICOS
  double calcularArea(List<Map<String, double>> puntos) {
    if (puntos.length < 3) return 0.0;

    double area = 0.0;
    for (int i = 0; i < puntos.length; i++) {
      int j = (i + 1) % puntos.length;
      area +=
          puntos[i]['x']! * puntos[j]['y']! - puntos[j]['x']! * puntos[i]['y']!;
    }
    return area.abs() / 2.0;
  }

  double calcularPerimetro(List<Map<String, double>> puntos) {
    if (puntos.length < 2) return 0.0;

    double perimetro = 0.0;
    for (int i = 0; i < puntos.length; i++) {
      int j = (i + 1) % puntos.length;
      double dx = puntos[j]['x']! - puntos[i]['x']!;
      double dy = puntos[j]['y']! - puntos[i]['y']!;
      perimetro += sqrt(dx * dx + dy * dy);
    }
    return perimetro;
  }

  double calcularCircularidad(double area, double perimetro) {
    if (perimetro == 0) return 0.0;
    return (4 * pi * area) / pow(perimetro, 2);
  }

  double calcularDiametro(double area) {
    return 2 * sqrt(area / pi);
  }

  // Calcular área aproximada desde bounding box si no hay puntos
  double calcularAreaDesdeBBox(Map<String, dynamic> prediccion) {
    final width = prediccion['width']?.toDouble() ?? 0.0;
    final height = prediccion['height']?.toDouble() ?? 0.0;
    // Aproximar como círculo inscrito en el rectángulo
    final radio = min(width, height) / 2;
    return pi * pow(radio, 2);
  }

  double calcularPerimetroDesdeBBox(Map<String, dynamic> prediccion) {
    final width = prediccion['width']?.toDouble() ?? 0.0;
    final height = prediccion['height']?.toDouble() ?? 0.0;
    // Aproximar como círculo inscrito en el rectángulo
    final radio = min(width, height) / 2;
    return 2 * pi * radio;
  }

  // PROCESAR RESPUESTA DEL MODELO ROBOFLOW

  List<Map<String, dynamic>> procesarResultados(
    Map<String, dynamic> roboflowResponse,
    double anchoImagenPx,
  ) {
    final escala = calcularEscalaMM(anchoImagenPx);
    final List predicciones = roboflowResponse["predictions"] ?? [];
    List<Map<String, dynamic>> resultados = [];

    print('Procesando ${predicciones.length} predicciones');

    for (int i = 0; i < predicciones.length; i++) {
      var prediccion = predicciones[i];

      double areaPx = 0.0;
      double perimetroPx = 0.0;
      double xCentro = prediccion['x']?.toDouble() ?? 0.0;
      double yCentro = prediccion['y']?.toDouble() ?? 0.0;

      // Verificar si hay puntos de segmentación
      if (prediccion.containsKey("points") && prediccion["points"] != null) {
        List<Map<String, double>> puntos = [];
        for (var pt in prediccion["points"]) {
          puntos.add({"x": pt["x"].toDouble(), "y": pt["y"].toDouble()});
        }

        if (puntos.isNotEmpty) {
          areaPx = calcularArea(puntos);
          perimetroPx = calcularPerimetro(puntos);

          // Calcular centro geométrico
          xCentro =
              puntos.map((e) => e["x"]!).reduce((a, b) => a + b) /
              puntos.length;
          yCentro =
              puntos.map((e) => e["y"]!).reduce((a, b) => a + b) /
              puntos.length;
        }
      } else {
        // Usar bounding box si no hay puntos
        areaPx = calcularAreaDesdeBBox(prediccion);
        perimetroPx = calcularPerimetroDesdeBBox(prediccion);
      }

      // Conversión a mm
      double areaMM = areaPx * pow(escala, 2);
      double perimetroMM = perimetroPx * escala;
      double diametroMM = calcularDiametro(areaMM);
      double circularidad = calcularCircularidad(areaMM, perimetroMM);

      resultados.add({
        "id": i + 1,
        "x": xCentro,
        "y": yCentro,
        "diametro": diametroMM,
        "area": areaMM,
        "perimetro": perimetroMM,
        "circularidad": circularidad,
        "confidence": prediccion['confidence']?.toDouble() ?? 0.0,
        "class": prediccion['class'] ?? 'unknown',
      });
    }

    print('Resultados procesados: ${resultados.length}');
    return resultados;
  }

  // CREAR IMAGEN ANOTADA CON IDs

  Future<File> generarImagenConIDs(
    File imagenOriginal,
    List<Map<String, dynamic>> resultados,
    int timestamp,
  ) async {
    final bytes = await imagenOriginal.readAsBytes();
    img.Image base = img.decodeImage(bytes)!;

    print('Generando imagen anotada con ${resultados.length} IDs');

    for (var halo in resultados) {
      final id = halo["id"];
      final x = halo["x"]?.toInt() ?? 0;
      final y = halo["y"]?.toInt() ?? 0;

      // Dibujar círculo de fondo blanco
      img.fillCircle(
        base,
        x: x,
        y: y,
        radius: 15,
        color: img.ColorRgb8(255, 255, 255),
      );

      // Dibujar borde del círculo en rojo
      img.drawCircle(
        base,
        x: x,
        y: y,
        radius: 15,
        color: img.ColorRgb8(255, 0, 0),
      );

      // Dibujar texto del ID
      img.drawString(
        base,
        "$id",
        font: img.arial14,
        x: x - 8,
        y: y - 7,
        color: img.ColorRgb8(255, 0, 0),
      );
    }

    final localPath = await _getLocalPath();
    final anotada = File(path.join(localPath, 'imagen_anotada_$timestamp.png'));
    await anotada.writeAsBytes(img.encodePng(base));

    print('Imagen anotada guardada en: ${anotada.path}');
    return anotada;
  }

  // GENERAR PDF FINAL

  Future<File> generarPDF(
    List<Map<String, dynamic>> resultados,
    File imagenOriginal,
    File imagenAnotada,
    int timestamp,
  ) async {
    print('Generando PDF con ${resultados.length} resultados');

    final pdf = pw.Document();

    // Leer imágenes
    final imagenOriginalBytes = await imagenOriginal.readAsBytes();
    final imagenAnotadaBytes = await imagenAnotada.readAsBytes();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          // Título
          pw.Center(
            child: pw.Text(
              "Resultados del análisis de halos de lisis",
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),

          // Resumen
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 1),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "RESUMEN DEL ANÁLISIS",
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  "Cantidad total de halos detectados: ${resultados.length}",
                ),
                pw.Text("Fecha: ${DateTime.now().toString().split('.')[0]}"),
                if (resultados.isNotEmpty) ...[
                  pw.Text(
                    "Diámetro promedio: ${(resultados.map((r) => r["diametro"]).reduce((a, b) => a + b) / resultados.length).toStringAsFixed(2)} mm",
                  ),
                  pw.Text(
                    "Área total: ${resultados.map((r) => r["area"]).reduce((a, b) => a + b).toStringAsFixed(2)} mm²",
                  ),
                ],
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Imagen original
          pw.Text(
            "Imagen Original:",
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            height: 200,
            child: pw.Image(pw.MemoryImage(imagenOriginalBytes)),
          ),
          pw.SizedBox(height: 20),

          // Imagen anotada
          pw.Text(
            "Imagen con IDs de halos:",
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            height: 200,
            child: pw.Image(pw.MemoryImage(imagenAnotadaBytes)),
          ),
          pw.SizedBox(height: 20),

          // Tabla de resultados
          pw.Text(
            "Mediciones detalladas:",
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),

          if (resultados.isNotEmpty)
            pw.Table.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.center,
              headers: [
                "ID",
                "Diámetro\n(mm)",
                "Área\n(mm²)",
                "Perímetro\n(mm)",
                "Circularidad",
                "Confianza",
              ],
              data: resultados.map((r) {
                return [
                  r["id"].toString(),
                  r["diametro"].toStringAsFixed(2),
                  r["area"].toStringAsFixed(2),
                  r["perimetro"].toStringAsFixed(2),
                  r["circularidad"].toStringAsFixed(3),
                  "${(r["confidence"] * 100).toStringAsFixed(1)}%",
                ];
              }).toList(),
            )
          else
            pw.Text("No se detectaron halos en la imagen."),
        ],
      ),
    );

    final localPath = await _getLocalPath();
    final file = File(path.join(localPath, 'reporte_halos_$timestamp.pdf'));
    await file.writeAsBytes(await pdf.save());

    print('PDF guardado en: ${file.path}');
    return file;
  }

  // GUARDAR RESULTADOS COMPLETOS

  Future<File> guardarResultadosCompletos(
    Map<String, dynamic> roboflowResponse,
    List<Map<String, dynamic>> resultados,
    String imagenPath,
    int timestamp,
  ) async {
    final localPath = await _getLocalPath();

    final resultadosCompletos = {
      'timestamp': timestamp,
      'fecha': DateTime.now().toIso8601String(),
      'imagen_original': imagenPath,
      'archivos_generados': {
        'pdf': 'reporte_halos_$timestamp.pdf',
        'imagen_anotada': 'imagen_anotada_$timestamp.png',
        'analisis_json': 'analisis_completo_$timestamp.json',
      },
      'roboflow_response': roboflowResponse,
      'resultados_procesados': resultados,
      'estadisticas': {
        'total_halos': resultados.length,
        'diametro_promedio': resultados.isNotEmpty
            ? resultados.map((r) => r["diametro"]).reduce((a, b) => a + b) /
                  resultados.length
            : 0.0,
        'area_total': resultados.isNotEmpty
            ? resultados.map((r) => r["area"]).reduce((a, b) => a + b)
            : 0.0,
      },
    };

    final file = File(
      path.join(localPath, 'analisis_completo_$timestamp.json'),
    );
    await file.writeAsString(jsonEncode(resultadosCompletos));

    print('Resultados completos guardados en: ${file.path}');
    return file;
  }

  // LISTAR ANÁLISIS GUARDADOS

  Future<List<Map<String, dynamic>>> listarAnalisisGuardados() async {
    try {
      final localPath = await _getLocalPath();
      final directory = Directory(localPath);

      if (!await directory.exists()) {
        return [];
      }

      final files = await directory.list().toList();
      final jsonFiles = files
          .where(
            (file) =>
                file.path.endsWith('.json') &&
                file.path.contains('analisis_completo'),
          )
          .cast<File>()
          .toList();

      List<Map<String, dynamic>> analisis = [];

      for (File file in jsonFiles) {
        try {
          final content = await file.readAsString();
          final data = jsonDecode(content);
          analisis.add({
            'archivo': file.path,
            'fecha': data['fecha'],
            'total_halos': data['estadisticas']['total_halos'],
            'diametro_promedio': data['estadisticas']['diametro_promedio'],
            'area_total': data['estadisticas']['area_total'],
            'timestamp': data['timestamp'],
            'archivos_generados': data['archivos_generados'] ?? {},
          });
        } catch (e) {
          print('Error leyendo archivo ${file.path}: $e');
        }
      }

      // Ordenar por fecha (más reciente primero)
      analisis.sort((a, b) => b['fecha'].compareTo(a['fecha']));
      return analisis;
    } catch (e) {
      print('Error listando análisis: $e');
      return [];
    }
  }

  // OBTENER RUTA DE ARCHIVO DE ANÁLISIS

  Future<String> getRutaAnalisis(String nombreArchivo) async {
    final localPath = await _getLocalPath();
    return '$localPath/$nombreArchivo';
  }

  // MÉTODO DE DEPURACIÓN - VERIFICAR ARCHIVOS

  Future<Map<String, bool>> verificarArchivosExisten(
    Map<String, dynamic> analysis,
  ) async {
    final resultado = <String, bool>{};

    try {
      // Verificar archivo JSON
      final file = File(analysis['archivo']);
      resultado['json'] = await file.exists();

      // Verificar archivos relacionados si están disponibles
      if (analysis['archivos_generados'] != null) {
        final archivosGenerados = analysis['archivos_generados'];

        if (archivosGenerados['pdf'] != null) {
          final rutaPDF = await getRutaAnalisis(archivosGenerados['pdf']);
          resultado['pdf'] = await File(rutaPDF).exists();
        }

        if (archivosGenerados['imagen_anotada'] != null) {
          final rutaImagen = await getRutaAnalisis(
            archivosGenerados['imagen_anotada'],
          );
          resultado['imagen'] = await File(rutaImagen).exists();
        }
      }

      print('Verificación de archivos para análisis:');
      print('JSON: ${resultado['json']}');
      print('PDF: ${resultado['pdf']}');
      print('Imagen: ${resultado['imagen']}');
    } catch (e) {
      print('Error verificando archivos: $e');
    }

    return resultado;
  }
}
