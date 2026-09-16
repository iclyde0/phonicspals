# PhonicsPals

Building Strong Readers, One Game at a Time.

Offline-first Android app for Kindergarten and Grade School. Children learn synthetic phonics through short games, with Palsy the bunny mascot, local audio, and Hive progress storage. There is no server and no tracking.

## Stack

- Flutter (Android, min SDK 24, target SDK 34)
- Flame for Letter Catch and Word Builder drag-and-drop
- flutter_bloc + Hive for offline progress
- Bundled Fredoka/Nunito fonts and phonics audio

## Run

```bash
flutter pub get
flutter run
```

Portrait Android phones and tablets are the target. Play a session from the world map; grown-ups open the lock icon, hold for 3 seconds or solve 4 + 3, then use the parent portal.
