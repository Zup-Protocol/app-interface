import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';

enum PoolDataTimeframe {
  day,
  week,
  month,
  threeMonth;

  static PoolDataTimeframe? fromValue(String name) {
    return PoolDataTimeframe.values.firstWhereOrNull((e) => e.name == name);
  }
}

extension YieldTimeFrameExtension on PoolDataTimeframe {
  bool get isDay => this == PoolDataTimeframe.day;
  bool get isWeek => this == PoolDataTimeframe.week;
  bool get isMonth => this == PoolDataTimeframe.month;
  bool get isThreeMonth => this == PoolDataTimeframe.threeMonth;

  String label(BuildContext context) {
    return switch (this) {
      PoolDataTimeframe.day => S.of(context).twentyFourHours,
      PoolDataTimeframe.week => S.of(context).week,
      PoolDataTimeframe.month => S.of(context).month,
      PoolDataTimeframe.threeMonth => S.of(context).threeMonths,
    };
  }

  String compactDaysLabel(BuildContext context) => switch (this) {
    PoolDataTimeframe.day => S.of(context).twentyFourHoursCompact,
    PoolDataTimeframe.week => S.of(context).weekCompact,
    PoolDataTimeframe.month => S.of(context).monthCompact,
    PoolDataTimeframe.threeMonth => S.of(context).threeMonthsCompact,
  };
}
