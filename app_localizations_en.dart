// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SOMMACUSTOZA08';

  @override
  String get calendar => 'Calendar';

  @override
  String get trainings => 'Trainings';

  @override
  String get players => 'Players';

  @override
  String get matches => 'Matches';

  @override
  String get statistics => 'Statistics';

  @override
  String get staff => 'Staff';

  @override
  String get attendance => 'Attendance';

  @override
  String get formations => 'Formations';

  @override
  String get noEventsForDate => 'No events for this date';

  @override
  String eventsFor(String date) {
    return 'Events for $date';
  }
}
