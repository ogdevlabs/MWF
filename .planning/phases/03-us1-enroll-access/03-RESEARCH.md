# Phase 3: US1 Enroll & Access - Research

**Researched:** 2026-05-25
**Domain:** Flutter in-app purchase (RevenueCat), auth/onboarding, program browse, offline-first CQRS
**Confidence:** HIGH — all findings sourced from installed package source code, existing project files, and official SDK APIs.

## Summary

Phase 3 builds on a fully-wired Phase 2 foundation (AuthRepository, Drift AppDatabase with all 9 tables, SyncQueue, CommandBus, QueryGateway, app_router with placeholders). The phase replaces placeholder screens with real implementations and adds three new feature layers: auth/onboarding flow, RevenueCat subscription/paywall, and program browse/detail.

The project uses purchases_flutter 10.1.1 (installed, verified from pub-cache). The correct configure pattern is `Purchases.configure(PurchasesConfiguration(apiKey)..appUserID = supabaseUserId)`. Entitlement check is `customerInfo.entitlements.active.containsKey('premium_access')`. The entitlement identifier `premium_access` is confirmed in `docs/external-service-setup.md`. The program catalog already has a CQRS view (`program_catalog_view`) that returns `is_subscribed` from the Supabase join, so lock/unlock overlay state is available directly from the QueryGateway.

The `google_sign_in 7.2.0` `authenticate()` pattern is already implemented in `AuthRepository.signInWithGoogle()`. The students table upsert must be done explicitly (no DB trigger exists in migration 001). SharedPreferences 2.5.5 is installed and supports both legacy and async APIs for the onboarding-seen flag.

**Primary recommendation:** Wire Purchases.configure() in main.dart after Supabase.initialize(), call Purchases.logIn(supabaseUserId) after any Supabase sign-in, and read `program_catalog_view` via QueryGateway (which already handles online/offline fallback to local Drift).

## Project Constraints (from CLAUDE.md)

**Git Workflow:** Never push directly to `main`. Always create a feature branch and open a PR. Main is protected.

## Standard Stack

### Core (all verified from pubspec.yaml and pub-cache)

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| purchases_flutter | 10.1.1 | RevenueCat SDK: Offerings, purchase, CustomerInfo | Installed in pubspec.yaml; only cross-platform IAP abstraction |
| freezed_annotation | 3.1.0 | Immutable domain models with copyWith, equality | Project standard; build_runner generates .freezed.dart |
| freezed (dev) | 3.2.6-dev.1 | Code generator for freezed_annotation | Installed dev dep |
| shared_preferences | 2.5.5 | Onboarding-seen flag, last-sync timestamp | Already used by SyncService |
| go_router | 17.2.3 | Named routes, auth redirect, ShellRoute bottom nav | Already wired via appRouterProvider |
| flutter_riverpod | 3.3.1 | State management; providers for subscription/programs | Project-wide standard |
| riverpod_annotation | 4.0.2 | Code-gen providers (@riverpod, @Riverpod) | Project-wide standard |
| supabase_flutter | 2.12.4 | Auth + database + RLS | Already initialized in main.dart |
| drift | 2.33.0 | Local SQLite ORM; all tables already defined | Foundation phase complete |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| sign_in_with_apple | 8.0.0 | Apple Sign-In (already implemented in AuthRepository) | iOS mandatory when Google Sign-In present |
| google_sign_in | 7.2.0 | Google Sign-In (7.x singleton pattern) | Android + iOS |
| connectivity_plus | 7.1.1 | Online/offline state for QueryGateway | Already wired as connectivityProvider |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Custom paywall UI | RevenueCat Paywalls SDK | Custom UI is simpler for this single-offering app; RevenueCat Paywalls adds dependency weight |
| Supabase subscription read | RevenueCat getCustomerInfo() only | Project uses Supabase subscription table as source of truth (webhook-written); RC is checked for real-time state |

**Installation:** All packages already in pubspec.yaml. No new packages needed for Phase 3 tasks T041–T058.

## Architecture Patterns

### Recommended Project Structure

