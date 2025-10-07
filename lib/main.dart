import 'package:flutter/material.dart';
import 'pantallas/Home.dart';
import 'pantallas/Login.dart';
import 'pantallas/Register.dart';
import 'pantallas/Principal.dart';
import 'pantallas/Congrats.dart';
import 'pantallas/NavigationBar.dart';
import 'pantallas/Profile.dart';
import 'pantallas/Library.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase con las opciones generadas
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Orbitron'),
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/principal': (context) => const PrincipalScreen(),
        '/congrats': (context) => const CongratulationsScreen(),
        '/customnavigationBar': (context) => const CustomNavigationBar(),
        '/profile': (context) => const ProfileScreen(),
        '/library': (context) => const LibraryScreen(),
      },
    );
  }
}
