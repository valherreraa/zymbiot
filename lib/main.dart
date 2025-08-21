import 'package:flutter/material.dart';
import 'pantallas/Home.dart';
import 'pantallas/Login.dart';
import 'pantallas/Register.dart';
import 'pantallas/Principal.dart';
import 'pantallas/Congrats.dart';

void main() {
  runApp(const ZymbiotApp());
}

class ZymbiotApp extends StatelessWidget {
  const ZymbiotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zymbiot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'Orbitron',
        ),
      ),
      initialRoute: '/home',  // Ruta inicial al Home
      routes: {
        '/home': (context) => const HomeScreen(),           // Ruta para Home
        '/login': (context) => const LoginScreen(),         // Ruta para Login
        '/register': (context) => const RegisterScreen(),   // Ruta para Register
        '/principal': (context) => const PrincipalScreen(), // Ruta para Principal
        '/congrats': (context) => const CongratulationsScreen(), // Ruta para Congrats
      },
    );
  }
}
