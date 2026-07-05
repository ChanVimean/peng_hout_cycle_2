import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:peng_houth_cycle/core/enum/app_state.dart';
import 'package:peng_houth_cycle/features/home/data/models/station_model.dart';
import 'package:peng_houth_cycle/features/home/data/repositories/station_repository.dart';
import 'package:peng_houth_cycle/features/home/presentation/helpers/home_open_station_helper.dart';
import 'package:peng_houth_cycle/features/home/presentation/helpers/station_marker_icon.dart';

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

  /// Cached labeled marker icons, keyed by "id-status" so an icon is only
  /// rebuilt when its station's name or color could have changed.
  final Map<String, BitmapDescriptor> _markerIcons = {};

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
      await _buildMarkerIcons();
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

  String _iconKey(StationModel s) => '${s.id}-${s.status}';

  Color _statusColor(StationModel s) =>
      s.status == 'normal' ? const Color(0xFF2E7D32) : const Color(0xFFC62828);

  /// Rasterizes a labeled marker icon for every station, caching by [_iconKey].
  /// Only stations without a cached icon are (re)built, then listeners are
  /// notified so the map rebuilds its markers with the finished bitmaps.
  Future<void> _buildMarkerIcons() async {
    var built = false;
    for (final station in _stations) {
      final key = _iconKey(station);
      if (_markerIcons.containsKey(key)) continue;
      _markerIcons[key] = await createStationMarkerBitmap(
        label: station.name,
        color: _statusColor(station),
      );
      built = true;
    }
    if (built) notifyListeners();
  }

  Set<Marker> buildMarkers(
    BuildContext context, {
    required List<StationModel> stations,
  }) {
    return stations.map((stationModel) {
      final icon = _markerIcons[_iconKey(stationModel)];
      return Marker(
        onTap: () => homeOpenStationHelper(context, stationModel: stationModel),
        markerId: MarkerId(stationModel.id.toString()),
        position: LatLng(stationModel.latitude, stationModel.longitude),
        // Fall back to a plain colored pin until the labeled bitmap is ready.
        icon:
            icon ??
            BitmapDescriptor.defaultMarkerWithHue(
              stationModel.status == 'normal'
                  ? BitmapDescriptor.hueGreen
                  : BitmapDescriptor.hueRed,
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
