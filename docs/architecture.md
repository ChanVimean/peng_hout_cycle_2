## Architecture

```bash
lib/
├── main.dart
├── bootstrap.dart                       # MultiProvider setup, Dio init, run app
│
├── app/
│   ├── app.dart                         # MaterialApp.router
│   ├── providers/                       # AppProvider (splash/onboarding state)
│   └── view/                            # splash, onboarding
│
├── core/
│   ├── network/
│   │   ├── dio_client.dart              # Dio with baseUrl, timeouts, auth header
│   │   └── api_endpoints.dart           # all endpoint strings
│   ├── errors/                          # exceptions handling
│   ├── const/                           # app properties
│   ├── enum/                            # view_state.dart (idle/loading/success/error)
│   ├── extensions/
│   ├── theme/
│   ├── storage/
│   ├── utils/
│   └── widgets/                         # custom widgets
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/                  # user_model.dart, login_request.dart
│   │   │   ├── services/                # auth_api_service.dart (raw Dio calls)
│   │   │   └── repositories/            # auth_repository.dart (service + token storage)
│   │   └── presentation/
│   │       ├── entities/                # ui entities
│   │       ├── providers/               # auth_provider.dart (ChangeNotifier)
│   │       ├── screens/
│   │       ├── helpers/                 # private support functions
│   │       └── widgets/                 # private widgets for this domain only
│   │
│   ├── product/
│   │   ├── data/
│   │   │   ├── models/                  # product_model.dart (fromJson/toJson)
│   │   │   ├── services/                # product_api_service.dart
│   │   │   └── repositories/            # product_repository.dart
│   │   └── presentation/
│   │       ├── entities/                # ui entities
│   │       ├── providers/               # product_provider.dart
│   │       ├── screens/
│   │       ├── helpers/                 # private support functions
│   │       └── widgets/                 # private widgets for this domain only
│   │
│   └── settings/
│
└── router/
    ├── router.dart
    ├── routes.dart
    └── go_router_refresh_stream.dart    # works with Provider too (see note)
```

---
