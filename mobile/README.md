# Field Notes

Field Notes is an offline-first field inspection app. Customers, sites, notes,
photos, GPS data, and deletions are saved to the device before any network
request is attempted.

## Offline and online behavior

- Create, edit, and delete records while offline; changes remain in local Hive
  storage and are shown immediately.
- When connectivity returns, the app automatically pushes pending local
  changes and pulls server changes.
- Opening the dashboard and using **Sync Now** also starts synchronization.
- Multiple sync triggers are coalesced into one operation.
- Conflicting records use the newest `updatedAt` timestamp. A newer local
  unsynced edit is retained until it is pushed successfully.
- If the backend is unavailable, local work is retained and the next
  connectivity event retries synchronization.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