Tasks T041–T058 follow this structure (already scaffolded in plan.md):
```
mobile/lib/features/
├── auth/
│   ├── domain/
│   │   ├── student_model.dart        # T041 @freezed Student
│   │   └── subscription_model.dart   # T048 @freezed Subscription
│   ├── data/
│   │   ├── auth_remote_datasource.dart      # T042
│   │   ├── student_remote_datasource.dart   # T043 upsert students table
│   │   └── subscription_repository.dart    # T049
│   └── presentation/
│       ├── login_screen.dart         # T044
│       ├── signup_screen.dart        # T045
│       ├── onboarding_screen.dart    # T046
│       └── paywall_screen.dart       # T050
└── programs/
    ├── domain/
    │   └── program_model.dart        # T052 @freezed Program
    ├── data/
    │   ├── programs_remote_datasource.dart  # T053 via QueryGateway
    │   ├── programs_local_datasource.dart   # T054 via ProgramsDao
    │   └── programs_repository.dart         # T055
    └── presentation/
        ├── program_list_screen.dart  # T056
        ├── program_detail_screen.dart # T057
        └── program_card_widget.dart  # T058
```

### Pattern 1: Freezed 3.x Domain Model (simple value class)

Freezed 3.x generates `sealed class` for unions. For simple single-constructor value objects, use `abstract class ... with _$ClassName`:

```dart
// Source: freezed_annotation 3.1.0 + freezed 3.2.6-dev.1 installed in project
// Simple value class (T041, T048, T052)
@freezed
abstract class Student with _$Student {
  const factory Student({
    required String id,
    required String email,
    String? displayName,
    String? avatarUrl,
    @Default('UTC') String timezone,
    required DateTime createdAt,
  }) = _Student;

  factory Student.fromJson(Map<String, dynamic> json) => _$StudentFromJson(json);
}

// Union/sealed type (useful for PaywallState, ProgramLoadState)
@freezed
sealed class SubscriptionState with _$SubscriptionState {
  const factory SubscriptionState.loading() = _Loading;
  const factory SubscriptionState.active(Subscription subscription) = _Active;
  const factory SubscriptionState.inactive() = _Inactive;
  const factory SubscriptionState.error(String message) = _Error;
}
```

**Key change from Freezed 2.x:** Classes must be `abstract class ... with _$ClassName` OR `sealed class ... with _$ClassName`. The `class ... with _$ClassName` pattern is no longer valid in freezed 3.x.

### Pattern 2: RevenueCat configure() + logIn()

```dart
// Source: purchases_flutter-10.1.1/lib/purchases_flutter.dart (verified)
// In main.dart, AFTER Supabase.initialize():
await Supabase.initialize(url: ..., anonKey: ...);

const rcApiKey = String.fromEnvironment('REVENUECAT_API_KEY');
final config = PurchasesConfiguration(rcApiKey);
// Do NOT set appUserID here — call logIn() after Supabase auth succeeds
await Purchases.configure(config);
```

Then, in auth_provider.dart or subscription_repository.dart, after Supabase sign-in:
```dart
// Link RevenueCat user to Supabase user ID
final supabaseUserId = supabase.auth.currentUser?.id;
if (supabaseUserId != null) {
  await Purchases.logIn(supabaseUserId);
}
```

On sign-out:
```dart
await Purchases.logOut();
```

### Pattern 3: RevenueCat Entitlement Check

```dart
// Source: purchases_flutter-10.1.1/lib/models/entitlement_infos_wrapper.dart (verified)
// Entitlement identifier: 'premium_access' (from docs/external-service-setup.md)
Future<bool> isSubscribed() async {
  try {
    final customerInfo = await Purchases.getCustomerInfo();
    return customerInfo.entitlements.active.containsKey('premium_access');
  } on PlatformException catch (e) {
    final errorCode = PurchasesErrorHelper.getErrorCode(e);
    // Return cached/local value if network unavailable
    return false;
  }
}
```

### Pattern 4: RevenueCat Paywall Screen with Offerings

