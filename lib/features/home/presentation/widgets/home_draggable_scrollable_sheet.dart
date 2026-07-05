import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:peng_houth_cycle/features/home/presentation/providers/home_provider.dart';
import 'package:provider/provider.dart';

class HomeDraggableScrollableSheet extends StatelessWidget {
  const HomeDraggableScrollableSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();

    return DraggableScrollableSheet(
      initialChildSize: 0.18,
      minChildSize: 0.1,
      maxChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              // drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${provider.stations.length} stations nearby',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              ...provider.stations.map(
                (s) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: s.status == 'normal'
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    child: Icon(
                      Icons.pedal_bike,
                      color: s.status == 'normal' ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(s.name),
                  subtitle: Text(
                    '${s.bikesCount}/${s.capacity} bikes · ${s.address}',
                  ),
                  onTap: () {
                    provider.mapController?.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        LatLng(s.latitude, s.longitude),
                        16,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
