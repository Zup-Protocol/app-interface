import 'package:flutter/widgets.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';
import 'package:zup_core/enums/time_unit.dart';
import 'package:zup_core/objects/time_ago.dart';

extension TimeAgoExtension on TimeAgo {
  String formattedTimeAgo(BuildContext context) {
    return switch (amountTimeUnit) {
      TimeUnit.milliseconds => S.of(context).xMillisecondsAgo(milliseconds: amount),
      TimeUnit.seconds => S.of(context).xSecondsAgo(seconds: amount),
      TimeUnit.minutes => S.of(context).xMinutesAndSecondsAgo(minutes: amount, seconds: remainder),
      TimeUnit.hours => S.of(context).xHoursAndMinutesAgo(hours: amount, minutes: remainder),
      TimeUnit.days => S.of(context).xDaysAndHoursAgo(days: amount, hours: remainder),
      TimeUnit.months => S.of(context).xMonthsAndDaysAgo(months: amount, days: remainder),
      TimeUnit.years => S.of(context).xYearsAndMonthsAgo(years: amount, months: remainder),
    };
  }
}