```dart
// Source: purchases_flutter-10.1.1/lib/models/offerings_wrapper.dart (verified)
// Offerings.current returns the default offering configured in RC dashboard
// Offering.monthly / Offering.annual for typed package access
// Offering.availablePackages for all packages
Future<void> loadOfferings() async {
  final offerings = await Purchases.getOfferings();
  final current = offerings.current; // default offering
  if (current != null) {
    final monthly = current.monthly;   // Package? — null if not configured
    final annual = current.annual;     // Package? — null if not configured
    // availablePackages is the safe fallback
    final packages = current.availablePackages;
  }
}

// Purchase a package using the modern non-deprecated API:
Future<void> purchase(Package package) async {
  try {
    final result = await Purchases.purchase(
      PurchaseParams(package: package),
    );
    // result.customerInfo contains updated entitlement state
    final isActive = result.customerInfo.entitlements.active
        .containsKey('premium_access');
  } on PlatformException catch (e) {
    if (PurchasesErrorHelper.getErrorCode(e) !=
        PurchasesErrorCode.purchaseCancelledError) {
      // Surface error to user
    }
  }
}
```

### Pattern 5: Supabase students table upsert after signup

There is NO database trigger in migration 001 that auto-creates the students row on auth.users insert. The app must explicitly upsert the students row after sign-up. The students table has `id = auth.uid()` as its PK, enforced by RLS (`students_insert_own`: `WITH CHECK (id = auth.uid())`).

```dart
// Source: supabase/migrations/001_initial_schema.sql (verified — no trigger)
// student_remote_datasource.dart (T043)
Future<void> upsertStudentProfile({
  required String userId,
  required String email,
  String? displayName,
}) async {
  await supabase.from('students').upsert({
    'id': userId,
    'email': email,
    'display_name': displayName,
    'timezone': 'UTC',
  }, onConflict: 'id');
}
```

Call this in T045 (signup_screen) AFTER `authRepository.signUpWithEmail()` succeeds, and also after social logins (T044) for new users. Use `onConflict: 'id'` for idempotency on re-login with existing accounts.

### Pattern 6: SharedPreferences for onboarding-seen flag

```dart
// Source: shared_preferences-2.5.5 (verified — both async and legacy API available)
// Use legacy SharedPreferences (simpler, consistent with existing SyncService usage)
const _kOnboardingSeenKey = 'onboarding_seen';

Future<bool> hasSeenOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_kOnboardingSeenKey) ?? false;
}

Future<void> markOnboardingSeen() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_kOnboardingSeenKey, true);
}
```

Create a `OnboardingPrefsService` injectable via Riverpod. The router redirect logic (T047) watches `isAuthenticatedProvider` + a new `onboardingSeenProvider`.

### Pattern 7: go_router 17.x — named routes, parameters, bottom nav ShellRoute

The existing `app_router.dart` already uses `GoRoute` with `name:` fields and nested routes. No breaking changes needed; extend the existing provider.

```dart
// Source: go_router-17.2.3/lib/src/route.dart (verified)
// Named route push with parameters:
context.pushNamed('program-detail', pathParameters: {'programId': id});
context.goNamed('programs'); // tab-level navigation

// Bottom nav with StatefulShellRoute.indexedStack (preserves state per tab):
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) =>
      ScaffoldWithNavBar(navigationShell: navigationShell),
  branches: [
    StatefulShellBranch(routes: [
      GoRoute(path: '/programs', name: 'programs', builder: ...),
    ]),
    StatefulShellBranch(routes: [
      GoRoute(path: '/progress', name: 'progress', builder: ...),
    ]),
    StatefulShellBranch(routes: [
      GoRoute(path: '/notifications', name: 'notifications', builder: ...),
    ]),
  ],
)
```

**Note:** Bottom nav is optional for Phase 3 scope. The existing app_router.dart uses flat GoRoutes; introduce StatefulShellRoute only if task scope explicitly requires bottom nav in this phase. Task T047 wires redirects only — bottom nav can remain as existing structure.

### Pattern 8: program_catalog_view — CQRS projection for lock/unlock overlay

The `program_catalog_view` in `003_cqrs_read_models.sql` already returns `is_subscribed` and `enrollment_id` per row. The `QueryGateway.getProgramCatalog()` method already fetches this view and falls back to `_localProgramCatalog()` (local Drift) when offline.

```dart
// Source: mobile/lib/core/cqrs/query_gateway.dart (verified)
// In programs_remote_datasource.dart (T053):
final rows = await ref.read(queryGatewayProvider).getProgramCatalog();
// Each row map contains:
//   'id', 'title', 'description', 'difficulty', 'duration_weeks',
//   'thumbnail_url', 'published_at',
//   'enrollment_id' (null if not enrolled),
//   'current_day' (null if not enrolled),
//   'is_subscribed' (bool)
```

