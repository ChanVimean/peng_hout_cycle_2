# 🚲 Peng Houth Cycle — API

## BASE API = [https://peng-houth-cycle-api.onrender.com/api](https://peng-houth-cycle-api.onrender.com/api)

All routes are relative to the base URL and speak JSON (`Accept: application/json`).

> [!TIP]
> The API is hosted on **Render (free tier)** — the first request after a period of inactivity cold-starts the server and can be slow. The app's `ApiClient` absorbs this with a **60s timeout + one automatic retry** (`lib/core/network/api_client.dart`).
>
> For local development switch `baseUrl` to `http://127.0.0.1:8000/api` in `lib/core/network/api_endpoints.dart`.

**Route Access Levels**

- 🟢 **Public Route** — no authentication required
- 🔑 **Auth Route** — register / login, returns a `Bearer` token
- 🚴 **Customer Route** — requires header `Authorization: Bearer <token>`

**Quick Navigation**

| Endpoint                        | Method | Access   |
| ------------------------------- | :----: | -------- |
| [All Stations](#all-stations)   | `GET`  | Public   |
| [One Station](#one-station)     | `GET`  | Public   |
| [All Bikes](#all-bikes)         | `GET`  | Public   |
| [One Bike](#one-bike)           | `GET`  | Public   |
| [Register](#register)           | `POST` | Auth     |
| [Login](#login)                 | `POST` | Auth     |
| [Start Rental](#start-rental)   | `POST` | Customer |
| [Return Rental](#return-rental) | `POST` | Customer |

**Reference**

- [Station Object](#station-object)
- [Bike Object](#bike-object)
- [Enum - App State](#enum---app-state)

---

<a id="all-stations"></a>

> [!NOTE]
>
> ## Public Route
>
> ### Method: GET
>
> [**All Stations:** https://peng-houth-cycle-api.onrender.com/api/stations](https://peng-houth-cycle-api.onrender.com/api/stations)

> **Description**: Returns every station with live capacity numbers. Powers the map markers, station list sheet, and search on the Home screen.

```json
{
  "data": [
    {
      "id": 1,
      "name": "Borey Main Gate",
      "address": "Borey Peng Huoth Main Gate",
      "latitude": 11.5329,
      "longitude": 104.9567,
      "capacity": 5,
      "bikes_count": 3,
      "status": "normal",
      "remaining_capacity": 2,
      "over_capacity_count": 0
    },
    ....
  ]
}
```

---

<a id="one-station"></a>

> [!NOTE]
>
> ## Public Route
>
> ### Method: GET
>
> [**One Station:** https://peng-houth-cycle-api.onrender.com/api/stations/1](https://peng-houth-cycle-api.onrender.com/api/stations/1)

> **Description**: Same shape as a [Station Object](#station-object), plus a `bikes` array listing every bike docked at that station. Powers the station detail bottom sheet. Returns **404** if the id does not exist.

```json
{
  "data": {
    "id": 1,
    "name": "Borey Main Gate",
    "address": "Borey Peng Huoth Main Gate",
    "latitude": 11.5329,
    "longitude": 104.9567,
    "capacity": 5,
    "bikes_count": 3,
    "status": "normal",
    "remaining_capacity": 2,
    "over_capacity_count": 0,
    "bikes": [
      {
        "id": 1,
        "station_id": 1,
        "code": "BIKE-001",
        "name": "Electric Bike 001",
        "type": "electric",
        "status": "available",
        "battery_level": 95,
        "base_price": 1,
        "base_minute": 15,
        "extra_price": 0.25,
        "extra_minute": 5,
        "description": "Electric bike for short city rides.",
        "created_at": "2026-06-05T12:21:52.000000Z",
        "updated_at": "2026-06-05T12:21:52.000000Z"
    },
      ....
    ]
  }
}
```

---

<a id="all-bikes"></a>

> [!NOTE]
>
> ## Public Route
>
> ### Method: GET
>
> [**All Bikes:** https://peng-houth-cycle-api.onrender.com/api/bikes](https://peng-houth-cycle-api.onrender.com/api/bikes)

> **Description**: Returns every bike across all stations, with type, availability, battery level, and pricing.

```json
{
  "data": [
    {
      "id": 1,
      "station_id": 1,
      "code": "BIKE-001",
      "name": "Electric Bike 001",
      "type": "electric",
      "status": "available",
      "battery_level": 95,
      "base_price": 1,
      "base_minute": 15,
      "extra_price": 0.25,
      "extra_minute": 5,
      "description": "Electric bike for short city rides."
    },
    ....
  ]
}
```

---

<a id="one-bike"></a>

> [!NOTE]
>
> ## Public Route
>
> ### Method: GET
>
> [**One Bike:** https://peng-houth-cycle-api.onrender.com/api/bikes/1](https://peng-houth-cycle-api.onrender.com/api/bikes/1)

> **Description**: A single [Bike Object](#bike-object) by id. Returns **404** if the id does not exist.

```json
{
  "data": {
    "id": 1,
    "station_id": 1,
    "code": "BIKE-001",
    "name": "Electric Bike 001",
    "type": "electric",
    "status": "available",
    "battery_level": 95,
    "base_price": 1,
    "base_minute": 15,
    "extra_price": 0.25,
    "extra_minute": 5,
    "description": "Electric bike for short city rides."
  }
}
```

---

<a id="register"></a>

> [!IMPORTANT]
>
> ## Auth Route
>
> ### Method: POST
>
> [**Register:** https://peng-houth-cycle-api.onrender.com/api/auth/register](https://peng-houth-cycle-api.onrender.com/api/auth/register)

> **Description**: Creates a new customer account. On success returns the created user together with a `Bearer` token — store it and send it as `Authorization: Bearer <token>` on customer routes. `password_confirmation` must match `password`.

**Request**

```json
{
  "firstname": "John",
  "lastname": "Doe",
  "email": "johndoe@gmail.com",
  "phone": "012462652",
  "password": "John$1234",
  "password_confirmation": "John$1234"
}
```

**Response**

```json
{
  "user": {
    "firstname": "John",
    "message": "Register successful",
    "lastname": "Doe",
    "email": "johndoe@gmail.com",
    "phone": "012462652",
    "updated_at": "2026-06-13T11:26:08.000000Z",
    "created_at": "2026-06-13T11:26:08.000000Z",
    "id": 4
  },
  "token": "27|GY3WL5X0tlwzz3N9cYc...",
  "token_type": "Bearer"
}
```

---

<a id="login"></a>

> [!IMPORTANT]
>
> ## Auth Route
>
> ### Method: POST
>
> [**Login:** https://peng-houth-cycle-api.onrender.com/api/auth/login](https://peng-houth-cycle-api.onrender.com/api/auth/login)

> **Description**: Authenticates an existing user by email + password and issues a fresh `Bearer` token. The response also includes the user's `role` (e.g. `customer`).

**Request**

```json
{
  "email": "johndoe@gmail.com",
  "password": "John$1234"
}
```

**Response**

```json
{
  "message": "Login successful",
  "user": {
    "id": 4,
    "firstname": "John",
    "lastname": "Doe",
    "email": "johndoe@gmail.com",
    "role": "customer",
    "email_verified_at": null,
    "phone": "012462652",
    "created_at": "2026-06-13T11:26:08.000000Z",
    "updated_at": "2026-06-13T11:26:08.000000Z"
  },
  "token": "29|r0M1LlvFsXz6DsIh1CiBxl...",
  "token_type": "Bearer"
}
```

---

<a id="start-rental"></a>

> [!NOTE]
>
> ## Customer Route
>
> ### Method: POST
>
> [**Start Rental:** https://peng-houth-cycle-api.onrender.com/api/rentals](https://peng-houth-cycle-api.onrender.com/api/rentals)

> **Description**: Starts a rental for the authenticated user on the given bike. The rental snapshots the bike's pricing (`base_price` / `base_minute` / `extra_price` / `extra_minute`) at start time, records the pickup station, and its `status` becomes `active`.

**Request**

```json
{
  "bike_id": 6
}
```

> [!WARNING]
>
> **Authentication**: Bearer Token
>
> `Authorization: Bearer <token>`

**Response**

```json
{
  "message": "Rental started",
  "data": {
    "user_id": 1,
    "bike_id": 6,
    "pickup_station_id": 4,
    "started_at": "2026-06-13T11:14:24.000000Z",
    "status": "active",
    "base_price": "1.00",
    "base_minute": 15,
    "extra_price": "0.25",
    "extra_minute": 5,
    "updated_at": "2026-06-13T11:14:24.000000Z",
    "created_at": "2026-06-13T11:14:24.000000Z",
    "id": 2
  }
}
```

---

<a id="return-rental"></a>

> [!NOTE]
>
> ## Customer Route
>
> ### Method: POST
>
> [**Return Rental:** https://peng-houth-cycle-api.onrender.com/api/rentals/2/return](https://peng-houth-cycle-api.onrender.com/api/rentals/2/return)

> **Description**: Completes rental `{id}` at the given return station. The server computes `duration_minute` and `total_price` from the snapshotted pricing, sets `status` to `completed`, and re-docks the bike at the return station (note the returned `bike.station_id`).

**Request**

```json
{
  "return_station_id": 2
}
```

> [!WARNING]
>
> **Authentication**: Bearer Token
>
> `Authorization: Bearer <token>`

**Response**

```json
{
  "message": "Rental completed",
  "data": {
    "id": 2,
    "user_id": 1,
    "bike_id": 6,
    "pickup_station_id": 4,
    "return_station_id": 2,
    "started_at": "2026-06-13T11:14:24.000000Z",
    "ended_at": "2026-06-13T11:15:31.000000Z",
    "status": "completed",
    "base_price": "1.00",
    "base_minute": 15,
    "extra_price": "0.25",
    "extra_minute": 5,
    "duration_minute": 2,
    "total_price": "1.00",
    "created_at": "2026-06-13T11:14:24.000000Z",
    "updated_at": "2026-06-13T11:15:31.000000Z",
    "bike": {
      "id": 6,
      "station_id": 2,
      "code": "BIKE-006",
      "name": "Electric Bike 006",
      "type": "electric",
      "status": "available",
      "battery_level": 92,
      "base_price": 1,
      "base_minute": 15,
      "extra_price": 0.25,
      "extra_minute": 5,
      "description": "Electric bike for short city rides.",
      "created_at": "2026-06-05T12:21:54.000000Z",
      "updated_at": "2026-06-13T11:15:32.000000Z"
    }
  }
}
```

---

## Station Object

| Field                 | Type     | Description                                                                       |
| --------------------- | -------- | --------------------------------------------------------------------------------- |
| `id`                  | `int`    | Unique station id                                                                 |
| `name`                | `string` | Display name                                                                      |
| `address`             | `string` | Human-readable address                                                            |
| `latitude`            | `double` | Map coordinate                                                                    |
| `longitude`           | `double` | Map coordinate                                                                    |
| `capacity`            | `int`    | Total docking slots                                                               |
| `bikes_count`         | `int`    | Bikes currently docked                                                            |
| `status`              | `string` | `normal` when within capacity — the app renders `normal` green, anything else red |
| `remaining_capacity`  | `int`    | Free slots left                                                                   |
| `over_capacity_count` | `int`    | Bikes docked beyond capacity                                                      |
| `bikes`               | `Bike[]` | Only present on [One Station](#one-station)                                       |

## Bike Object

| Field           | Type     | Description                                                        |
| --------------- | -------- | ------------------------------------------------------------------ |
| `id`            | `int`    | Unique bike id                                                     |
| `station_id`    | `int`    | Station the bike is docked at                                      |
| `code`          | `string` | Short bike code (e.g. `BIKE-001`)                                  |
| `name`          | `string` | Display name                                                       |
| `type`          | `string` | `standard` \| `electric`                                           |
| `status`        | `string` | `available` — any other value is treated as unavailable in the app |
| `battery_level` | `int`    | `0–100`, meaningful for `electric` bikes                           |
| `base_price`    | `double` | Price (USD) for the first `base_minute` minutes                    |
| `base_minute`   | `int`    | Minutes covered by `base_price`                                    |
| `extra_price`   | `double` | Price (USD) per extra `extra_minute` block                         |
| `extra_minute`  | `int`    | Block size (minutes) for `extra_price`                             |
| `description`   | `string` | Free-text notes                                                    |

> Pricing renders in-app as **`$1 first 15 min, then $0.25 / 5 min`** — built from the four pricing fields above. Some responses also include `created_at` / `updated_at` timestamps.

---

## Enum - App State

UI state machine used by providers to drive loading / error views (`lib/core/enum/app_state.dart`):

```dart
enum AppState { idle, loading, success, error }
```

| Value     | Meaning                              |
| --------- | ------------------------------------ |
| `idle`    | Nothing requested yet                |
| `loading` | Request in flight — show spinner     |
| `success` | Data ready — render content          |
| `error`   | Request failed — show retry/error UI |

---
