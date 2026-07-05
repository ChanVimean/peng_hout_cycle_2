import 'package:peng_houth_cycle/core/network/api_client.dart';
import 'package:peng_houth_cycle/core/network/api_endpoints.dart';
import 'package:peng_houth_cycle/features/home/data/models/station_model.dart';

class StationApiService {
  StationApiService(this._client);
  final ApiClient _client;

  Future<List<StationModel>> fetchStations() async {
    final response = await _client.get(ApiEndpoints.stations);
    final data = (response as Map<String, dynamic>)['data'] as List;
    return data
        .map((e) => StationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<StationModel> fetchStationDetail(int id) async {
    final response = await _client.get(ApiEndpoints.stationDetail(id));
    final data =
        (response as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return StationModel.fromJson(data);
  }
}
