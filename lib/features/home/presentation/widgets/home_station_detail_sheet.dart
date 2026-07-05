import 'package:flutter/material.dart';
import 'package:peng_houth_cycle/core/enum/app_state.dart';
import 'package:peng_houth_cycle/features/home/presentation/providers/home_provider.dart';
import 'package:provider/provider.dart';

class StationDetailSheet extends StatelessWidget {
  const StationDetailSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final station = provider.selectedStation;

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
                Expanded(
                  child: ListView.builder(
                    itemCount: station.bikes.length,
                    itemBuilder: (context, i) {
                      final bike = station.bikes[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: bike.isAvailable
                              ? Colors.green.shade100
                              : Colors.grey.shade200,
                          child: Icon(
                            bike.isElectric
                                ? Icons.electric_bike
                                : Icons.pedal_bike,
                            color: bike.isAvailable
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ),
                        title: Text(bike.name),
                        subtitle: Text(
                          '${bike.priceLabel}'
                          '${bike.isElectric ? ' · 🔋${bike.batteryLevel}%' : ''}',
                        ),
                        trailing: Text(
                          bike.status,
                          style: TextStyle(
                            color: bike.isAvailable
                                ? Colors.green
                                : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
