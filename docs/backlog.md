# Backlog — Pointage

À placer dans `docs/backlog.md`. Chaque story contient un prompt prêt à coller dans Claude Code.
Les règles métier détaillées sont dans `CLAUDE.md` : les stories y renvoient au lieu de les répéter.

## Prompt de démarrage (première session)

```
Lis CLAUDE.md et docs/backlog.md. Ne code rien pour l'instant.
Reformule en 10 lignes max ce que tu as compris du produit et des règles métier,
liste les ambiguïtés ou contradictions que tu vois, puis propose l'ordre de réalisation
des stories de la v1. Attends ma validation.
```

## Prompt générique (pour chaque story)

```
Implémente US-XX de docs/backlog.md en suivant CLAUDE.md.
1. Propose ton plan (fichiers touchés, dépendances éventuelles) et attends ma validation.
2. Tests d'abord pour la logique, puis implémentation.
3. Termine par flutter analyze et flutter test, corrige jusqu'à ce que tout soit vert.
4. Coche la story et résume ce que je dois vérifier manuellement sur le téléphone.
```

## Ordre de réalisation (v0 + v1)

US-00 → US-01 → US-02 → US-03 → US-04a → US-09 → US-10 → US-05 → US-07 → US-06 → US-08 → US-11 → US-04b → US-12 → US-13 → US-14

---

## v0 — Socle

### [ ] US-00 — Initialiser le projet
**En tant que** développeur, **je veux** un projet Flutter propre et outillé **afin de** démarrer sur de bonnes bases.

Critères d'acceptation :
- Projet Android uniquement, package `fr.thomas.pointage` (modifiable), minSdk 26.
- Arborescence de `CLAUDE.md` créée (dossiers vides avec `.gitkeep`).
- `very_good_analysis` configuré, `flutter analyze` sans warning.
- Abstraction `Clock` dans `domain/` avec une implémentation système et une implémentation de test.
- GitHub Actions (`.github/workflows/ci.yml`) : jobs `analyze` et `test` sur Flutter stable.
- README court : lancer, tester, générer le code.

Prompt :
```
Implémente US-00. Utilise flutter create puis adapte. N'ajoute que les dépendances
listées dans CLAUDE.md dont on a besoin maintenant (lints, test, mocktail).
```

---

## v1 — MVP

### [ ] US-01 — Modèle de domaine et calcul du statut
**En tant qu'**utilisateur, **je veux** que l'app sache si je suis dans les clous **afin d'**être prévenu au bon moment.

Critères d'acceptation :
- Entités : `Session`, `WorkDay`, `WorkKind`, `Settings`, `Extension`, `ShutdownRitual`.
- `StatusCalculator` renvoie `idle | ok | ritual | warn | extension | stop`, avec temps restant et heure de fin prévue, selon l'ordre défini dans `CLAUDE.md`.
- `WeekSummary` : total, répartition client/Zenika, zone vert/orange/rouge, prolongations utilisées.
- Tests aux bornes : pile à l'objectif, pile à 17:30 / 18:00 / 18:30, objectif + 60 min, prolongation expirée à la seconde près, session qui passe minuit, semaine du lundi au dimanche.

Prompt :
```
Implémente US-01 en TDD strict : écris d'abord tous les tests de StatusCalculator
et WeekSummary (cas nominaux et bornes listées), montre-les-moi, puis implémente.
Dart pur, aucun import Flutter.
```

### [ ] US-02 — Persistance
**En tant qu'**utilisateur, **je veux** que mes données survivent au redémarrage **afin de** ne rien perdre.

Critères d'acceptation :
- Tables drift : sessions, days (rituel, notes, terminé), extensions, settings.
- Repositories définis dans le domaine, implémentés dans `data/`.
- Invariant garanti : une seule session ouverte à la fois (test).
- Tests sur base en mémoire.

Prompt :
```
Implémente US-02. Propose d'abord le schéma drift et le mapping vers le domaine.
Prévois une stratégie de migration (schemaVersion) dès maintenant.
```

### [ ] US-03 — Écran « Aujourd'hui » : pointer
**En tant qu'**utilisateur, **je veux** démarrer, mettre en pause et changer de type de temps en un tap **afin de** pointer sans effort.

