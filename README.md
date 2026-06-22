# Weather App with Offline Cache

A Flutter weather app that lets users search current weather by city, view it
offline from the last cached result, and recover gracefully from network and
API errors. Built with **Clean Architecture**, **Cubit** for state
management, **Dio** for networking, and **Hive** for local caching.

---

## Setup Instructions

This project ships as source only (`lib/`, `test/`, `pubspec.yaml`) — platform
folders (`android/`, `ios/`, etc.) are generated on your machine so they match
your installed Flutter SDK exactly.

### 1. Get a WeatherAPI.com key

Sign up free at https://www.weatherapi.com/ and copy your API key.

### 2. Place the project files

Unzip this project into an empty folder, e.g. `weather_app/`.

### 3. Generate platform folders

From inside the project folder:

```bash
flutter create .
```

This scaffolds `android/`, `ios/`, `web/`, etc. around the existing
`lib/`, `pubspec.yaml`, and `test/` without overwriting them.

### 4. Install dependencies

```bash
flutter pub get
```

### 5. Add your API key

Open `lib/core/constants/api_constants.dart` and replace:

```dart
static const String apiKey = 'YOUR_WEATHERAPI_KEY';
```

with your actual key.

### 6. Run the app

```bash
flutter run
```

### 7. Run tests

```bash
flutter test
```

### 8. Build a release APK

```bash
flutter build apk --release
```

The APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

---

## Architecture Explanation

The app follows **Clean Architecture** with three layers, each only aware of
the layer "below" it through abstractions:

```
lib/
├── core/                     # Cross-cutting concerns
│   ├── constants/            # API config
│   ├── error/                # Failure & Exception types
│   ├── network/               # Dio client, connectivity check
│   └── theme/                 # App theming (light/dark)
│
├── domain/                   # Pure business logic — no Flutter, no Dio, no Hive
│   ├── entities/              # WeatherEntity
│   ├── repositories/          # WeatherRepository abstract contract + result types
│   └── usecases/              # GetWeatherUseCase, GetRecentSearchesUseCase
│
├── data/                      # Implementation details
│   ├── models/                 # WeatherModel (extends WeatherEntity, handles JSON)
│   ├── datasources/             # Remote (Dio/API) and Local (Hive) data sources
│   └── repositories/             # WeatherRepositoryImpl — ties everything together
│
└── presentation/              # UI + state management
    ├── cubit/                  # WeatherCubit + WeatherState
    ├── pages/                   # HomePage
    └── widgets/                  # SearchBar, WeatherDisplay, ShimmerLoading, etc.
```

### Why this structure

- **Domain layer has zero dependencies on Flutter or any package.** The
  `WeatherRepository` is an abstract class; the Cubit and use cases depend on
  that abstraction, not on Dio or Hive directly. This makes business logic
  testable in isolation and the data layer swappable (e.g. switching APIs or
  storage solutions) without touching domain or presentation code.

- **Repository Pattern** (`WeatherRepositoryImpl`) is the single point that
  decides: try the network first, fall back to cache on failure (server error
  or offline), or surface a clean error (e.g. invalid city name shouldn't
  silently show a different city's cached data).

- **Result type instead of throwing across layers** — `WeatherRepository`
  returns a sealed `WeatherResult` (`WeatherSuccess` / `WeatherError`) rather
  than throwing exceptions up to the UI. This keeps error handling explicit
  and exhaustive in the Cubit (Dart 3 pattern matching).

### Offline caching strategy

- `WeatherLocalDataSource` stores the **last successfully fetched weather**
  as a JSON string in a Hive `Box<String>`, and a separate box for the list
  of recent searches (also JSON-encoded). This avoids needing generated Hive
  `TypeAdapter`s / `build_runner`, while still getting Hive's fast, persistent
  storage.
- On every successful API call, the result is cached and added to recent
  searches.
- On failure:
  - **No internet connection** → immediately falls back to cache, with a
    clear "offline" banner explaining why.
  - **Server error (5xx, timeout)** → also falls back to cache, since the
    cached data is still useful and the error wasn't about the search term.
  - **Invalid city name (400)** or **rate limit (429)** → does **not** fall
    back to cache (since the user explicitly searched for something
    different), and instead shows a direct, meaningful error message.

### State management (Cubit)

`WeatherCubit` exposes four states: `WeatherInitial`, `WeatherLoading`,
`WeatherLoaded` (carries `isFromCache` + `cacheMessage`), and
`WeatherFailure`. A simple `_isFetching` guard prevents duplicate/overlapping
requests if the user taps search repeatedly. `refreshWeather()` re-runs the
search for the currently displayed city, powering pull-to-refresh.

### Error handling

`WeatherRemoteDataSourceImpl` maps Dio exceptions/status codes into specific,
typed exceptions (`CityNotFoundException`, `RateLimitException`,
`ServerException`), which the repository translates into `Failure`s with
user-friendly messages — never raw stack traces or status codes shown to the
user.

### Testing

- `test/data/repositories/weather_repository_impl_test.dart` — unit tests
  for the repository's online/offline/cache-fallback/error-mapping logic
  using `mocktail`.
- `test/presentation/cubit/weather_cubit_test.dart` — `bloc_test` coverage
  for search success, search failure, duplicate-request prevention, and
  empty-input handling.

### Bonus features included

- ✅ Dark mode support (`ThemeMode.system` with light/dark `ThemeData`)
- ✅ Unit tests (repository + cubit)
- ✅ Weather condition icons from the API, with a graceful fallback icon
- ✅ Clean Architecture with full separation of concerns

---

## Notes

- The chosen API is **WeatherAPI.com** (`/v1/current.json`).
- State management: **Cubit** (via `flutter_bloc`), chosen for its simplicity
  for this scope (a single feature, a handful of states) while still keeping
  business logic out of widgets.
