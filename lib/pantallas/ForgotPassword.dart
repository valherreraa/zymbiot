import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      _showSnackBar('Por favor, ingresa tu correo electrónico', isError: true);
      return;
    }

    // Validar formato de email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      _showSnackBar(
        'Por favor, ingresa un correo electrónico válido',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());

      if (mounted) {
        _showSnackBar(
          'Se ha enviado un correo para restablecer tu contraseña. Revisa tu bandeja de entrada.',
          isError: false,
        );

        // Esperar un momento para que el usuario vea el mensaje
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage =
              'No se encontró una cuenta con este correo electrónico';
          break;
        case 'invalid-email':
          errorMessage = 'El formato del correo electrónico no es válido';
          break;
        case 'too-many-requests':
          errorMessage = 'Demasiados intentos. Intenta de nuevo más tarde';
          break;
        default:
          errorMessage = 'Error al enviar el correo. Intenta de nuevo';
      }
      _showSnackBar(errorMessage, isError: true);
    } catch (e) {
      _showSnackBar('Error inesperado. Intenta de nuevo', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: isError
              ? Colors.red.shade600
              : const Color.fromARGB(255, 209, 185, 249),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.asset('assets/bg.png', fit: BoxFit.cover),
          ),

          // Contenido
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Header con botón de regreso
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Recuperar Contraseña',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: 'Orbitron',
                        ),
                      ),
                    ],
                  ),

                  // Contenido principal
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Icono central
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF33133B).withOpacity(0.3),
                                border: Border.all(
                                  color: const Color(0xFF64316B),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.email_outlined,
                                size: 64,
                                color: Color(0xFF64316B),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Título
                            const Text(
                              '¿Olvidaste tu\ncontraseña?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Orbitron',
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Descripción
                            const Text(
                              'No te preocupes, ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                color: Colors.white70,
                                height: 1.5,
                              ),
                            ),

                            const SizedBox(height: 40),

                            // Campo de email
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              enabled: !_isLoading,
                              decoration: InputDecoration(
                                hintText: 'Ingresa tu correo electrónico',
                                hintStyle: const TextStyle(
                                  color: Colors.white70,
                                  fontFamily: 'Poppins',
                                ),
                                prefixIcon: const Icon(
                                  Icons.email_outlined,
                                  color: Colors.white70,
                                ),
                                filled: true,
                                fillColor: const Color(0xFF272531),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF64316B),
                                    width: 2,
                                  ),
                                ),
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Botón de enviar
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _resetPassword,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  backgroundColor: const Color(0xFF33133B),
                                  disabledBackgroundColor: const Color(
                                    0xFF33133B,
                                  ).withOpacity(0.6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    side: BorderSide(
                                      color: _isLoading
                                          ? const Color(
                                              0xFF64316B,
                                            ).withOpacity(0.5)
                                          : const Color(0xFF64316B),
                                    ),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : const Text(
                                        'Enviar Correo',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Orbitron',
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Botón de regresar
                            TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => Navigator.pop(context),
                              child: const Text(
                                'Regresar al inicio de sesión',
                                style: TextStyle(
                                  color: Color(0xFF64316B),
                                  fontSize: 14,
                                  fontFamily: 'Orbitron',
                                  fontWeight: FontWeight.w500,
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
            ),
          ),
        ],
      ),
    );
  }
}
