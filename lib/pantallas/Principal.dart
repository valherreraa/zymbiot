import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/roboflow_service.dart';
import '../services/analysis.dart';
import 'Profile.dart';
import 'Files.dart';
import 'Settings.dart';

class PrincipalScreen extends StatefulWidget {
  const PrincipalScreen({super.key});

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  final RoboflowService _roboflowService = RoboflowService();
  final ZymbiotAnalysisService _analysisService = ZymbiotAnalysisService();
  String? _userName;
  String? _userAvatar;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recargar datos cuando regresamos a esta pantalla
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Recargar el usuario para obtener los datos más recientes
      await user.reload();
      final freshUser = _auth.currentUser;

      setState(() {
        _userName = freshUser?.displayName ?? 'Usuario';
        _userAvatar = freshUser?.photoURL ?? 'assets/avatar.png';
      });
    }
  }

  Future<void> _takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        // Mostrar indicador de carga
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );

        final file = File(photo.path);

        // Analizar la imagen con Roboflow
        final apiResponse = await _roboflowService.analyzeImage(file);

        // Procesar resultados y generar PDF
        final analysisResults = await _analysisService.analizarResultadosJSON(
          apiResponse,
          file,
        );

        // Cerrar el indicador de carga
        Navigator.pop(context);

        // Mostrar mensaje de éxito con detalles
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Análisis completo! ${analysisResults['total_detectado']} halos detectados. PDF generado.',
            ),
            backgroundColor: const Color.fromARGB(255, 209, 185, 249),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Ver archivos',
              onPressed: () {
                // TODO: Navegar a pantalla de archivos generados
                print('PDF: ${analysisResults['pdf_reporte']}');
                print('Imagen: ${analysisResults['imagen_anotada']}');
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Cerrar el indicador de carga si hay error
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _uploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        // Mostrar indicador de carga
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );

        final file = File(image.path);

        // Analizar la imagen con Roboflow
        final apiResponse = await _roboflowService.analyzeImage(file);

        // Procesar resultados y generar PDF
        final analysisResults = await _analysisService.analizarResultadosJSON(
          apiResponse,
          file,
        );

        // Cerrar el indicador de carga
        Navigator.pop(context);

        // Mostrar mensaje de éxito con detalles
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Análisis completo! ${analysisResults['total_detectado']} halos detectados. PDF generado.',
            ),
            backgroundColor: const Color.fromARGB(255, 209, 185, 249),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Ver archivos',
              onPressed: () {
                // TODO: Navegar a pantalla de archivos generados
                print('PDF: ${analysisResults['pdf_reporte']}');
                print('Imagen: ${analysisResults['imagen_anotada']}');
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Cerrar el indicador de carga si hay error
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Fondo
          Positioned.fill(
            child: Image.asset('assets/bg3.gif', fit: BoxFit.cover),
          ),

          // Contenido principal
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage(
                          _userAvatar ?? 'assets/avatar.png',
                        ),
                        radius: 20,
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  Text(
                    'Hola, ${_userName ?? "Usuario"}!',
                    style: const TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Bienvenido a Zymbiot',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),

                  const SizedBox(height: 200),

                  // Botón 1
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _takePicture,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF33133B),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(color: Color(0xFF64316B)),
                        ),
                      ),
                      child: const Text(
                        'Abrir Cámara',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Botón 2
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _uploadImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white12,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(color: Colors.white30),
                        ),
                      ),
                      child: const Text(
                        'Subir Imagen',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),

          // Bottom navigation bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.person_outline, color: Colors.white),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                      // Recargar datos cuando regresamos del perfil
                      _loadUserData();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.home, color: Colors.white),
                    onPressed: () {
                      // Ya estamos en la pantalla principal
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.folder_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FilesScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
