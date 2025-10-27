import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Fondo de pantalla
          Positioned.fill(
            child: Image.asset('assets/bg3.gif', fit: BoxFit.cover),
          ),
          Container(color: Colors.black.withOpacity(0.8)),

          SafeArea(
            child: Column(
              children: [
                // Header con botón de regreso
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Aviso de Privacidad',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Orbitron',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Contenido scrollable
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

               

                        const SizedBox(height: 24),

                        // Párrafo introductorio
                        _buildIntroCard(),

                        const SizedBox(height: 20),

                        // Sección 1
                        _buildSection(
                          '1.',
                          'Datos personales que se recopilan',
                          'La aplicación Zymbiot puede recopilar los siguientes datos personales proporcionados directamente por el usuario al registrarse o utilizar las funciones de la app:\n\n'
                              '• Nombre y apellidos\n'
                              '• Correo electrónico\n'
                              '• Fotografía o imágenes cargadas para análisis\n'
                              '• Datos técnicos del dispositivo (versión del sistema operativo, identificador único y permisos de cámara o almacenamiento)\n\n'
                              'Zymbiot no recopila información de ubicación geográfica ni datos sensibles que revelen origen étnico, estado de salud, orientación sexual u otra información de carácter personal.',
                        ),

                        const SizedBox(height: 16),

                        // Sección 2
                        _buildSection(
                          '2.',
                          'Finalidad del tratamiento de los datos',
                          'Los datos personales recabados se utilizan exclusivamente para los siguientes fines:\n\n'
                              '• Creación y gestión de cuentas de usuario dentro de la aplicación.\n'
                              '• Procesamiento de imágenes con fines de análisis microbiológico automatizado mediante visión por computadora.\n'
                              '• Generación y almacenamiento de reportes de resultados en formato digital.\n'
                              '• Mejora continua del servicio, monitoreo de desempeño y resolución de incidencias técnicas.\n\n'
                              'Los datos se tratarán bajo los principios de licitud, confidencialidad, proporcionalidad y seguridad, y no serán utilizados para fines distintos a los establecidos sin el consentimiento del usuario.',
                        ),

                        const SizedBox(height: 16),

                        // Sección 3
                        _buildSection(
                          '3.',
                          'Transferencia y uso de datos por terceros',
                          'Zymbiot utiliza servicios externos que intervienen en el funcionamiento de la aplicación, con los cuales se comparten únicamente los datos necesarios para su operación:\n\n'
                              '• Firebase (Google LLC): para autenticación, almacenamiento seguro de información y base de datos en la nube.\n'
                              '• Roboflow Inc.: para el procesamiento y análisis de imágenes mediante inteligencia artificial.\n\n'
                              'Ambas plataformas aplican estándares internacionales de seguridad, encriptación y protección de datos, garantizando que la información del usuario sea tratada de forma segura y únicamente con fines técnicos y analíticos relacionados con el funcionamiento de la aplicación.\n\n'
                              'Zymbiot no vende, renta ni comercializa datos personales de los usuarios a terceros.',
                        ),

                        const SizedBox(height: 16),

                        // Sección 4
                        _buildSection(
                          '4.',
                          'Cambios al aviso de privacidad',
                          'Cualquier modificación al presente Aviso de Privacidad será notificada dentro de la aplicación Zymbiot.',
                        ),

                        const SizedBox(height: 40),

                        // Footer
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.security,
                                  color: Color(0xFF64316B),
                                  size: 32,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Tus datos están protegidos',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Orbitron',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: const Text(
        'Comprometida con la protección de los datos personales de sus usuarios, se emite el presente Aviso de Privacidad en cumplimiento con la normativa aplicable en materia de protección de datos.',
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Poppins',
          fontSize: 16,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildSection(String number, String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF64316B),
            brightness: Brightness.dark,
          ),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF64316B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Orbitron',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Orbitron',
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          iconColor: Colors.white,
          collapsedIconColor: Colors.white70,
          children: [
            Text(
              content,
              style: const TextStyle(
                color: Colors.white70,
                fontFamily: 'Poppins',
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
