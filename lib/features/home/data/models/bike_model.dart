class BikeModel {
  final int id;
  final int stationId;
  final String code;
  final String name;
  final String type;
  final String status;
  final int batteryLevel;
  final double basePrice;
  final int baseMinute;
  final double extraPrice;
  final int extraMinute;
  final String description;

  const BikeModel({
    required this.id,
    required this.stationId,
    required this.code,
    required this.name,
    required this.type,
    required this.status,
    required this.batteryLevel,
    required this.basePrice,
    required this.baseMinute,
    required this.extraPrice,
    required this.extraMinute,
    required this.description,
  });

  factory BikeModel.fromJson(Map<String, dynamic> json) {
    return BikeModel(
      id: json['id'] as int,
      stationId: json['station_id'] as int,
      code: json['code'] as String,
      name: json['name'] as String,
      type: json['type'] as String? ?? 'standard',
      status: json['status'] as String? ?? 'unavailable',
      batteryLevel: json['battery_level'] as int? ?? 0,
      basePrice: (json['base_price'] as num?)?.toDouble() ?? 0,
      baseMinute: json['base_minute'] as int? ?? 0,
      extraPrice: (json['extra_price'] as num?)?.toDouble() ?? 0,
      extraMinute: json['extra_minute'] as int? ?? 0,
      description: json['description'] as String? ?? '',
    );
  }

  bool get isAvailable => status == 'available';
  bool get isElectric => type == 'electric';

  /// "$1 first 15 min, then $0.25 / 5 min"
  String get priceLabel =>
      '\$${basePrice.toStringAsFixed(basePrice.truncateToDouble() == basePrice ? 0 : 2)} first $baseMinute min, then \$${extraPrice.toStringAsFixed(2)} / $extraMinute min';
}
