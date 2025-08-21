import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo de imagen estática
          Positioned.fill(
            child: Image.asset(
              'assets/purple-bacteria.png',
              fit: BoxFit.cover,
            ),
          ),


          // Capa negra translúcida encima del fondo
          Container(
            color: Colors.black.withOpacity(0.8),
          ),

          // Contenido principal
          SafeArea(
            child: Align(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo central
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Image.asset(
                          'assets/Icon.png',
                          height: 300,
                          semanticLabel: 'Zymbiot Logo',
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Botón Sign Up
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purpleAccent.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            textStyle: const TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: const BorderSide(color: Color(0xFFF4CAFF)),
                            ),
                          ),
                          child: const Text('Sign Up'),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Botón Sign In
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            textStyle: const TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text('Sign In'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
