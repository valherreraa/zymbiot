import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

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
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _usernameController.text = user.displayName ?? 'Usuario';
        _emailController.text = user.email ?? '';
      });
    }
  }

  Future<void> _updateProfile() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(_usernameController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado correctamente')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al actualizar perfil: $e')));
    }
  }

  Future<void> _changeEmail() async {
    try {
      if (_emailController.text.isEmpty) {
        throw 'El correo no puede estar vacío';
      }
      final user = _auth.currentUser;
      if (user != null) {
        // Re-autenticar al usuario antes de cambiar el correo
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _passwordController.text,
        );
        await user.reauthenticateWithCredential(credential);
        await user.verifyBeforeUpdateEmail(_emailController.text);

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Se ha enviado un correo de verificación a la nueva dirección',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      String errorMessage = 'Error al actualizar correo';
      if (e.toString().contains('invalid-email')) {
        errorMessage = 'Correo electrónico inválido';
      } else if (e.toString().contains('email-already-in-use')) {
        errorMessage = 'Este correo ya está en uso';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _changePassword() async {
    try {
      if (_passwordController.text.length < 6) {
        throw 'La contraseña debe tener al menos 6 caracteres';
      }

      final user = _auth.currentUser;
      if (user != null) {
        // Enviar correo de restablecimiento de contraseña
        await _auth.sendPasswordResetEmail(email: user.email!);

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Se ha enviado un correo para cambiar tu contraseña'),
            backgroundColor: Colors.green,
          ),
        );

        // Limpiar el campo de contraseña
        _passwordController.clear();
      }
    } catch (e) {
      String errorMessage = 'Error al enviar el correo de cambio de contraseña';
      if (e.toString().contains('weak-password')) {
        errorMessage = 'La contraseña es demasiado débil';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cerrar sesión: $e')));
    }
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _avatarOptions
                    .map(
                      (avatar) => GestureDetector(
                        onTap: () {
                          setState(() => _selectedAvatar = avatar);
                          Navigator.pop(context);
                        },
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(avatar),
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
            onPressed: () {
              _updateProfile();
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
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
                      radius: 50,
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
    final TextEditingController currentPasswordController =
        TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Correo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Nuevo correo'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: currentPasswordController,
              decoration: const InputDecoration(labelText: 'Contraseña actual'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              currentPasswordController.dispose();
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              _passwordController.text = currentPasswordController.text;
              _changeEmail();
              currentPasswordController.dispose();
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Contraseña'),
        content: TextField(
          controller: _passwordController,
          decoration: const InputDecoration(labelText: 'Nueva contraseña'),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              _changePassword();
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
