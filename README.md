# Data Handler Project

A Flutter mobile application built as part of an internship assignment. The app fetches and displays characters from the Rick and Morty API with infinite scrolling, search, local data persistence, and settings.

## App Functionality

- **Home Screen** — displays a paginated list of Rick and Morty characters loaded from a public REST API
- **Detail Screen** — shows full character info (name, status, species, gender, origin) on tapping any card
- **Settings Screen** — toggle dark/light mode and select language
- **Search** — searches across all characters via API query, not just loaded ones
- **Infinite Scrolling** — automatically loads next page when user scrolls to 90% of the list
- **Local Storage** — character data, theme, and language saved to device and restored on app restart
- **App Lifecycle** — data is saved when app goes to background using `WidgetsBindingObserver`
- **Error Handling** — shows retry button on API failure, falls back to cached data if available
- **Image Error Handling** — shows placeholder icon if character image fails to load

## How to Run

### Prerequisites
- Flutter SDK 3.0+
- Android Studio or VS Code
- Android/iOS device or emulator

### Steps
```bash
git clone https://github.com/phoenixspecss-mait/Data-Handler-Project.git
cd Data-Handler-Project
flutter pub get
flutter run
```

## Key Technical Decisions

**Flutter over React Native**
The assignment suggested React Native but Flutter is my primary stack. The core architecture — Redux state management, API integration, pagination, lifecycle handling — is identical across both frameworks. Flutter allowed me to deliver a more polished and well-tested result.

**Redux for State Management**
Used `redux` + `flutter_redux` packages. All app state lives in a single `AppState` object. Actions describe what happened, the reducer handles state transitions, and middleware handles async API calls. This keeps business logic completely separate from UI.

**Middleware for API calls**
All HTTP requests happen in middleware, not in widgets. Widgets only dispatch actions and read state — they have no knowledge of the API.

**Local Storage with shared_preferences**
Characters are serialized to JSON and stored as a string list. Theme and language are stored as strings. On app start, all saved data is loaded before `runApp()` so the app restores its exact previous state instantly.

**Pagination strategy**
The Rick and Morty API returns 20 items per page. `ScrollController` detects when the user reaches 90% scroll depth and dispatches `FetchNextPageAction`. New items are appended to the existing list in the reducer using the spread operator `[...state.items, ...newItems]`.

**Search strategy**
Local search filters already loaded items instantly. For full search across all 826 characters, a separate API endpoint (`/api/character/?name=query`) is called, replacing the list with search results.

**Theme and Language via Redux**
Theme and language are part of `AppState` so they are available anywhere in the widget tree. `MaterialApp` listens to `themeMode` from Redux state via `StoreConnector` and rebuilds only when theme changes.

## Improvements With More Time

- Add filter by status (Alive/Dead/Unknown) and species
- Cache images locally using `cached_network_image`
- Add unit tests for reducer and middleware
- Add shimmer loading placeholders instead of a spinner
- Implement proper pagination for search results
- Add full translations for all UI text across all languages