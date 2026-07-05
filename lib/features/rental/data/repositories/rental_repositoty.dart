import 'package:peng_houth_cycle/core/storage/local_storage.dart';
import 'package:peng_houth_cycle/features/rental/data/models/rental_model.dart';
import 'package:peng_houth_cycle/features/rental/data/services/rental_service.dart';

class RentalRepository {
  RentalRepository(this._service, this._storage);

  final RentalApiService _service;
  final LocalStorage _storage;

  Future<RentalModel> start({required int bikeId}) async {
    final rental = await _service.start(bikeId: bikeId);
    await _storage.saveActiveRentalId(rental.id);
    return rental;
  }

  Future<RentalModel> returnBike({
    required int rentalId,
    required int returnStationId,
  }) async {
    final rental = await _service.returnBike(
      rentalId: rentalId,
      returnStationId: returnStationId,
    );
    await _storage.clearActiveRentalId();
    return rental;
  }

  Future<int?> restoreActiveRentalId() => _storage.readActiveRentalId();
}
