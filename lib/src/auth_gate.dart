import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_shell.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snap.data == null) {
          return const _AuthPage();
        }
        return const HomeShell();
      },
    );
  }
}

class _AuthPage extends StatefulWidget {
  const _AuthPage();

  @override
  State<_AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<_AuthPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool busy = false;
  String? error;

  Future<void> _signIn(bool isRegister) async {
    setState(() { busy = true; error = null; });
    try {
      final auth = FirebaseAuth.instance;
      if (isRegister) {
        await auth.createUserWithEmailAndPassword(email: email.text.trim(), password: password.text);
      } else {
        await auth.signInWithEmailAndPassword(email: email.text.trim(), password: password.text);
      }
    } on FirebaseAuthException catch (e) {
      setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in to PlayLog')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            const SizedBox(height: 16),
            if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: busy ? null : () => _signIn(false),
              child: const Text('Sign in'),
            ),
            TextButton(
              onPressed: busy ? null : () => _signIn(true),
              child: const Text('Create account'),
            ),
          ],
        ),
      ),
    );
  }
}