Map these rows to `ProgramModel` with an `isSubscribed` and `isEnrolled` field. The program list screen uses `isSubscribed` to decide locked overlay, and `enrollment_id != null` to show "Continue" vs "Enroll" CTA.

### Pattern 9: Offline — local_programs from Drift when QueryGateway falls back

The offline fallback in `QueryGateway._localProgramCatalog()` reads from `ProgramsDao.getAllPrograms()`. This returns `LocalProgram` rows that were previously synced. Note: the local fallback does NOT include `is_subscribed` (it returns an empty value for that field). The `ProgramsRepository` must handle this: when offline and local fallback is used, check local subscription status from Drift (a `local_subscriptions` table does NOT exist yet — see Open Questions).

### Pattern 10: Auth redirect wiring (T047)

The existing `appRouterProvider` watches `isAuthenticatedProvider`. The onboarding redirect requires an additional provider:

```dart
// Source: mobile/lib/shared/router/app_router.dart (existing)
// Extend existing redirect logic:
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final isAuth = ref.watch(isAuthenticatedProvider);
  final onboardingSeen = ref.watch(onboardingSeenProvider).valueOrNull ?? true;

  return GoRouter(
    initialLocation: '/programs',
    redirect: (context, state) {
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';
      final isOnboardingRoute = state.matchedLocation == '/onboarding';
      final isPaywallRoute = state.matchedLocation == '/paywall';

      if (!isAuth && !isAuthRoute) return '/login';
      if (isAuth && isAuthRoute) {
        return onboardingSeen ? '/programs' : '/onboarding';
      }
      if (isAuth && isOnboardingRoute && onboardingSeen) return '/programs';
      return null;
    },
    routes: [...], // replace placeholders with real screens
  );
}
```

### Anti-Patterns to Avoid

- **Calling `Purchases.setup()` instead of `Purchases.configure()`:** `setup()` is `@Deprecated`. Use `Purchases.configure(PurchasesConfiguration(apiKey))`.
- **Setting `appUserID` in PurchasesConfiguration:** Set it to null at configure time; call `Purchases.logIn(supabaseUserId)` after sign-in completes. This avoids race conditions.
- **Using `purchasePackage()` / `purchaseStoreProduct()`:** Both are `@Deprecated`. Use `Purchases.purchase(PurchaseParams(package: pkg))`.
- **Reading subscription status only from Supabase:** The Supabase subscriptions table is written by webhook (async). For real-time paywall decisions always call `Purchases.getCustomerInfo()` first, then cross-check Supabase for UI display.
- **Creating students row without `id = auth.uid()`:** RLS policy `students_insert_own` requires `WITH CHECK (id = auth.uid())`. Passing any other ID will result in a 403.
- **Using materialized views for read models:** Migration 003 correctly uses regular views with `security_invoker = true`. Do not change to materialized views — they cannot call `auth.uid()` at query time.
- **Freezed 2.x `class Foo with _$Foo`:** Freezed 3.x requires `abstract class Foo with _$Foo` or `sealed class Foo with _$Foo` for union types. Using bare `class` will cause build errors.
- **`SharedPreferencesAsync` for onboarding flag:** Overkill. Use `SharedPreferences.getInstance()` (legacy) consistent with how SyncService reads/writes last-sync timestamp.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| In-app purchase receipt validation | Custom StoreKit / Play Billing server | RevenueCat SDK (`purchases_flutter`) | Receipt validation is a security-critical subsystem with edge cases (jailbreak, clock skew, grace periods) |
| Subscription state management | Custom poll/refresh loop | `Purchases.addCustomerInfoUpdateListener` + `Purchases.getCustomerInfo()` | RevenueCat handles renewal, grace period, expiration state machine |
| Program lock/unlock overlay logic | Custom SQL join in client | `program_catalog_view.is_subscribed` from QueryGateway | View already computed in 003_cqrs_read_models.sql |
| Immutable domain models with equality | Manual `==` / `hashCode` | `@freezed` code generation | Handles nested collections, copyWith, JSON serialization |
| Auth state persistence | Manual token storage | Supabase session manager (auto-persisted) | supabase_flutter handles token refresh and secure storage |

**Key insight:** RevenueCat is designed specifically so you never call raw StoreKit or Play Billing. The constraint "In-app purchase receipt validation delegated entirely to RevenueCat" is already enforced by using `purchases_flutter` exclusively.

