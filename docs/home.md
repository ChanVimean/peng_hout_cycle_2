### Home Screen / Map

**Quick Navigation**

- [Main Screen](#main-screen)
- [Provider](#provider)
- [Helpers](#helpers)
- [Widgets - Home Draggable Scrollable Sheet](#widgets---home-draggable-scrollable-sheet)
- [Widgets - Google Map](#widgets---google-map)
- [Widgets - Search](#widgets---search)
- [Widgets - Station Detail Sheet](#widgets---station-detail-sheet)
- [Models - Station Model](#models---station-model)
- [Models - Bike Model](#models---bike-model)
- [Services - Station](#services---station)
- [Repository - Station](#repository---station)

---

### Folder Layout

Following `Architecture.md` — folders marked _(empty)_ exist now, filled later:

```bash
features/home/
├── data/
│   ├── models/
│   │   ├── bike_model.dart
│   │   └── station_model.dart
│   ├── services/
│   │   └── station_service.dart
│   └── repositories/
│       └── station_repository.dart
└── presentation/
    ├── entities/
    ├── providers/
    │   └── home_provider.dart
    ├── screens/
    │   └── home_screen.dart
    ├── helpers/
    │   └── home_open_station_helper.dart
    └── widgets/
        ├── home_draggable_scrollable_sheet.dart
        ├── home_google_map.dart
        ├── home_search.dart
        └── home_station_detail_sheet.dart
```

---

### Main Screen

> `features/home/presentation/screens/home_screen.dart`

```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();

    return Scaffold(
      body: Stack(
        children: [
          const HomeGoogleMap(),

          // ── Search bar, like Google Maps top pill ──
          const HomeSearch(),

          // ── Floating locate-me button, bottom right ──
          Positioned(
            right: 16,
            bottom: 180,
            child: FloatingActionButton.small(
              heroTag: 'locate_me',
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              onPressed: provider.goToMyLocation,
              child: const Icon(Icons.my_location),
            ),
          ),

          // ── Draggable bottom sheet with station list ──
          const HomeDraggableScrollableSheet(),

          if (provider.state == AppState.loading)
            const Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 120),
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
```

---

### Provider

> `features/home/presentation/providers/home_provider.dart`

```dart
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
```

---

### Helpers

> `features/home/presentation/helpers/home_open_station_helper.dart`

```dart
void homeOpenStationHelper(
  BuildContext context, {
  required StationModel stationModel,
}) {
  final provider = context.read<HomeProvider>();
  provider.mapController?.animateCamera(
    CameraUpdate.newLatLngZoom(
      LatLng(stationModel.latitude, stationModel.longitude),
      16,
    ),
  );
  provider.loadStationDetail(stationModel.id);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const StationDetailSheet(),
  );
}

```

---

### Widgets - Home Draggable Scrollable Sheet

> `features/home/presentation/widgets/home_draggable_scrollable_sheet.dart`

```dart
class HomeDraggableScrollableSheet extends StatelessWidget {
  const HomeDraggableScrollableSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();

    return DraggableScrollableSheet(
      initialChildSize: 0.18,
      minChildSize: 0.1,
      maxChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              // drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${provider.stations.length} stations nearby',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              ...provider.stations.map(
                (s) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: s.status == 'normal'
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    child: Icon(
                      Icons.pedal_bike,
                      color: s.status == 'normal' ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(s.name),
                  subtitle: Text(
                    '${s.bikesCount}/${s.capacity} bikes · ${s.address}',
                  ),
                  onTap: () {
                    provider.mapController?.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        LatLng(s.latitude, s.longitude),
                        16,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

---

### Widgets - Google Map

> `features/home/presentation/widgets/home_google_map.dart`

```dart
class HomeGoogleMap extends StatelessWidget {
  const HomeGoogleMap({super.key});

  static const _initialCamera = CameraPosition(
    target: LatLng(11.5564, 104.9282),
    zoom: 13,
  );

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    return GoogleMap(
      initialCameraPosition: _initialCamera,
      onMapCreated: provider.onMapCreated,
      markers: provider.buildMarkers(context, stations: provider.stations),
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: true,
    );
  }
}
```

---

### Widgets - Search

> `features/home/presentation/widgets/home_search.dart`

```dart
class HomeSearch extends StatefulWidget {
  const HomeSearch({super.key});

  @override
  State<HomeSearch> createState() => _HomeSearchState();
}

class _HomeSearchState extends State<HomeSearch> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final stations = provider.filtered(
      stations: provider.stations,
      query: _query,
    );

    return SafeArea(
      child: AppSearchSuggestionBar<StationModel>(
        controller: _searchController,
        hint: 'Search stations',
        query: _query,
        suggestions: stations, // already filtered by _filtered()
        itemBuilder: (context, s) => ListTile(
          dense: true,
          leading: Icon(
            Icons.pedal_bike,
            color: s.status == 'normal' ? Colors.green : Colors.red,
          ),
          title: Text(s.name),
          subtitle: Text(
            s.address,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text('${s.bikesCount}/${s.capacity}'),
        ),
        onChanged: (value) => setState(() => _query = value),
        onSelected: (stationModel) {
          FocusScope.of(context).unfocus(); // close keyboard
          _searchController.clear();
          setState(() => _query = '');
          homeOpenStationHelper(context, stationModel: stationModel);
        },
        onClear: () {
          _searchController.clear();
          setState(() => _query = '');
        },
      ),
    );
  }
}
```

---

### Widgets - Station Detail Sheet

> `features/home/presentation/widgets/home_station_detail_sheet.dart`

```dart
class StationDetailSheet extends StatelessWidget {
  const StationDetailSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final station = provider.selectedStation;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.55,
      child: provider.detailState == AppState.loading || station == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                  child: Text(
                    station.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '${station.bikesCount}/${station.capacity} bikes · ${station.address}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const Divider(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: station.bikes.length,
                    itemBuilder: (context, i) {
                      final bike = station.bikes[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: bike.isAvailable
                              ? Colors.green.shade100
                              : Colors.grey.shade200,
                          child: Icon(
                            bike.isElectric
                                ? Icons.electric_bike
                                : Icons.pedal_bike,
                            color: bike.isAvailable
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ),
                        title: Text(bike.name),
                        subtitle: Text(
                          '${bike.priceLabel}'
                          '${bike.isElectric ? ' · 🔋${bike.batteryLevel}%' : ''}',
                        ),
                        trailing: Text(
                          bike.status,
                          style: TextStyle(
                            color: bike.isAvailable
                                ? Colors.green
                                : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
```

---

### Models - Station Model

> `features/home/data/models/station_model.dart`

```dart
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
```

---

### Models - Bike Model

> `features/home/data/models/bike_model.dart`

```dart
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

```

---

### Services - Station

> `features/home/data/services/station_service.dart`

```dart
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
```

---

### Repository - Station

> `features/home/data/repository/station_repository.dart`

```dart
class StationRepository {
  StationRepository(this._service);
  final StationApiService _service;

  Future<List<StationModel>> getStations() => _service.fetchStations();

  Future<StationModel> getStationDetail(int id) =>
      _service.fetchStationDetail(id);
}
```

---
