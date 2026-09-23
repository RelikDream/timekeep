# Pointage

App Android personnelle de suivi du temps de travail pour un cadre au forfait jours :
rappels calculés sur le temps réellement travaillé, prolongations limitées, rituel de coupure.

- Règles métier, stack et façon de travailler : [`CLAUDE.md`](CLAUDE.md)
- User stories : [`docs/backlog.md`](docs/backlog.md)

## Prérequis

- Flutter stable (Dart 3)
- SDK Android (minSdk 26) et un téléphone ou émulateur

## Lancer

```bash
flutter pub get
flutter run
```

## Tester

```bash
flutter analyze
flutter test
```

La CI GitHub Actions lance les mêmes commandes à chaque push sur `main` et sur chaque pull request.

## Générer le code

À relancer après toute modification des tables drift ou des providers Riverpod (à partir d'US-02) :

```bash
dart run build_runner build --delete-conflicting-outputs
```
