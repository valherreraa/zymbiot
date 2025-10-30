import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'ForgotPassword.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _selectedAvatar = 'assets/avatar.png';
  final List<String> _avatarOptions = [
    'assets/avatar.png',
    'assets/avatar2.png',
  ];
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Recargar el usuario para obtener los datos más recientes
      await user.reload();
      final freshUser = _auth.currentUser;

      setState(() {
        _usernameController.text = freshUser?.displayName ?? 'Usuario';
        _emailController.text = freshUser?.email ?? '';
        // Cargar el avatar guardado o usar el predeterminado
        _selectedAvatar = freshUser?.photoURL ?? 'assets/avatar.png';
      });
    }
  }

  Future<void> _updateProfile() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Actualizar nombre de usuario y avatar
        await user.updateProfile(
          displayName: _usernameController.text,
          photoURL: _selectedAvatar,
        );

        // Recargar el usuario para obtener los cambios más recientes
        await user.reload();

        // Actualizar el estado local con los nuevos datos
        await _loadUserData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil actualizado correctamente'),
              backgroundColor: Color.fromARGB(255, 209, 185, 249),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } catch (e) {
      if (mounted) {
        // Verificar si el widget está montado antes de mostrar el SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEditDialog() {
    // Crear una copia temporal para el diálogo
    String tempSelectedAvatar = _selectedAvatar;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Editar Perfil'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de usuario',
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Seleccionar avatar:'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _avatarOptions
                      .map(
                        (avatar) => GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              tempSelectedAvatar = avatar;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: tempSelectedAvatar == avatar
                                    ? Colors.blue
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundImage: AssetImage(avatar),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                // Actualizar el avatar seleccionado
                setState(() {
                  _selectedAvatar = tempSelectedAvatar;
                });

                // Guardar los cambios
                await _updateProfile();
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/bg3.gif', fit: BoxFit.cover),
          ),
          Container(color: Colors.black.withOpacity(0.8)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage(_selectedAvatar),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _usernameController.text,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Orbitron',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _emailController.text,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildButton('Editar Perfil', _showEditDialog),
                    const SizedBox(height: 16),
                    _buildButton(
                      'Cambiar Correo',
                      () => _showChangeEmailDialog(),
                    ),
                    const SizedBox(height: 16),
                    _buildButton(
                      'Cambiar Contraseña',
                      () => _showChangePasswordDialog(),
                    ),
                    const SizedBox(height: 24),
                    _buildButton('Cerrar Sesión', _signOut, isPrimary: true),
                    const SizedBox(
                      height: 80,
                    ), // Espacio para la barra de navegación
                  ],
                ),
              ),
            ),
          ),
          // Barra de navegación
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
                    icon: const Icon(Icons.person, color: Colors.white),
                    onPressed: () {
                      // Ya estamos en la pantalla de perfil
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.home_outlined, color: Colors.white),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/principal');
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.folder_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/files');
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

  Widget _buildButton(
    String text,
    VoidCallback onPressed, {
    bool isPrimary = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: isPrimary
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF33133B),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: const BorderSide(color: Color(0xFF64316B)),
                ),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Orbitron',
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white30),
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.white12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Orbitron',
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
    );
  }

  void _showChangeEmailDialog() {
    final TextEditingController newEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF33133B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF64316B), width: 1),
        ),
        title: const Text(
          'Cambiar Correo Electrónico',
          style: TextStyle(color: Colors.white, fontFamily: 'Orbitron'),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ingresa tu nuevo correo electrónico:',
                style: TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Poppins',
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newEmailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'nuevo@ejemplo.com',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF272531),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF64316B),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Nota: Necesitarás verificar tu nuevo correo electrónico antes de que el cambio sea efectivo.',
                style: TextStyle(
                  color: Color.fromARGB(255, 253, 253, 253),
                  fontFamily: 'Poppins',
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () async {
              final newEmail = newEmailController.text.trim();

              if (newEmail.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor, ingresa un correo electrónico'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Validar formato de email
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(newEmail)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Por favor, ingresa un correo electrónico válido',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context);
              await _updateUserEmail(newEmail);
            },
            child: const Text(
              'Cambiar Correo',
              style: TextStyle(
                color: Color(0xFF64316B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateUserEmail(String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Verificar si el usuario necesita reautenticarse
        await user.verifyBeforeUpdateEmail(newEmail);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Se ha enviado un correo de verificación a tu nueva dirección. Verifica el correo para completar el cambio.',
              ),
              backgroundColor: Color.fromARGB(255, 209, 185, 249),
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage =
              'Este correo electrónico ya está siendo usado por otra cuenta';
          break;
        case 'invalid-email':
          errorMessage = 'El formato del correo electrónico no es válido';
          break;
        case 'requires-recent-login':
          errorMessage =
              'Por seguridad, necesitas iniciar sesión nuevamente antes de cambiar tu correo';
          break;
        default:
          errorMessage = 'Error al cambiar el correo: ${e.message}';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF33133B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF64316B), width: 1),
        ),
        title: const Text(
          'Cambiar Contraseña',
          style: TextStyle(color: Colors.white, fontFamily: 'Orbitron'),
        ),
        content: const Text(
          'Serás redirigido a la pantalla de recuperación de contraseña donde podrás solicitar un correo para cambiar tu contraseña de forma segura.',
          style: TextStyle(
            color: Colors.white70,
            fontFamily: 'Poppins',
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navegar a la pantalla de recuperación de contraseña
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ForgotPasswordScreen(),
                ),
              );
            },
            child: const Text(
              'Continuar',
              style: TextStyle(
                color: Color(0xFF64316B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
