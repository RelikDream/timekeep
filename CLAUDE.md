# CLAUDE.md — Pointage (app Android de suivi du temps de travail)

## Contexte

App Android personnelle pour un cadre au **forfait jours** (convention Syntec) qui veut éviter la surcharge.
Ce n'est pas un outil de pointage employeur : c'est un garde-fou personnel.

Elle doit résoudre trois problèmes concrets de l'utilisateur :
1. **Ne pas voir l'heure passer** → rappels fiables même app fermée, calculés sur le temps réellement travaillé.
2. **Vouloir « finir un truc »** → prolongations courtes, justifiées et limitées.
3. **Mal décrocher** → rituel de coupure guidé + note « pour reprendre » affichée le lendemain.

Une version web prototype existe déjà (HTML/JS). Les règles métier ci-dessous en sont issues et font foi.

Langue : **UI et docs en français**, **code, noms de classes, commits en anglais**.

## Règles métier (source de vérité)

Valeurs par défaut, toutes modifiables dans les réglages :

| Paramètre | Défaut |
|---|---|
| Objectif journalier effectif | 7 h 45 (465 min) |
| Début du rituel de coupure | 17:30 |
| Heure de fin visée (soft) | 18:00 |
| Limite dure (hard) | 18:30 |
| Durée d'une prolongation | 20 min |
| Prolongations max / semaine | 2 |
| Seuil semaine vert | ≤ 39 h |
| Seuil semaine orange | 39 h – 42 h |
| Seuil semaine rouge | > 42 h |

- Une journée = liste de **sessions** `{start, end?, kind}` avec `kind ∈ {client, zenika}`. Une seule session ouverte à la fois.
- Temps effectif = somme des sessions (une session ouverte compte jusqu'à *maintenant*). Les trous entre sessions = pauses.
- Changer de `kind` pendant une session ouverte = fermer la session et en ouvrir une nouvelle à la même seconde.
- **Statut du jour** (évalué dans cet ordre) :
  - `idle` : aucune session ouverte.
  - `extension` : prolongation active et non expirée.
  - `stop` : maintenant ≥ limite dure **ou** effectif ≥ objectif + 60 min.
  - `warn` : maintenant ≥ fin visée **ou** effectif ≥ objectif.
  - `ritual` : maintenant ≥ début du rituel.
  - `ok` : sinon. Afficher le temps restant et l'heure de fin prévue = `min(maintenant + restant, fin visée)`.
- **Prolongation** : uniquement en `warn`/`stop`, avec une note facultative (une note vide s'affiche « Sans précision »), bloquée si quota hebdo atteint. La semaine va du lundi au dimanche.
- **Rituel de coupure** : 5 étapes cochables — finir ou geler / écrire la prochaine étape (texte) / vider sa tête / regarder demain (texte : 1 à 3 priorités) / fermer vraiment. Bouton « Journée terminée » : ferme la session, marque le jour comme terminé, fonctionne même si le rituel est incomplet.
- **Pour reprendre** : ce qu'il faut se rappeler pour recommencer à la session de travail suivante. Si l'effectif du jour < 45 min, afficher la dernière note « prochaine étape » + priorités du dernier jour qui en contient.
- **Repos légaux** (alertes, jamais bloquantes) : moins de 11 h entre l'heure de fin du travail (fin de la dernière session) et le début de la session suivante ; travail le samedi ou le dimanche.
- Une journée qui dépasse minuit reste rattachée au jour de son début.

## Stack

- Flutter stable, Dart 3, **Android uniquement** (minSdk 26, targetSdk dernier stable).
- État : `flutter_riverpod` (+ `riverpod_annotation` / `riverpod_generator`).
- Persistance : `drift` (SQLite) + `drift_dev`, `build_runner`.
- Notifications planifiées : `flutter_local_notifications` + `timezone`. Horodatages stockés en UTC, calculs faits dans le fuseau horaire actuel du téléphone.
- Chrono permanent : `flutter_foreground_task`.
- Lints : `very_good_analysis`.
- Tests : `flutter_test`, `mocktail`. L'horloge est toujours injectée (`Clock` abstraite), jamais `DateTime.now()` en dur dans le domaine ou les services.

**Ne pas ajouter de dépendance sans me demander**, en justifiant (maintenance, dernière release, alternative).

## Architecture

```
lib/
  domain/        # Dart pur, aucun import Flutter/drift. Entités, value objects, règles (StatusCalculator, WeekSummary...)
  data/          # drift : tables, DAO, mapping vers le domaine, implémentations des repositories
  services/      # notifications, foreground task, (plus tard) détection wifi/Bluetooth
  application/   # providers Riverpod, use cases (StartSession, PauseSession, Extend, FinishDay...)
  ui/            # écrans et widgets, par feature : today/, week/, settings/
  main.dart
test/            # miroir de lib/
android/         # code Kotlin natif uniquement pour ce que Flutter ne couvre pas (tuile, détection BT)
docs/backlog.md  # user stories
```

- Dépendances dans un seul sens : `ui → application → domain ← data/services`.
- Le domaine définit les interfaces de repository ; `data/` les implémente.
- Pas de logique métier dans les widgets.

## Commandes

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # après modif drift/riverpod
flutter analyze
flutter test
flutter run
```

## Contraintes Android à respecter

- Android 13+ : demander `POST_NOTIFICATIONS` au premier lancement, avec écran d'explication.
- Android 12+ : alarmes exactes (`SCHEDULE_EXACT_ALARM`) ; si refusé, basculer en inexact et le signaler dans l'UI.
- Android 14+ : déclarer le `foregroundServiceType` du service chrono dans le manifeste.
- Les rappels utilisent le canal et le son d'alarme (usage audio `alarm`) pour ne pas être coupés par « Ne pas déranger ».
- Proposer d'exclure l'app de l'optimisation batterie (lien vers les réglages système), sans l'imposer.
- Reprogrammer les rappels au boot (`RECEIVE_BOOT_COMPLETED`) et à chaque changement d'état.

## Façon de travailler

- Une user story à la fois, référencée par son ID (`US-xx`) dans `docs/backlog.md`.
- Chaque story ne crée que le stockage dont elle a besoin (pas de table anticipée), mais le plan explique comment il s'articulera avec les stories suivantes.
- Avant de coder : **résumer le plan en quelques lignes et attendre ma validation** si la story touche plus de 3 fichiers ou ajoute une dépendance.
- Domaine en **TDD** : tests d'abord, notamment pour les bornes (pile à 18:00, pile à l'objectif, quota atteint, passage de minuit).
- Terminer chaque story par `flutter analyze` sans warning et `flutter test` vert.
- Commits conventionnels en anglais (`feat(today): ...`, `test(domain): ...`), un commit par étape logique.
- Cocher la story dans `docs/backlog.md` une fois terminée.
- En cas de doute sur une règle métier : **demander**, ne pas inventer.

## Definition of Done

- Critères d'acceptation de la story couverts (tests pour la logique, vérification manuelle décrite pour l'UI).
- Analyse et tests verts.
- Textes UI en français, sans jargon, accessibles (contrastes, tailles de cible ≥ 48 dp, labels TalkBack).
- Pas de `TODO` sans ticket associé dans le backlog.