## Common Pitfalls

### Pitfall 1: RevenueCat configure() called before user identity is known
**What goes wrong:** Calling `Purchases.configure()` with `appUserID = supabaseUserId` in main.dart fails on first launch before any sign-in, and the user ID is null.
**Why it happens:** main.dart runs before auth state resolves.
**How to avoid:** Call `Purchases.configure(PurchasesConfiguration(rcApiKey))` (no appUserID) in main.dart. Call `Purchases.logIn(supabaseUserId)` in the auth success handler. Call `Purchases.logOut()` on Supabase sign-out.
**Warning signs:** `PlatformException: No appUserID set` or anonymous RC user IDs appearing in the dashboard.

### Pitfall 2: Supabase students row not created after social sign-in
**What goes wrong:** Apple/Google sign-in creates an `auth.users` row but NOT a `students` row. Subsequent queries against `students` (e.g., subscription join) return null.
**Why it happens:** Migration 001 has no trigger — the students insert must be explicit.
**How to avoid:** After every successful `signInWithApple()` or `signInWithGoogle()`, call `studentRemoteDatasource.upsertStudentProfile(...)`. Use `onConflict: 'id'` so returning users don't get 409 errors.
**Warning signs:** `program_catalog_view` returns empty results for subscribed users; join on `students.id` returns null.

### Pitfall 3: Onboarding redirect loop
**What goes wrong:** `appRouterProvider` is `@Riverpod(keepAlive: true)` and re-creates a new GoRouter each time `isAuthenticated` or `onboardingSeen` changes. If `onboardingSeenProvider` is async and emits loading/error before data, the redirect fires with undefined state.
**Why it happens:** `ref.watch(onboardingSeenProvider)` returns `AsyncValue` — accessing `.value` can be null during load.
**How to avoid:** Use `.valueOrNull ?? true` (default to "seen" during loading to avoid bouncing to /onboarding). Only redirect to `/onboarding` if `onboardingSeen == false` (explicit false, not null/loading).
**Warning signs:** App briefly flashes /onboarding on every launch.

### Pitfall 4: program_catalog_view offline fallback missing is_subscribed
**What goes wrong:** `QueryGateway._localProgramCatalog()` returns rows from `ProgramsDao` which has no `isSubscribed` field. Programs appear locked when offline even for subscribed users.
**Why it happens:** The local fallback was designed in Phase 2 before the subscription layer existed.
**How to avoid:** In `programs_repository.dart`, when using the local fallback, also check local subscription status. Since `local_subscriptions` table does NOT exist in the current schema (see Open Questions), the simplest safe approach is: check SharedPreferences for a cached `is_subscribed` boolean, or treat offline as "last known subscription state" from the Supabase table read (cached on last sync).
**Warning signs:** Offline users see paywall overlay for programs they've subscribed to.

### Pitfall 5: RevenueCat not finding offerings (sandbox setup required)
**What goes wrong:** `Purchases.getOfferings()` returns `Offerings(all: {}, current: null)` on simulator.
**Why it happens:** RevenueCat requires App Store Connect sandbox products created AND entitlement `premium_access` linked to products. Simulator IAP sandbox requires a signed-in sandbox tester account.
**How to avoid:** Handle `offerings.current == null` gracefully in paywall screen; show a "Subscription unavailable" state. Always test on physical device with sandbox account.
**Warning signs:** `current == null` in debug mode; getOfferings returns empty in unit tests (mock the call).

### Pitfall 6: go_router provider rebuilds create new GoRouter instance
**What goes wrong:** `appRouterProvider` uses `@Riverpod(keepAlive: true)` but is watching fast-changing providers. Each rebuild discards navigation stack history.
**Why it happens:** GoRouter is re-instantiated when providers change.
**How to avoid:** Keep the router watching only `isAuthenticatedProvider` (already stable, keepAlive) and a simple `FutureProvider` for `onboardingSeen` that resolves once and never changes. Do not watch granular program/subscription state inside the router.

## Code Examples

### Complete RevenueCat configure + logIn wiring

