# Architecture du Projet Betif (School App)

**Date** : 2026-05-25  
**Objectif** : Application Flutter multi-platform (mobile + web + desktop) avec gestion de rôles (Admin / Prof / Étudiant), authentification Supabase, dashboards spécifiques et logique métier.

---

## 1. Choix d'Architecture : Meilleur pour ce projet

**Architecture retenue : Clean Architecture + MVVM hybride avec approche Feature-First**

### Pourquoi ce choix est le meilleur ici :

| Critère                        | Clean + MVVM + Feature-First | Alternatives rejetées                  | Raison du rejet |
|--------------------------------|------------------------------|----------------------------------------|-----------------|
| Séparation des responsabilités | Excellente (Domain pur)     | -                                      | - |
| Facilité de test               | Très bonne                    | Bloc pur                               | Trop de boilerplate |
| Vitesse de développement       | Excellente (Riverpod)         | GetX / Provider simple                 | Manque de structure à long terme |
| Gestion des rôles + dashboards | Parfaite (guards + providers) | Pure Layered sans features             | Trop rigide et lent à scaler |
| Multi-platform + Supabase      | Idéale                        | -                                      | - |
| Maintenance long terme         | Excellente                    | -                                      | - |

**Stack technique choisie :**
- **State Management** : `flutter_riverpod` + `riverpod_annotation` (MVVM moderne, async notifiers excellents pour auth/Supabase)
- **Navigation** : `go_router` (déclarative + role guards natifs)
- **Backend Auth & DB** : `supabase_flutter` (Auth + Realtime + RLS)
- **Modèles** : `freezed` + `json_serializable`
- **Routing + Auth** : Role-based redirects
- **DI** : Riverpod (providers comme source de vérité) + éventuel `get_it` pour les repositories si besoin

---

## 2. Structure des Dossiers (Feature-First Clean)

```
lib/
├── app/
│   ├── router/                  # go_router + role guards
│   └── providers/               # providers globaux (auth, theme...)
├── core/
│   ├── constants/
│   ├── errors/                  # Failure classes
│   ├── supabase/                # Client Supabase + initialisation
│   ├── theme/
│   └── utils/
├── features/
│   ├── auth/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── pages/
│   │       ├── viewmodels/      # Riverpod Notifiers (MVVM)
│   │       └── widgets/
│   ├── admin/
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/        # Dashboard Admin + gestion users/classes
│   ├── professor/
│   │   └── ...                  # Dashboard Prof + cours, notes, etc.
│   ├── student/
│   │   └── ...                  # Dashboard Étudiant + emploi du temps, notes
│   └── shared/                  # Entités communes (User, Course, Class, Role)
│       └── domain/
│           └── entities/
└── main.dart
```

**Règles importantes :**
- Le dossier `domain` ne dépend **jamais** de Flutter, de Supabase ou de Riverpod.
- Les `data` implémentent les contrats du `domain`.
- La `presentation` (ViewModels) utilise Riverpod et appelle les usecases.
- Chaque feature est autonome (sauf dépendances vers `shared` et `core`).

---

## 3. Flux Authentification + Rôles

1. Supabase Auth (email/password ou OAuth)
2. Après login → lecture du rôle via table `profiles` ou `user_roles` (ou metadata Supabase)
3. `AuthNotifier` (Riverpod) expose l'utilisateur + rôle courant
4. `go_router` redirect :
   - Non authentifié → `/login`
   - Authentifié + rôle admin → `/admin/dashboard`
   - Authentifié + rôle prof → `/prof/dashboard`
   - Authentifié + rôle student → `/student/dashboard`

---

## 4. Couches détaillées

### Domain (Business Rules)
- Entities : `User`, `Role`, `Course`, `Classroom`, etc.
- Repository interfaces (abstraites)
- Usecases (ex: `LoginUseCase`, `GetStudentScheduleUseCase`)

### Data
- Remote datasource : appels Supabase (PostgREST + Auth)
- Models : DTOs (Freezed + fromJson)
- Repository implementations

### Presentation (MVVM)
- Pages (UI pure)
- ViewModels = Riverpod `Notifier` / `AsyncNotifier`
- Widgets réutilisables

---

## 5. Pourquoi pas d'autres architectures ?

- **Pure Clean Layered** (data/domain/presentation global) → trop de navigation entre dossiers pour une app avec 3 dashboards très différents.
- **Bloc** → excellent mais beaucoup de fichiers pour chaque feature (surtout pour des dashboards simples).
- **Feature-First + Riverpod MVVM** = le meilleur équilibre en 2026 pour ce type de projet.

---

## 6. Prochaines étapes d'implémentation (suivies par l'agent)

1. Ajout des dépendances
2. Initialisation Supabase
3. Création des entités de base + Role enum
4. Feature Auth complète (login + role guard)
5. Dashboards vides par rôle avec navigation
6. Exemples de logique métier (CRUD cours/classe selon rôle)

---

**Cette architecture est scalable, testable et maintenable pour une application scolaire multi-rôles.**
