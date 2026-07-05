import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:peng_houth_cycle/features/home/data/models/station_model.dart';
import 'package:peng_houth_cycle/features/home/presentation/providers/home_provider.dart';
import 'package:peng_houth_cycle/features/home/presentation/widgets/home_station_detail_sheet.dart';
import 'package:provider/provider.dart';

void homeOpenStationHelper(
  BuildContext context, {
  required StationModel stationModel,
}) {
  final provider = context.read<HomeProvider>();
  provider.mapController?.animateCamera(
    CameraUpdate.newLatLngZoom(
      LatLng(stationModel.latitude, stationModel.longitude),
      16,
    ),
  );
  provider.loadStationDetail(stationModel.id);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const StationDetailSheet(),
  );
}
