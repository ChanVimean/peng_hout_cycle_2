class RentalModel {
  final int id;
  final int userId;
  final int bikeId;
  final int pickupStationId;
  final int? returnStationId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String status; // 'active' | 'completed'

  // Snapshotted pricing (taken at start time)
  final double basePrice;
  final int baseMinute;
  final double extraPrice;
  final int extraMinute;

  // Return-only
  final int? durationMinute;
  final double? totalPrice;

  const RentalModel({
    required this.id,
    required this.userId,
    required this.bikeId,
    required this.pickupStationId,
    required this.startedAt,
    required this.status,
    required this.basePrice,
    required this.baseMinute,
    required this.extraPrice,
    required this.extraMinute,
    this.returnStationId,
    this.endedAt,
    this.durationMinute,
    this.totalPrice,
  });

  bool get isActive => status == 'active';

  factory RentalModel.fromJson(Map<String, dynamic> json) {
    return RentalModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      bikeId: json['bike_id'] as int,
      pickupStationId: json['pickup_station_id'] as int,
      returnStationId: json['return_station_id'] as int?,
      startedAt: DateTime.parse(json['started_at'] as String),
      endedAt: json['ended_at'] == null
          ? null
          : DateTime.parse(json['ended_at'] as String),
      status: json['status'] as String? ?? 'active',
      // API sends these as strings ("1.00") on rentals — parse safely
      basePrice: _toDouble(json['base_price']),
      baseMinute: json['base_minute'] as int? ?? 0,
      extraPrice: _toDouble(json['extra_price']),
      extraMinute: json['extra_minute'] as int? ?? 0,
      durationMinute: json['duration_minute'] as int?,
      totalPrice: json['total_price'] == null
          ? null
          : _toDouble(json['total_price']),
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  /// Live running cost from snapshotted pricing — for the "you're riding" UI.
  /// Mirrors the server's billing: base covers the first block, then each
  /// extra block (rounded up) costs extraPrice.
  double estimatedCost(DateTime now) {
    final mins = now.difference(startedAt).inMinutes;
    if (mins <= baseMinute) return basePrice;
    final over = mins - baseMinute;
    final blocks = (over / extraMinute).ceil();
    return basePrice + blocks * extraPrice;
  }
}