```dart
// mobile/lib/main.dart — after Supabase.initialize()
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  const rcAppleKey = String.fromEnvironment('REVENUECAT_APPLE_API_KEY');
  const rcGoogleKey = String.fromEnvironment('REVENUECAT_GOOGLE_API_KEY');
  final rcApiKey = defaultTargetPlatform == TargetPlatform.iOS
      ? rcAppleKey
      : rcGoogleKey;
  await Purchases.configure(PurchasesConfiguration(rcApiKey));

  runApp(const ProviderScope(child: MwfApp()));
}
```

### Subscription provider (T051)

```dart
// subscription_provider.dart
@riverpod
Future<bool> isSubscribed(Ref ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  try {
    final customerInfo = await Purchases.getCustomerInfo();
    return customerInfo.entitlements.active.containsKey('premium_access');
  } catch (_) {
    // Fallback: check local Supabase subscription row
    final supabase = ref.read(supabaseClientProvider);
    final rows = await supabase
        .from('subscriptions')
        .select('status')
        .eq('student_id', user.id)
        .eq('status', 'active')
        .limit(1);
    return (rows as List).isNotEmpty;
  }
}
```

### Program model with lock state (T052)

```dart
// program_model.dart
@freezed
abstract class ProgramModel with _$ProgramModel {
  const factory ProgramModel({
    required String id,
    required String title,
    String? description,
    required String difficulty,
    required int durationWeeks,
    String? thumbnailUrl,
    DateTime? publishedAt,
    String? enrollmentId,
    @Default(1) int currentDay,
    @Default(false) bool isSubscribed,
  }) = _ProgramModel;

  factory ProgramModel.fromCatalogRow(Map<String, dynamic> row) =>
      ProgramModel(
        id: row['id'] as String,
        title: row['title'] as String,
        description: row['description'] as String?,
        difficulty: row['difficulty'] as String,
        durationWeeks: row['duration_weeks'] as int,
        thumbnailUrl: row['thumbnail_url'] as String?,
        publishedAt: row['published_at'] != null
            ? DateTime.parse(row['published_at'] as String)
            : null,
        enrollmentId: row['enrollment_id'] as String?,
        currentDay: (row['current_day'] as int?) ?? 1,
        isSubscribed: (row['is_subscribed'] as bool?) ?? false,
      );
}
```

### Enrollment via CommandBus (T055)

