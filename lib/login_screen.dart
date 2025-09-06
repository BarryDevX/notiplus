// lib/login_screen.dart
import 'package:flutter/material.dart';
import 'db_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscurePass = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;

    setState(() => _loading = true);
    try {
      final user = await DBHelper.instance.getUserByUsername(username);

      if (user == null || user['password'] != password) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Identifiants incorrects')),
        );
        return;
      }

      //  connexion réussie
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bienvenue $username !')),
      );

      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/notes', arguments: user['id']);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(Icons.lock_outline, size: 64),
              const SizedBox(height: 20),
              TextFormField(
                controller: _usernameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nom d’utilisateur',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtrl,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePass = !_obscurePass),
                  ),
                ),
                obscureText: _obscurePass,
                validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('Se connecter'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/signup');
                },
                child: const Text('Pas encore de compte ? Créez-en un'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
