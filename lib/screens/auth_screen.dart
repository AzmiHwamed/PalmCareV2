import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginEmail = TextEditingController();
  final _loginPassword = TextEditingController();
  final _registerEmail = TextEditingController();
  final _registerPassword = TextEditingController();
  final _registerConfirm = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _message = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _showMessage(String msg) {
    setState(() {
      _message = msg;
    });
  }

  Future<void> _login() async {
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _loginEmail.text.trim(),
        password: _loginPassword.text,
      );
      if (response.user != null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        _showMessage("Échec de connexion. Vérifiez vos données.");
      }
    } catch (e) {
      _showMessage("Erreur: ${e.toString()}");
    }
  }

  Future<void> _register() async {
    if (_registerPassword.text != _registerConfirm.text) {
      _showMessage("Les mots de passe ne correspondent pas.");
      return;
    }

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: _registerEmail.text.trim(),
        password: _registerPassword.text,
      );
      if (response.user != null) {
        _showMessage("Inscription réussie! Connectez-vous.");
        _tabController.animateTo(0);
      } else {
        _showMessage("Erreur lors de l'inscription.");
      }
    } catch (e) {
      _showMessage("Erreur: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text("PalmCare Auth"),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.yellow.shade600,
          tabs: const [
            Tab(text: "Se connecter"),
            Tab(text: "S'inscrire"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // LOGIN
          _buildLoginForm(),
          // REGISTER
          _buildRegisterForm(),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          TextField(
            controller: _loginEmail,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: _loginPassword,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Mot de passe'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _login,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Connexion'),
          ),
          if (_message.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(_message, style: const TextStyle(color: Colors.red)),
          ]
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          TextField(
            controller: _registerEmail,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: _registerPassword,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Mot de passe'),
          ),
          TextField(
            controller: _registerConfirm,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Confirmer le mot de passe'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _register,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text("S'inscrire"),
          ),
          if (_message.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(_message, style: const TextStyle(color: Colors.red)),
          ]
        ],
      ),
    );
  }
}
