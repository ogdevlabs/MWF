// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Move With Fergie';

  @override
  String get programsScreenTitle => 'Programs';

  @override
  String get progressScreenTitle => 'Progress';

  @override
  String get coachChatScreenTitle => 'Coach';

  @override
  String get notificationsScreenTitle => 'Notifications';

  @override
  String get sessionCompleteTitle => 'Session Complete!';

  @override
  String get retryButtonLabel => 'Retry';

  @override
  String get signInButtonLabel => 'Sign In';

  @override
  String get signUpButtonLabel => 'Sign Up';

  @override
  String get subscribeButtonLabel => 'Subscribe';

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get errorLoadFailed => 'Failed to load';

  @override
  String get emptyStateNoPrograms => 'No programs available';

  @override
  String get emptyStateNoMetrics => 'No data yet';

  @override
  String get emptyStateNoNotifications => 'No notifications yet';
}
