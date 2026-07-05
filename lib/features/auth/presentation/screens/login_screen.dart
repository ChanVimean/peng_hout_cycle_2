import 'package:flutter/material.dart';
import 'package:peng_houth_cycle/core/enum/app_state.dart';
import 'package:peng_houth_cycle/core/widgets/app_button.dart';
import 'package:peng_houth_cycle/core/widgets/app_textfield.dart';
import 'package:peng_houth_cycle/features/auth/presentation/providers/auth_provider.dart';
import 'package:peng_houth_cycle/features/auth/presentation/screens/register_screen.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ok = await context.read<AuthProvider>().login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (ok && mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();
    final isLoading = provider.state == AppState.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
            AppTextField(
              controller: _passwordController,
              label: 'Password',
              isPassword: true,
            ),
            const SizedBox(height: 8),
            if (provider.state == AppState.error)
              Text(
                provider.errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16),
            AppButton(
              'Login',
              isLoading: isLoading,
              onTap: isLoading ? null : _submit,
            ),
            AppButton(
              'Register',
              variant: ButtonVariant.text,
              onTap: isLoading
                  ? null
                  : () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
