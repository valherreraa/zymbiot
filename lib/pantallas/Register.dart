import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  bool _isPasswordValid(String password) {
    // Al menos 6 caracteres
    if (password.length < 6) return false;

    // Debe contener al menos una letra minúscula
    if (!password.contains(RegExp(r'[a-z]'))) return false;

    // Debe contener al menos una letra mayúscula
    if (!password.contains(RegExp(r'[A-Z]'))) return false;

    // Debe contener al menos un número
    if (!password.contains(RegExp(r'[0-9]'))) return false;

    // Debe contener al menos un carácter especial
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;

    return true;
  }

  String _getPasswordRequirements() {
    return 'La contraseña debe contener:\n'
        '• Al menos 6 caracteres\n'
        '• Una letra minúscula (a-z)\n'
        '• Una letra mayúscula (A-Z)\n'
        '• Un número (0-9)\n'
        '• Un carácter especial (!@#\$%^&*...)';
  }

  Future<void> _showAlertDialog(String title, String message) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF33133B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF64316B)),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Orbitron',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF64316B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _register() async {
    // Validar campos vacíos
    if (_emailController.text.trim().isEmpty) {
      await _showAlertDialog(
        'Campo requerido',
        'Por favor, ingresa tu correo electrónico.',
      );
      return;
    }

    if (_passwordController.text.isEmpty) {
      await _showAlertDialog(
        'Campo requerido',
        'Por favor, ingresa una contraseña.',
      );
      return;
    }

    if (_confirmPasswordController.text.isEmpty) {
      await _showAlertDialog(
        'Campo requerido',
        'Por favor, confirma tu contraseña.',
      );
      return;
    }

    // Validar formato de correo electrónico básico
    if (!_emailController.text.contains('@') ||
        !_emailController.text.contains('.')) {
      await _showAlertDialog(
        'Correo inválido',
        'Por favor, ingresa un correo electrónico válido.',
      );
      return;
    }

    // Validar formato de contraseña
    if (!_isPasswordValid(_passwordController.text)) {
      await _showAlertDialog('Contraseña inválida', _getPasswordRequirements());
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      await _showAlertDialog(
        'Contraseñas no coinciden',
        'Las contraseñas ingresadas no son iguales. Por favor, verifícalas.',
      );
      return;
    }

    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );

      if (userCredential.user != null) {
        await userCredential.user!.sendEmailVerification();
        // ignore: use_build_context_synchronously
        await _showAlertDialog(
          'Registro exitoso',
          'Se ha enviado un correo de verificación a tu cuenta. Por favor, verifica tu correo antes de iniciar sesión.',
        );
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/login');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'La contraseña es muy débil.';
          break;
        case 'email-already-in-use':
          errorMessage = 'Ya existe una cuenta con este correo electrónico.';
          break;
        case 'invalid-email':
          errorMessage = 'El formato del correo electrónico no es válido.';
          break;
        case 'operation-not-allowed':
          errorMessage =
              'El registro con correo electrónico no está habilitado.';
          break;
        default:
          errorMessage = 'Error de registro: ${e.message}';
      }
      await _showAlertDialog('Error de registro', errorMessage);
    } catch (e) {
      await _showAlertDialog(
        'Error',
        'Ocurrió un error inesperado. Por favor, inténtalo de nuevo.',
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      // Cerrar sesión anterior para forzar selección de cuenta
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      if (userCredential.user != null) {
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, '/congrats');
      }
    } catch (e) {
      await _showAlertDialog(
        'Error de Google Sign-In',
        'No se pudo registrarse con Google. Por favor, inténtalo de nuevo.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo de imagen
          Positioned.fill(
            child: Image.asset('assets/bg.png', fit: BoxFit.cover),
          ),

          // Contenido principal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Crea tu\ncuenta',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 24),

                    // Email
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'hola@ejemplo.com',
                        hintStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF272531),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: '.............',
                        hintStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF272531),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Confirm Password
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: '.............',
                        hintStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF272531),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Requisitos de contraseña
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const Text(
                        'La contraseña debe tener al menos 6 caracteres e incluir:\n'
                        '• Una minúscula (a-z) • Una mayúscula (A-Z)\n'
                        '• Un número (0-9) • Un carácter especial (!@#\$%...)',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Botón Register
                    ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF33133B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(color: Color(0xFF64316B)),
                        ),
                      ),
                      child: const Text(
                        'Registrarse',
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Divider
                    const Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'O',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Botón de Google
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _signInWithGoogle,
                        style: TextButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            58,
                            57,
                            58,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: const BorderSide(
                              color: Color.fromARGB(255, 58, 57, 58),
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/google-icon.svg',
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Ingresa con Google',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                                color: Colors.white,
                              ),
                            ),
                          ],
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
