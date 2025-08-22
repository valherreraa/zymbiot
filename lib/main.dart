import 'package:flutter/material.dart';
import 'pantallas/Home.dart';
import 'pantallas/Login.dart';
import 'pantallas/Register.dart';
import 'pantallas/Principal.dart';
import 'pantallas/Congrats.dart';
//firebase
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
