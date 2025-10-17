import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class RoboflowService {
  // API Base URL
  static const String _apiUrl = "https://detect.roboflow.com";

  // API key de Roboflow
  static const String _apiKey = "rf_ByLqCZZ7COTvA3Yc8TP5vz3pPEV2";

  // Proyecto y versión del modelo
  static const String _projectId = "portaplacas";
  static const String _modelVersion = "3";
  Future<String> _getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final analysisDir = Directory('${directory.path}/analyses');
    if (!await analysisDir.exists()) {
      await analysisDir.create(recursive: true);
    }
    return analysisDir.path;
  }

  Future<void> saveAnalysisResults(
    Map<String, dynamic> results,
    String imageFilePath,
  ) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final localPath = await _getLocalPath();

    // Copia la imagen al directorio local
    final String imageName = 'image_$timestamp.jpg';
    final String localImagePath = path.join(localPath, imageName);
    await File(imageFilePath).copy(localImagePath);

    // Guardar resultados en un archivo JSON
    final String resultsName = 'results_$timestamp.json';
    final String resultsPath = path.join(localPath, resultsName);
    await File(resultsPath).writeAsString(
      jsonEncode({
        'timestamp': timestamp,
        'imagePath': localImagePath,
        'results': results,
      }),
    );
  }

  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    try {
      print('Iniciando análisis de imagen: ${imageFile.path}');

      // Verificar que el archivo existe
      if (!await imageFile.exists()) {
        throw Exception('El archivo de imagen no existe en: ${imageFile.path}');
      }

      // Verificar tamaño del archivo
      final fileSize = await imageFile.length();
      print('Tamaño del archivo: ${(fileSize / 1024).toStringAsFixed(2)} KB');

      // Convertir la imagen a base64
      final List<int> imageBytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(imageBytes);
      print('Imagen convertida a base64. Longitud: ${base64Image.length}');

      final payload = base64Image.startsWith('data:image')
          ? base64Image
          : 'data:image/jpeg;base64,$base64Image';

      // Construir la URL para la API de workflows
      // final url = Uri.parse(
      //   'https://serverless.roboflow.com/infer/workflows/$_projectId/detect-count-and-visualize-3',
      // );
      final url = Uri.parse(
        'https://serverless.roboflow.com/culture-media-3lxam/1'
        '?api_key=yeWujAFWX0ZvG0wwu4Fs'
        '&format=json'
      );
      print('Enviando petición a Roboflow URL: ${url.toString()}');

      // Preparar el cuerpo de la petición en formato JSON
      print('POST $url');
      final resp = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: payload,
      );
      print('Respuesta recibida. Código de estado: ${resp.statusCode}');

      if(resp.statusCode == 200) {
        return json.decode(resp.body) as Map<String, dynamic>;
      } else {
        print('Error en la respuesta: ${resp.body}');
        throw Exception(
          'Error en la API: ${resp.statusCode} - ${resp.body}',
        );
      }
    } catch (e, st) {
      print('Error detallado: $e');
      print('Stack trace: $st');
      throw Exception('Error al analizar la imagen: $e');
    }
  }

  // Método para procesar los resultados
  Map<String, dynamic> processResults(Map<String, dynamic> apiResponse) {
    // Extraer las predicciones
    final predictions = apiResponse['predictions'] as List? ?? [];

    return {
      'predictions': predictions,
      'detected_objects': predictions
          .map(
            (pred) => {
              'class': pred['class'],
              'confidence': pred['confidence'],
              'bbox': {
                'x':
                    pred['x'] -
                    (pred['width'] /
                        2), // Convertir a formato x,y esquina superior izquierda
                'y': pred['y'] - (pred['height'] / 2),
                'width': pred['width'],
                'height': pred['height'],
              },
            },
          )
          .toList(),
      'time': DateTime.now().millisecondsSinceEpoch,
    };
  }
}

  //           'value': 'data:image/jpeg;base64,$base64Image',
  //         },
  //       },
  //     });

  //     // Enviar la petición usando JSON
  //     final response = await http.post(
  //       url,
  //       headers: {'Content-Type': 'application/json'},
  //       body: requestBody,
  //     );

  //     print('Respuesta recibida. Código de estado: ${response.statusCode}');

  //     if (response.statusCode == 200) {
  //       final responseData = json.decode(response.body);
  //       print('Respuesta exitosa de la API');
  //       return responseData;
  //     } else {
  //       print('Error en la respuesta: ${response.body}');
  //       throw Exception(
  //         'Error en la API: ${response.statusCode} - ${response.body}',
  //       );
  //     }
  //   } catch (e, stackTrace) {
  //     print('Error detallado: $e');
  //     print('Stack trace: $stackTrace');
  //     throw Exception('Error al analizar la imagen: $e');
  //   }
  // }

  // Método para procesar los resultados
  Map<String, dynamic> processResults(Map<String, dynamic> apiResponse) {
    // Extraer las predicciones
    final predictions = apiResponse['predictions'] as List? ?? [];

    return {
      'predictions': predictions,
      'detected_objects': predictions
          .map(
            (pred) => {
              'class': pred['class'],
              'confidence': pred['confidence'],
              'bbox': {
                'x':
                    pred['x'] -
                    (pred['width'] /
                        2), // Convertir a formato x,y esquina superior izquierda
                'y': pred['y'] - (pred['height'] / 2),
                'width': pred['width'],
                'height': pred['height'],
              },
            },
          )
          .toList(),
      'time': DateTime.now().millisecondsSinceEpoch,
    };
  }

