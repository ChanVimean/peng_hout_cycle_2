import 'package:flutter/material.dart';
import 'package:peng_houth_cycle/core/enum/app_state.dart';
import 'package:peng_houth_cycle/core/widgets/app_button.dart';
import 'package:peng_houth_cycle/core/widgets/app_textfield.dart';
import 'package:peng_houth_cycle/features/auth/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ok = await context.read<AuthProvider>().register(
      firstname: _firstnameController.text.trim(),
      lastname: _lastnameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmController.text,
    );
    // pop back past LoginScreen too — user is now logged in
    if (ok && mounted) {
      Navigator.of(context)
        ..pop()
        ..pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();
    final isLoading = provider.state == AppState.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _firstnameController,
                  label: 'First name',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  controller: _lastnameController,
                  label: 'Last name',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _emailController,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _phoneController,
            label: 'Phone',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _passwordController,
            label: 'Password',
            isPassword: true,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _confirmController,
            label: 'Confirm password',
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
            'Create account',
            isLoading: isLoading,
            onTap: isLoading ? null : _submit,
          ),
        ],
      ),
    );
  }
}
