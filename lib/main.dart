import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'signup_screen.dart';
import 'login_screen.dart';
import 'notes_list_screen.dart'; // Import de NotesListScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.instance.init();

  // Vérifie s'il existe déjà un compte
  final hasUser = await DBHelper.instance.hasAnyUser();

  runApp(MyApp(initialRoute: hasUser ? '/login' : '/signup'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({required this.initialRoute, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Application de Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      initialRoute: initialRoute,
      routes: {
        '/signup': (context) => const SignUpScreen(),
        '/login': (context) => const LoginScreen(),
        '/notes': (context) => const NotesListScreen(), // route mise à jour
      },
    );
  }
}