```dart
// programs_repository.dart — enroll student
Future<void> enrollStudent({
  required String studentId,
  required String programId,
}) async {
  final enrollmentId = const Uuid().v4();
  // 1. Write to local Drift immediately
  await db.enrollmentsDao.upsertEnrollment(LocalEnrollmentsCompanion(
    id: Value(enrollmentId),
    studentId: Value(studentId),
    programId: Value(programId),
    enrolledAt: Value(DateTime.now()),
    currentDay: const Value(1),
  ));
  // 2. Enqueue for Supabase sync via CommandBus
  await ref.read(commandBusProvider).dispatch(
    CommandType.enrollProgram,
    {
      'id': enrollmentId,
      'student_id': studentId,
      'program_id': programId,
      'enrolled_at': DateTime.now().toIso8601String(),
      'current_day': 1,
    },
  );
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `Purchases.setup()` | `Purchases.configure(PurchasesConfiguration(...))` | RC SDK 4.x | setup() is @Deprecated in 10.x |
| `purchasePackage()` | `Purchases.purchase(PurchaseParams(package: pkg))` | RC SDK 7.x | Old method @Deprecated in 10.x |
| `freezed class Foo with _$Foo` | `freezed abstract class Foo with _$Foo` | Freezed 3.0 | Breaking — bare `class` fails build |
| Freezed 2.x union `when()` removed | `when()` / `map()` re-added in Freezed 3.1.0 | 2025-07-02 | Safe to use when/map on union types |
| SharedPreferences `getInstance()` | `SharedPreferencesAsync` or legacy | 2.4.x+ | Both APIs available; legacy still works |

**Deprecated/outdated:**
- `Purchases.setup()`: replaced by `Purchases.configure()`. Do not use.
- `Purchases.purchasePackage()` / `purchaseStoreProduct()` / `purchaseProduct()`: all `@Deprecated`. Use `Purchases.purchase(PurchaseParams(...))`.
- Freezed bare `class Foo with _$Foo`: must be `abstract class` or `sealed class` in freezed 3.x.

## Open Questions

1. **Local subscription table for offline is_subscribed**
   - What we know: `local_programs`, `local_enrollments` exist in Drift. `subscriptions` is readable from Supabase but no `local_subscriptions` Drift table was created in Phase 2.
   - What's unclear: Should `subscription_repository.dart` (T049) cache the active subscription status in SharedPreferences (simple key), or should it create a `LocalSubscriptions` Drift table?
   - Recommendation: Use SharedPreferences cached boolean `subscription_is_active` updated on each successful RC entitlement check. Avoids a new Drift migration at schema version 1. If more subscription fields are needed (grace period display), add a local table in Phase 3 as schemaVersion 2.

2. **Purchases.configure() API key: single key or platform-split**
   - What we know: RevenueCat has separate Apple and Google API keys. The external-service-setup.md references `REVENUECAT_APPLE_API_KEY` and `REVENUECAT_GOOGLE_API_KEY` as separate `--dart-define` vars.
   - What's unclear: The plan says Phase 3 wires RevenueCat configure. The API key must be selected by platform.
   - Recommendation: Use `defaultTargetPlatform` check in main.dart (shown in Code Examples above) to select the correct key.

3. **DAO for enrollments in T055 — enrollmentsDao not yet created**
   - What we know: Phase 2 created 8 DAOs (programs, sessions, exercises, progress, metric_logs, feedback, sync_queue, download_manifest). The `LocalEnrollments` table exists but `enrollmentsDao` is NOT in AppDatabase.
   - What's unclear: Was this an oversight in Phase 2, or is it intentional (handled via CommandBus/SyncQueue only)?
   - Recommendation: Create `EnrollmentsDao` as part of T055 or as a Wave 0 setup task. The AppDatabase `daos:` list must be updated + build_runner re-run.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| purchases_flutter | T050 paywall, T049 subscription | ✓ | 10.1.1 (pub-cache) | — |
| RevenueCat sandbox account | T050 paywall test | External config | — | Mock getOfferings() in tests |
| Apple IAP capability (Xcode) | T050 iOS purchase | Requires manual Xcode step | — | docs/external-service-setup.md §5 |
| Flutter (Dart SDK) | All tasks | ✓ | ^3.12.0 (pubspec.yaml) | — |
| Supabase project | T043 upsert, T053 programs | ✓ (initialized in main.dart) | 2.12.4 | — |
| build_runner | Freezed + Riverpod codegen | ✓ | 2.15.0 (dev dep) | — |

**Missing dependencies with no fallback:**
- RevenueCat dashboard configured with entitlement `premium_access` and products linked — required for paywall to show packages. Manual setup per `docs/external-service-setup.md §2`.
- Apple In-App Purchase Xcode capability — required for iOS purchase flow. Manual Xcode step per `docs/external-service-setup.md §5`.

**Missing dependencies with fallback:**
- Google Play sandbox — paywall tests can run on iOS-only until Android configuration is complete.

## Validation Architecture

> `workflow.nyquist_validation` key is absent from `.planning/config.json` — treated as enabled.

### Test Framework

| Property | Value |
|----------|-------|
| Framework | flutter_test (SDK) + mocktail 1.0.5 |
| Config file | none — flutter test discovers test/ automatically |
| Quick run command | `flutter test test/unit/features/ -x` |
| Full suite command | `flutter test` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| FR-001 | Email/password + Apple + Google sign-in present and functional | widget | `flutter test test/widget/auth/ -x` | ❌ Wave 0 |
| FR-002 | Subscription gating via RevenueCat entitlement | unit | `flutter test test/unit/features/subscription_repository_test.dart -x` | ❌ Wave 0 |
| FR-003 | Program browse with title, description, difficulty, lock state | widget | `flutter test test/widget/programs/ -x` | ❌ Wave 0 |

### Sampling Rate

- **Per task commit:** `flutter test test/unit/features/ -x`
- **Per wave merge:** `flutter test`
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps

- [ ] `test/unit/features/auth/student_model_test.dart` — covers FR-001 model construction
- [ ] `test/unit/features/subscription/subscription_repository_test.dart` — covers FR-002 entitlement check (mock Purchases.getCustomerInfo)
- [ ] `test/unit/features/programs/program_model_test.dart` — covers FR-003 fromCatalogRow mapping
- [ ] `test/widget/auth/login_screen_test.dart` — FR-001 sign-in buttons present
- [ ] `test/widget/programs/program_list_screen_test.dart` — FR-003 locked overlay + FR-002 paywall tap
- [ ] `test/unit/core/database/enrollments_dao_test.dart` — covers missing enrollmentsDao (see Open Questions)

## Sources

### Primary (HIGH confidence)

- `mobile/.dart_tool/package_config.json` — verified exact installed package versions
- `/Users/oglabs/.pub-cache/hosted/pub.dev/purchases_flutter-10.1.1/lib/purchases_flutter.dart` — `Purchases.configure()`, `Purchases.purchase()`, `Purchases.getCustomerInfo()`, `Purchases.logIn()` API
- `/Users/oglabs/.pub-cache/hosted/pub.dev/purchases_flutter-10.1.1/lib/models/offerings_wrapper.dart` — `Offerings.current`, `Offering.monthly`, `Offering.annual`, `Offering.availablePackages`
- `/Users/oglabs/.pub-cache/hosted/pub.dev/purchases_flutter-10.1.1/lib/models/customer_info_wrapper.dart` — `CustomerInfo.entitlements`
- `/Users/oglabs/.pub-cache/hosted/pub.dev/purchases_flutter-10.1.1/lib/models/entitlement_infos_wrapper.dart` — `EntitlementInfos.active` map keyed by entitlement ID
- `/Users/oglabs/.pub-cache/hosted/pub.dev/purchases_flutter-10.1.1/lib/models/purchases_configuration.dart` — `PurchasesConfiguration(apiKey)` constructor
- `/Users/oglabs/.pub-cache/hosted/pub.dev/freezed-3.2.6-dev.1/CHANGELOG.md` — confirmed `sealed class ... with _$ClassName` pattern for unions; `abstract class` for simple models; `when()`/`map()` re-added in 3.1.0
- `/Users/oglabs/.pub-cache/hosted/pub.dev/go_router-17.2.3/lib/src/route.dart` — `StatefulShellRoute.indexedStack`, `ShellRoute`, `GoRoute` APIs confirmed
- `/Users/oglabs/.pub-cache/hosted/pub.dev/shared_preferences-2.5.5/lib/src/shared_preferences_async.dart` — `getBool`, `setBool`, `getString`, `setString` APIs
- `supabase/migrations/001_initial_schema.sql` — confirmed no DB trigger for students table; RLS policies verified
- `supabase/migrations/003_cqrs_read_models.sql` — `program_catalog_view` fields verified: `is_subscribed`, `enrollment_id`, `current_day`
- `mobile/lib/core/cqrs/query_gateway.dart` — `getProgramCatalog()` method + local fallback structure
- `mobile/lib/core/cqrs/command_bus.dart` — `CommandType.enrollProgram` already exists
- `mobile/lib/core/auth/auth_repository.dart` — Google Sign-In 7.x `initialize()+authenticate()` pattern already implemented
- `mobile/lib/shared/router/app_router.dart` — existing GoRouter setup with placeholder routes, `@Riverpod(keepAlive: true)`
- `docs/external-service-setup.md` — entitlement ID `premium_access`, products `mwf_monthly_premium` / `mwf_annual_premium` confirmed

### Secondary (MEDIUM confidence)

- `specs/001-mat-pilates-coach/tasks.md` — T041–T058 task scope, confirmed enrollmentsDao missing from Phase 2 DAOs list
- `.planning/STATE.md` — Phase 2 decisions confirmed (upsert for idempotency, Google Sign-In 7.x singleton)

## Metadata

**Confidence breakdown:**
- RevenueCat API (configure, purchase, entitlement check): HIGH — read directly from installed 10.1.1 source
- Freezed 3.x patterns: HIGH — CHANGELOG and annotation source confirmed
- Supabase students upsert (no trigger): HIGH — verified migration SQL has no trigger
- program_catalog_view fields: HIGH — read directly from 003_cqrs_read_models.sql
- go_router ShellRoute / StatefulShellRoute: HIGH — source verified
- Pitfalls: HIGH — derived from actual installed API (deprecated annotations visible in source)
- Missing enrollmentsDao: HIGH — verified AppDatabase daos list vs table list

**Research date:** 2026-05-25
**Valid until:** 2026-06-25 (stable libraries; RC SDK changes rarely)
