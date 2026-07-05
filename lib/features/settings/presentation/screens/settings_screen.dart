import 'package:flutter/material.dart';
import 'package:peng_houth_cycle/features/auth/presentation/providers/auth_provider.dart';
import 'package:peng_houth_cycle/features/auth/presentation/screens/login_screen.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // ── Account section ──
          if (auth.isLoggedIn && user != null) ...[
            ListTile(
              leading: CircleAvatar(
                child: Text(
                  user.firstname.isNotEmpty
                      ? user.firstname[0].toUpperCase()
                      : '?',
                ),
              ),
              title: Text(user.fullName),
              subtitle: Text(user.email),
            ),
            ListTile(
              leading: const Icon(Icons.phone_outlined),
              title: const Text('Phone'),
              subtitle: Text(user.phone),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () => context.read<AuthProvider>().logout(),
            ),
          ] else
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login / Register'),
              subtitle: const Text('Sign in to rent bikes'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
            ),
        ],
      ),
    );
  }
}
