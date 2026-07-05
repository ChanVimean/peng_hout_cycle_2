import 'package:flutter/material.dart';
import 'package:peng_houth_cycle/core/const/constant.dart';
import 'package:peng_houth_cycle/core/widgets/app_button.dart';
import 'package:peng_houth_cycle/core/widgets/app_card.dart';
import 'package:peng_houth_cycle/core/widgets/app_section.dart';
import 'package:peng_houth_cycle/core/widgets/app_text.dart';
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
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          AppSection(
            header: 'Header',
            children: [
              if (auth.isLoggedIn && user != null)
                AppCard(
                  child: Row(
                    spacing: 8,
                    children: [
                      CircleAvatar(
                        child: Text(
                          user.firstname.isNotEmpty
                              ? user.firstname[0].toUpperCase()
                              : '?',
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            user.fullName,
                            variant: TextVariant.body,
                            fontWeight: AppFontWeights.fontWeightSemiBold,
                          ),
                          AppText(user.email, variant: TextVariant.body),
                        ],
                      ),
                    ],
                  ),
                )
              else
                AppButton(
                  'Login',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          AppSection(
            children: [
              AppButton(
                'Logout',
                onTap: () => auth.logout(),
                variant: ButtonVariant.outline,
                color: AppColors.errorColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