Critères d'acceptation :
- Grand compteur du temps effectif, fond coloré selon le statut (vert / orange / rouge, neutre si `idle`).
- Message contextuel : temps restant et fin prévue, « C'est l'heure du rituel », « Objectif atteint », « Limite dépassée ».
- Bouton principal Démarrer / Pause / Reprendre.
- Sélecteur Client / Zenika ; en changer pendant une session applique la règle de `CLAUDE.md`.
- Frise de la journée 8h–20h avec sessions colorées par type, repères fin visée et limite, curseur « maintenant ».
- Rafraîchissement au moins toutes les 30 s et au retour au premier plan.

Prompt :
```
Implémente US-03. Crée les use cases StartSession, PauseSession, SwitchKind dans
application/ avec leurs tests, puis l'écran. Montre-moi une capture ou décris le rendu
pour chaque statut.
```

### [ ] US-04 — Corriger ses horaires

Découpée en deux : **US-04a** (jour courant, juste après US-03) et **US-04b** (jours passés, après US-11).
**En tant qu'**utilisateur qui a oublié de pointer, **je veux** modifier ou ajouter des plages **afin que** mes totaux restent justes.

Critères d'acceptation :
- US-04a — Liste des sessions du jour : modifier début/fin, changer le type, supprimer, ajouter une plage.
- US-04a — Validation : fin > début, pas de chevauchement, pas de fin dans le futur ; message clair sinon.
- US-04b — Possible aussi sur un jour passé de la semaine (depuis la vue semaine, US-11).

### [ ] US-05 — Permissions et fiabilité Android
**En tant qu'**utilisateur, **je veux** que les rappels arrivent vraiment **afin de** pouvoir compter dessus.

Critères d'acceptation :
- Écran d'accueil au premier lancement expliquant pourquoi l'app demande les notifications et les alarmes exactes.
- Gestion des refus : l'app reste utilisable et affiche un bandeau « rappels peu fiables » avec lien vers les réglages.
- Lien vers l'exclusion de l'optimisation batterie.
- Écran Réglages > Diagnostic : état de chaque permission.

Prompt :
```
Implémente US-05. Vérifie les exigences actuelles d'Android 13, 14 et 15 pour les
notifications, alarmes exactes et services de premier plan avant de coder, et
signale-moi tout écart avec CLAUDE.md.
```

### [ ] US-06 — Chrono permanent dans la notification
**En tant qu'**utilisateur, **je veux** voir mon temps de travail dans la barre de notifications **afin de** garder l'heure en tête sans ouvrir l'app.

Critères d'acceptation :
- Notification persistante pendant une session : temps effectif, type, statut (pastille couleur ou emoji).
- Actions dans la notification : Pause / Reprendre, Client ↔ Zenika.
- Disparaît en `idle` ; se relance si l'app est tuée pendant une session ouverte.

### [ ] US-07 — Rappels dynamiques
**En tant qu'**utilisateur qui ne voit pas l'heure passer, **je veux** être alerté au début du rituel, à la fin visée et à la limite **afin de** m'arrêter à temps.

Critères d'acceptation :
- Trois notifications, avec le son d'alarme (non coupées par « Ne pas déranger ») : rituel, fin (« objectif atteint »), limite. Chacune au plus tôt entre l'heure réglée et le moment où le temps effectif atteint le seuil correspondant.
- Replanification à chaque démarrage, pause, changement de réglage, correction d'horaires et au boot.
- Pas de rappel si la journée est terminée ou en pause ; pas de doublon.
- Tap sur la notification → écran Aujourd'hui avec la bonne action mise en avant.
- Logique de calcul des heures de rappel dans le domaine, testée.

Prompt :
```
Implémente US-07. Sépare le calcul des heures de rappel (domaine, testé) de la
planification (service). Documente dans le code comment tester manuellement en
avançant l'heure du téléphone.
```

### [ ] US-08 — Prolongation « Encore 20 min »
**En tant qu'**utilisateur qui veut finir un truc, **je veux** prolonger brièvement en le justifiant **afin de** finir sans que ça dérape.

Critères d'acceptation :
- Proposée en `warn` et `stop`, depuis l'écran et depuis la notification de fin.
- Note facultative (champ texte) ; une note vide s'affiche « Sans précision » (vue semaine, lendemain).
- Compteur « x/2 cette semaine » ; bouton désactivé au quota avec message incitant à noter la prochaine étape.
- Replanifie un rappel à la fin de la prolongation.

### [ ] US-09 — Rituel de coupure
**En tant qu'**utilisateur qui décroche mal, **je veux** un rituel guidé **afin de** terminer ma journée l'esprit libre.

Critères d'acceptation :
- Carte avec les 5 étapes de `CLAUDE.md`, champs texte « prochaine étape » et « priorités de demain » sauvegardés à la frappe.
- Mise en avant visuelle à partir de l'heure du rituel si une session est ouverte.
- « Journée terminée » : ferme la session, annule les rappels du jour, affiche « Bonne soirée ».

