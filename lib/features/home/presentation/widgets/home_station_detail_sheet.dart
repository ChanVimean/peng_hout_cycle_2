import 'package:flutter/material.dart';
import 'package:peng_houth_cycle/core/const/constant.dart';
import 'package:peng_houth_cycle/core/enum/app_state.dart';
import 'package:peng_houth_cycle/features/home/presentation/providers/home_provider.dart';
import 'package:peng_houth_cycle/features/home/presentation/widgets/home_rental_action_bar.dart';
import 'package:peng_houth_cycle/features/rental/presentation/providers/rental_provider.dart';
import 'package:provider/provider.dart';

class StationDetailSheet extends StatelessWidget {
  const StationDetailSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final station = provider.selectedStation;
    final rental = context.watch<RentalProvider>();

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.55,
      child: provider.detailState == AppState.loading || station == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                  child: Text(
                    station.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '${station.bikesCount}/${station.capacity} bikes · ${station.address}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const Divider(height: 24),

                // ── Bike list (scrolls) ──
                Expanded(
                  child: ListView.builder(
                    itemCount: station.bikes.length,
                    itemBuilder: (context, i) {
                      final bike = station.bikes[i];
                      final isSelected = rental.selectedBikeId == bike.id;

                      return ListTile(
                        selected: isSelected,
                        selectedTileColor: AppColors.selectionColor,
                        enabled: bike.isAvailable, // can't pick unavailable
                        onTap: bike.isAvailable
                            ? () => context.read<RentalProvider>().selectBike(
                                bike.id,
                              )
                            : null,
                        leading: CircleAvatar(
                          backgroundColor: bike.isAvailable
                              ? AppColors.successBgColor
                              : Colors.grey.shade200,
                          child: Icon(
                            bike.isElectric
                                ? Icons.electric_bike
                                : Icons.pedal_bike,
                            color: bike.isAvailable
                                ? AppColors.successColor
                                : Colors.grey,
                          ),
                        ),
                        title: Text(bike.name),
                        subtitle: Text(
                          '${bike.priceLabel}'
                          '${bike.isElectric ? ' · 🔋${bike.batteryLevel}%' : ''}',
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle,
                                color: AppColors.primaryColor,
                              )
                            : Text(
                                bike.status,
                                style: TextStyle(
                                  color: bike.isAvailable
                                      ? AppColors.successColor
                                      : Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      );
                    },
                  ),
                ),

                // ── Pinned action bar (rent / return) ──
                HomeRentalActionBar(station: station),
              ],
            ),
    );
  }
}
