import 'package:peng_houth_cycle/features/home/data/models/station_model.dart';
import 'package:peng_houth_cycle/features/home/data/services/station_service.dart';

class StationRepository {
  StationRepository(this._service);
  final StationApiService _service;

  Future<List<StationModel>> getStations() => _service.fetchStations();

  Future<StationModel> getStationDetail(int id) =>
      _service.fetchStationDetail(id);
}
