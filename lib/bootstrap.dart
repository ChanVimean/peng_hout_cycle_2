import 'package:flutter/material.dart';
import 'package:peng_houth_cycle/app/app.dart';
import 'package:peng_houth_cycle/app/providers/app_provider.dart';
import 'package:peng_houth_cycle/core/network/api_client.dart';
import 'package:peng_houth_cycle/core/storage/local_storage.dart';
import 'package:peng_houth_cycle/features/auth/data/repositories/auth_repository.dart';
import 'package:peng_houth_cycle/features/auth/data/services/auth_api_service.dart';
import 'package:peng_houth_cycle/features/auth/presentation/providers/auth_provider.dart';
import 'package:peng_houth_cycle/features/home/data/repositories/station_repository.dart';
import 'package:peng_houth_cycle/features/home/data/services/station_service.dart';
import 'package:peng_houth_cycle/features/home/presentation/providers/home_provider.dart';
import 'package:peng_houth_cycle/features/rental/data/repositories/rental_repositoty.dart';
import 'package:peng_houth_cycle/features/rental/data/services/rental_service.dart';
import 'package:peng_houth_cycle/features/rental/presentation/providers/rental_provider.dart';
import 'package:provider/provider.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiClient = ApiClient();
  final storage = LocalStorage();

  final authRepository = AuthRepository(
    AuthApiService(apiClient),
    apiClient,
    LocalStorage(),
  );
  final rentalRepository = RentalRepository(
    RentalApiService(apiClient),
    storage,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository)..restoreSession(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              HomeProvider(StationRepository(StationApiService(apiClient)))
                ..loaded(),
        ),
        ChangeNotifierProvider(
          create: (_) => RentalProvider(rentalRepository)..restore(),
        ),
      ],
      child: const App(),
    ),
  );
}
