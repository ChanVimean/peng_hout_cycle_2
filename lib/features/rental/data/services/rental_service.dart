import 'package:peng_houth_cycle/core/network/api_client.dart';
import 'package:peng_houth_cycle/core/network/api_endpoints.dart';
import 'package:peng_houth_cycle/features/rental/data/models/rental_model.dart';

class RentalApiService {
  RentalApiService(this._client);
  final ApiClient _client;

  Future<RentalModel> start({required int bikeId}) async {
    final response = await _client.post(
      ApiEndpoints.rentals,
      body: {'bike_id': bikeId},
    );
    final data =
        (response as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return RentalModel.fromJson(data);
  }

  Future<RentalModel> returnBike({
    required int rentalId,
    required int returnStationId,
  }) async {
    final response = await _client.post(
      ApiEndpoints.returnRental(rentalId),
      body: {'return_station_id': returnStationId},
    );
    final data =
        (response as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return RentalModel.fromJson(data);
  }
}
