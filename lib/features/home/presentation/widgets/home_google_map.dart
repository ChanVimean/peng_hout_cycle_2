import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:peng_houth_cycle/features/home/presentation/providers/home_provider.dart';
import 'package:provider/provider.dart';

class HomeGoogleMap extends StatelessWidget {
  const HomeGoogleMap({super.key});

  static const _initialCamera = CameraPosition(
    target: LatLng(11.5564, 104.9282),
    zoom: 13,
  );

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    return GoogleMap(
      initialCameraPosition: _initialCamera,
      onMapCreated: provider.onMapCreated,
      markers: provider.buildMarkers(context, stations: provider.stations),
      myLocationEnabled: true,
      myLocationButtonEnabled: false, // we make our own, Google-style
      zoomControlsEnabled: false,
      compassEnabled: true,
    );
  }
}
