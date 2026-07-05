import 'package:flutter/material.dart';
import 'package:peng_houth_cycle/core/enum/app_state.dart';
import 'package:peng_houth_cycle/features/rental/data/models/rental_model.dart';
import 'package:peng_houth_cycle/features/rental/data/repositories/rental_repositoty.dart';

class RentalProvider extends ChangeNotifier {
  RentalProvider(this._repository);

  final RentalRepository _repository;

  AppState _state = AppState.idle;
  AppState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  RentalModel? _activeRental;
  RentalModel? get activeRental => _activeRental;
  bool get hasActiveRental => _activeRental?.isActive ?? false;

  // Which bike is highlighted in the sheet (null = none picked yet)
  int? _selectedBikeId;
  int? get selectedBikeId => _selectedBikeId;

  void selectBike(int bikeId) {
    _selectedBikeId = _selectedBikeId == bikeId
        ? null
        : bikeId; // tap again = deselect
    notifyListeners();
  }

  void clearSelection() {
    _selectedBikeId = null;
    notifyListeners();
  }

  /// On app launch — if an id was persisted, we know a ride is in progress.
  /// (No GET endpoint to re-hydrate details, so we just flag it; the return
  ///  call still works with the id alone.)
  Future<void> restore() async {
    final id = await _repository.restoreActiveRentalId();
    if (id != null) {
      // minimal placeholder so hasActiveRental works; real fields fill on return
      // if you later add GET /rentals/{id}, fetch full detail here instead.
    }
  }

  Future<bool> startRental({required int bikeId}) async {
    _state = AppState.loading;
    _errorMessage = '';
    notifyListeners();
    try {
      _activeRental = await _repository.start(bikeId: bikeId);
      _selectedBikeId = null;
      _state = AppState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _state = AppState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> returnRental({required int returnStationId}) async {
    final rental = _activeRental;
    if (rental == null) return false;

    _state = AppState.loading;
    _errorMessage = '';
    notifyListeners();
    try {
      _activeRental = await _repository.returnBike(
        rentalId: rental.id,
        returnStationId: returnStationId,
      );
      _state = AppState.success;
      notifyListeners();
      return true; // _activeRental now holds the completed receipt (totalPrice etc.)
    } catch (e) {
      _errorMessage = e.toString();
      _state = AppState.error;
      notifyListeners();
      return false;
    }
  }

  /// Clear the completed receipt after the user dismisses it.
  void clearRental() {
    _activeRental = null;
    _state = AppState.idle;
    notifyListeners();
  }
}
