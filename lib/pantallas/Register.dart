import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Create your account',
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
                  decoration: InputDecoration(
                    hintText: 'Email',
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
                    fontFamily: 'Orbitron',
                  ),
                ),
                const SizedBox(height: 16),

                // Password
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
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
                    fontFamily: 'Orbitron',
                  ),
                ),
                const SizedBox(height: 16),

                // Confirm Password
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Confirm Password',
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
                    fontFamily: 'Orbitron',
                  ),
                ),
                const SizedBox(height: 24),

                // Login button with gradient
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF800080), Color(0xFFFF00FF)],
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement registration
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Divider
                const Row(
                  children: [
                    Expanded(
                      child: Divider(color: Colors.grey),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'OR',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Google Sign In Button (full width)
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Google Sign-In logic
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF800080),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
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
                          'Sign In with Google',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Orbitron',
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
    );
  }
}
