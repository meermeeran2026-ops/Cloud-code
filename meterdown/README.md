# MeterDown

Auto and car ride-booking app (Flutter). This is the UI skeleton: every screen
and the full booking flow work with sample data. There is no server, real map,
login or payment yet.

- Rider: language, onboarding, login, home, search, vehicle choice (Auto, Car,
  Sedan), finding a driver, driver arriving, on trip, fare and rating, rides,
  profile.
- Driver (dark theme): online/offline, ride request, pickup, OTP, trip, cash
  collection, earnings, documents, profile.
- 13 languages in `lib/l10n/`: English, Hindi, Bengali, Marathi, Telugu, Tamil,
  Gujarati, Urdu, Kannada, Odia, Malayalam, Punjabi, Assamese.

## Run

```
flutter pub get
flutter run
```

`flutter test` checks that every language has every string. Each push builds an
APK through `.github/workflows/meterdown-apk.yml` and attaches it to a
pre-release on GitHub.

`tool/preview.dart` opens any single screen on the web for design checks:
`flutter run -d chrome -t tool/preview.dart`, then add `?s=fare&l=hi` to the URL.
