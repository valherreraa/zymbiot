import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class RoboflowService {
  // API Base URL
  static const String _apiUrl = "https://detect.roboflow.com";

  // Tu API key de Roboflow (asegúrate de que sea la correcta)
  static const String _apiKey = "rf_ByLqCZZ7COTvA3Yc8TP5vz3pPEV2";

  // Workspace y modelo
  static const String _workspace = "portaplacas";
  static const String _version = "3";
  static const String _model = "detect-count-and-visualize";

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

    // Copiar la imagen al directorio local
    final String imageName = 'image_$timestamp.jpg';
    final String localImagePath = path.join(localPath, imageName);
    await File(imageFilePath).copy(localImagePath);

    // Guardar los resultados en un archivo JSON
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

      // Construir la URL con el formato correcto para la API HTTP
      final url = Uri.parse('$_apiUrl/$_workspace/$_model/$_version');
      print('Enviando petición a Roboflow URL: ${url.toString()}');

      // Preparar el cuerpo de la petición
      final imageData = 'data:image/jpeg;base64,$base64Image';
      final requestBody = jsonEncode({'api_key': _apiKey, 'image': imageData});

      // Enviar la petición
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: requestBody,
      );

      print('Respuesta recibida. Código de estado: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Respuesta exitosa de la API');
        return responseData;
      } else {
        print('Error en la respuesta: ${response.body}');
        throw Exception(
          'Error en la API: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e, stackTrace) {
      print('Error detallado: $e');
      print('Stack trace: $stackTrace');
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
