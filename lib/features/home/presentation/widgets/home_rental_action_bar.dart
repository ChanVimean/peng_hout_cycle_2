import 'package:flutter/material.dart';
import 'package:peng_houth_cycle/core/const/constant.dart';
import 'package:peng_houth_cycle/core/enum/app_state.dart';
import 'package:peng_houth_cycle/features/auth/presentation/providers/auth_provider.dart';
import 'package:peng_houth_cycle/features/auth/presentation/screens/login_screen.dart';
import 'package:peng_houth_cycle/features/home/data/models/station_model.dart';
import 'package:peng_houth_cycle/features/rental/presentation/providers/rental_provider.dart';
import 'package:provider/provider.dart';

class HomeRentalActionBar extends StatelessWidget {
  const HomeRentalActionBar({super.key, required this.station});
  final StationModel station;

  @override
  Widget build(BuildContext context) {
    final rental = context.watch<RentalProvider>();
    final isLoading = rental.state == AppState.loading;

    // ── State 1: riding ──
    if (rental.hasActiveRental) {
      final active = rental.activeRental!;
      return _bar(
        context,
        title: 'You\'re riding',
        subtitle:
            '~\$${active.estimatedCost(DateTime.now()).toStringAsFixed(2)} so far',
        buttonLabel: 'Return here',
        color: AppColors.errorColor,
        isLoading: isLoading,
        onPressed: () async {
          final ok = await context.read<RentalProvider>().returnRental(
            returnStationId: station.id,
          );
          if (ok && context.mounted) _showReceipt(context);
        },
      );
    }

    // ── State 2: a bike is selected ──
    final bikeId = rental.selectedBikeId;
    if (bikeId != null) {
      final bike = station.bikes.firstWhere((b) => b.id == bikeId);
      return _bar(
        context,
        title: bike.name,
        subtitle: bike.priceLabel,
        buttonLabel: 'Rent this bike',
        color: AppColors.primaryColor,
        isLoading: isLoading,
        onPressed: () => rentBikeGate(context, bikeId: bikeId),
      );
    }

    // ── State 3: nothing to do ──
    return const SizedBox.shrink();
  }

  Widget _bar(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String buttonLabel,
    required Color color,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.defaultPadding),
      decoration: const BoxDecoration(
        color: AppColors.cardBackgroundColor,
        border: Border(top: BorderSide(color: AppColors.selectionColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.textSecondaryColor),
                ),
              ],
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: color),
            onPressed: isLoading ? null : onPressed,
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(buttonLabel),
          ),
        ],
      ),
    );
  }

  void _showReceipt(BuildContext context) {
    final r = context.read<RentalProvider>().activeRental!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ride complete'),
        content: Text(
          'Duration: ${r.durationMinute} min\n'
          'Total: \$${r.totalPrice?.toStringAsFixed(2)}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<RentalProvider>().clearRental();
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // close sheet
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> rentBikeGate(BuildContext context, {required int bikeId}) async {
    final auth = context.read<AuthProvider>();

    // 1. must be logged in
    if (!auth.isLoggedIn) {
      final ok = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (ok != true || !context.mounted) return; // backed out
    }

    // 2. confirm
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Start rental?'),
        content: const Text(
          'You\'ll be charged from now until you return the bike.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Start'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    // 3. start — token already on ApiClient
    final ok = await context.read<RentalProvider>().startRental(bikeId: bikeId);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<RentalProvider>().errorMessage)),
      );
    }
    // on success the action bar auto-flips to "You're riding" (watches provider)
  }
}
