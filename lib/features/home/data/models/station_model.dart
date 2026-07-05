import 'package:peng_houth_cycle/features/home/data/models/bike_model.dart';

class StationModel {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int capacity;
  final int bikesCount;
  final String status;
  final int remainingCapacity;
  final int overCapacityCount;
  final List<BikeModel> bikes;

  const StationModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.capacity,
    required this.bikesCount,
    required this.status,
    required this.remainingCapacity,
    required this.overCapacityCount,
    this.bikes = const [],
  });

  factory StationModel.fromJson(Map<String, dynamic> json) {
    return StationModel(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      capacity: json['capacity'] as int? ?? 0,
      bikesCount: json['bikes_count'] as int? ?? 0,
      status: json['status'] as String? ?? 'normal',
      remainingCapacity: json['remaining_capacity'] as int? ?? 0,
      overCapacityCount: json['over_capacity_count'] as int? ?? 0,
      bikes:
          (json['bikes'] as List?)
              ?.map((e) => BikeModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
