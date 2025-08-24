// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'SOMMACUSTOZA08';

  @override
  String get calendar => 'Calendario';

  @override
  String get trainings => 'Allenamenti';

  @override
  String get players => 'Giocatori';

  @override
  String get matches => 'Partite';

  @override
  String get statistics => 'Statistiche';

  @override
  String get staff => 'Staff';

  @override
  String get attendance => 'Presenze';

  @override
  String get formations => 'Formazioni';

  @override
  String get noEventsForDate => 'Nessun evento per questa data';

  @override
  String eventsFor(String date) {
    return 'Eventi del $date';
  }
}