### [ ] US-10 — Pour reprendre
**En tant qu'**utilisateur, **je veux** retrouver le matin ce que j'avais noté la veille **afin de** redémarrer en deux minutes.

Critères d'acceptation :
- Bloc en haut de l'écran Aujourd'hui tant que l'effectif du jour < 45 min.
- Affiche la prochaine étape et les priorités du dernier jour qui en contient, avec le jour concerné (« noté vendredi »).

### [ ] US-11 — Vue semaine
**En tant qu'**utilisateur, **je veux** voir ma semaine d'un coup d'œil **afin de** repérer une surcharge qui s'installe.

Critères d'acceptation :
- Une ligne par jour (samedi/dimanche seulement s'ils sont travaillés) : barre empilée client/Zenika, repère d'objectif, total.
- Total hebdo, répartition, pastille de zone.
- Liste des prolongations de la semaine avec leurs notes.
- Navigation vers les semaines précédentes ; tap sur un jour → correction (US-04).

### [ ] US-12 — Réglages
**En tant qu'**utilisateur, **je veux** ajuster mes seuils **afin que** l'app colle à mon organisation.

Critères d'acceptation :
- Tous les paramètres du tableau de `CLAUDE.md`, avec validation (rituel < fin visée < limite).
- Toute modification replanifie les rappels.

### [ ] US-13 — Alertes repos et week-end
**En tant que** cadre au forfait jours, **je veux** être averti si je ne respecte pas mes repos **afin de** me protéger.

Critères d'acceptation :
- Au démarrage d'une session : alerte si moins de 11 h depuis la fin de la dernière journée travaillée, ou si c'est un samedi/dimanche.
- Non bloquant ; l'événement est enregistré et visible dans la vue semaine.

### [ ] US-14 — Bilan annuel et export
**En tant que** cadre au forfait jours, **je veux** un bilan exportable **afin de** préparer mon entretien annuel de charge.

Critères d'acceptation :
- Année civile : jours travaillés (comparés au plafond de 218, modifiable), moyenne hebdo, semaines par zone, prolongations, alertes repos.
- Export CSV (une ligne par session) via la feuille de partage Android.

---

## v2 — Accès rapide

### [ ] US-15 — Widget d'écran d'accueil
**En tant qu'**utilisateur, **je veux** un widget **afin de** voir mon temps et pointer sans ouvrir l'app.

Critères d'acceptation :
- Affiche temps effectif, statut coloré, bouton Démarrer/Pause.
- Mis à jour à chaque changement d'état et au moins toutes les 15 min.

Prompt :
```
Implémente US-15. Compare home_widget et une implémentation Glance native, recommande
une option et attends ma validation.
```

### [ ] US-16 — Tuile de réglages rapides
**En tant qu'**utilisateur, **je veux** une tuile dans le volet des réglages rapides **afin de** pointer d'un glissement.

Critères d'acceptation :
- `TileService` Kotlin : active = session ouverte ; tap = Démarrer/Pause.
- Communique avec la même source de données que l'app (pas de double état).

---

## v3 — Auto-pointage

### [ ] US-17 — Détection du wifi du bureau
**En tant qu'**utilisateur qui oublie de pointer, **je veux** que l'app me propose de démarrer en arrivant au bureau **afin de** ne plus oublier.

Critères d'acceptation :
- Réglage : liste de SSID « travail » (bouton « ajouter le réseau actuel »).
- Connexion à un SSID travail sans session ouverte → notification « Tu démarres ? » avec action. Jamais de démarrage silencieux.
- Déconnexion avec session ouverte → notification « Tu as fini ? » avec actions Pause / Journée terminée.
- Permission de localisation expliquée avant la demande.

Prompt :
```
Implémente US-17. Commence par une note technique : quelles API Android permettent
de réagir à un changement de wifi app fermée en 2026, quelles restrictions, quelles
permissions. Recommande une approche avant de coder.
```

### [ ] US-18 — Détection Bluetooth du portable pro
**En tant qu'**utilisateur, **je veux** que la connexion au Bluetooth de mon portable pro serve de signal de début et de fin **afin de** couvrir le télétravail.

Critères d'acceptation :
- Réglage : choisir un appareil appairé.
- Même comportement de proposition que US-17.
- Implémentation Kotlin (BroadcastReceiver sur les événements de connexion ACL) exposée via un platform channel.
