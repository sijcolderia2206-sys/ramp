# ramp

RAMP is a landlord-only property management application. Tenants are managed
profiles and do not receive application accounts.

## Landlord access

Firestore access requires both Firebase Authentication and a trusted
`landlords/{firebaseUid}` allow-list document. Create that document from the
Firebase console or another trusted admin environment before deploying
`firestore.rules`; the mobile client is intentionally unable to grant itself
landlord access.

Failed Firestore writes remain visible in the app's sync banner and can be
retried. PDF and CSV exports are written to the app documents directory under
`RAMP Exports` on supported mobile and desktop platforms.

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
