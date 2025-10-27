import 'package:flutter/material.dart';
import 'PrivacyPolicy.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avisos'),
        backgroundColor: const Color(0xFF64316B),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.warning_rounded),
            title: const Text('Aviso de Privacidad'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.announcement_rounded),
            title: const Text('Acerca de la App'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Acerca de Zymbiot'),
                  content: const SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Versión: 2.0.0'),
                        SizedBox(height: 8),
                        Text(
                          'Zymbiot es una aplicación móvil desarrollada para automatizar el análisis de halos de lisis en placas Petri mediante visión por computadora e inteligencia artificial. Su objetivo es facilitar la evaluación de la eficiencia de fagos y otros agentes antimicrobianos, reduciendo la subjetividad y el tiempo requeridos en los análisis manuales.',
                          style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
