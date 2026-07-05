import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:peng_houth_cycle/core/enum/app_state.dart';
import 'package:peng_houth_cycle/features/home/data/models/station_model.dart';
import 'package:peng_houth_cycle/features/home/data/repositories/station_repository.dart';
import 'package:peng_houth_cycle/features/home/presentation/helpers/home_open_station_helper.dart';

class HomeProvider extends ChangeNotifier {
  HomeProvider(this._repository);

  final StationRepository _repository;

  GoogleMapController? mapController;
  bool _hasFitted = false;

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    fitToStations();
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  AppState _state = AppState.idle;
  AppState get state => _state;

  List<StationModel> _stations = [];
  List<StationModel> get stations => _stations;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<void> loaded() async {
    loadStations();
  }

  void loadStations() async {
    _state = AppState.loading;
    notifyListeners();
    try {
      _stations = await _repository.getStations();
      _state = AppState.success;
      fitToStations();
    } catch (e) {
      _errorMessage = e.toString();
      _state = AppState.error;
    }
    notifyListeners();
  }

  StationModel? _selectedStation;
  StationModel? get selectedStation => _selectedStation;

  AppState _detailState = AppState.idle;
  AppState get detailState => _detailState;

  Future<void> loadStationDetail(int id) async {
    _detailState = AppState.loading;
    notifyListeners();
    try {
      _selectedStation = await _repository.getStationDetail(id);
      _detailState = AppState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _detailState = AppState.error;
    }
    notifyListeners();
  }

  void fitToStations() {
    final controller = mapController;
    if (controller == null || _stations.isEmpty || _hasFitted) return;
    _hasFitted = true;

    if (_stations.length == 1) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_stations.first.latitude, _stations.first.longitude),
          15,
        ),
      );
      return;
    }

    final lats = _stations.map((s) => s.latitude);
    final lngs = _stations.map((s) => s.longitude);
    final bounds = LatLngBounds(
      southwest: LatLng(
        lats.reduce((a, b) => a < b ? a : b),
        lngs.reduce((a, b) => a < b ? a : b),
      ),
      northeast: LatLng(
        lats.reduce((a, b) => a > b ? a : b),
        lngs.reduce((a, b) => a > b ? a : b),
      ),
    );
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
  }

  Set<Marker> buildMarkers(
    BuildContext context, {
    required List<StationModel> stations,
  }) {
    return stations.map((stationModel) {
      return Marker(
        onTap: () => homeOpenStationHelper(context, stationModel: stationModel),
        markerId: MarkerId(stationModel.id.toString()),
        position: LatLng(stationModel.latitude, stationModel.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          stationModel.status == 'normal'
              ? BitmapDescriptor.hueGreen
              : BitmapDescriptor.hueRed,
        ),
        infoWindow: InfoWindow(
          title: stationModel.name,
          snippet: '${stationModel.bikesCount}/${stationModel.capacity} bikes',
        ),
      );
    }).toSet();
  }

  Future<void> goToMyLocation() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    final pos = await Geolocator.getCurrentPosition();
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(pos.latitude, pos.longitude), 15),
    );
  }

  List<StationModel> filtered({
    required List<StationModel> stations,
    required String query,
  }) {
    if (query.isEmpty) return stations;
    final q = query.toLowerCase();
    return stations
        .where(
          (s) =>
              s.name.toLowerCase().contains(q) ||
              s.address.toLowerCase().contains(q),
        )
        .toList();
  }
}
