// lib/signup_screen.dart
import 'package:flutter/material.dart';
import 'db_helper.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _loading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;

    setState(() => _loading = true);
    try {
      // Vérifier si username existe déjà
      final existing = await DBHelper.instance.getUserByUsername(username);
      if (existing != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nom d’utilisateur déjà pris.')),
        );
        return;
      }

      // Création de  l'utilisateur
      await DBHelper.instance.createUser(username, password);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compte créé. Connecte-toi maintenant.')),
      );

      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
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
      appBar: AppBar(
        title: const Text('Créer un compte'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: Column(
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: const [
                    Icon(Icons.note_alt, size: 48),
                    SizedBox(height: 8),
                    Text('Notes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 6),
                    Text('Crée un compte pour commencer', textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _usernameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nom d’utilisateur',
                      prefixIcon: Icon(Icons.person),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Requis';
                      if (v.trim().length < 3) return 'Au moins 3 caractères';
                      return null;
                    },
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
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Requis';
                      if (v.length < 6) return 'Au moins 6 caractères';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirmCtrl,
                    decoration: InputDecoration(
                      labelText: 'Confirmer le mot de passe',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    obscureText: _obscureConfirm,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Requis';
                      if (v != _passwordCtrl.text) return 'Ne correspond pas';
                      return null;
                    },
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Créer mon compte'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text('J’ai déjà un compte — Se connecter'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
