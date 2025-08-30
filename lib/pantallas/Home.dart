import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo bacterias
          Positioned.fill(
            child: Image.asset('assets/purple-bacteria.png', fit: BoxFit.cover),
          ),

          // Capa negra encima
          Container(color: Colors.black.withOpacity(0.8)),

          // Contenido
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/Icon.png',
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),

                    // Imagen del nombre
                    Image.asset(
                      'assets/Logo-Blanco.png',
                      height: 50,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 12),

                    // Eslogan
                    const Text(
                      'Precisión microbiológica\nen la palma de tu mano',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFCCCCCC),
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Botón Sign Up
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF33133B),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: const BorderSide(color: Color(0xFF64316B)),
                          ),
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Enlace para crear cuenta
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        'Create an account',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64316B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
