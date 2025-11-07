import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zup_app/core/extensions/time_ago_extension.dart';
import 'package:zup_core/enums/time_unit.dart';
import 'package:zup_core/objects/time_ago.dart';

import '../../golden_config.dart';

void main() {
  Future<Widget> widgetBuilder(TimeAgo timeAgo) => GoldenConfig.builder(
    Builder(
      builder: (context) {
        return Text(timeAgo.formattedTimeAgo(context));
      },
    ),
  );

  testWidgets("When using formattedTimeAgo for milisseconds, it should use the correct string", (tester) async {
    await tester.pumpWidget(
      await widgetBuilder(
        TimeAgo(amountTimeUnit: TimeUnit.milliseconds, amount: 10, remainder: 0, remainderTimeUnit: TimeUnit.hours),
      ),
    );

    await tester.pumpAndSettle();

    expect((find.byType(Text).evaluate().first.widget as Text).data, "10 milliseconds ago");
  });

  testWidgets("When using formattedTimeAgo for seconds, it should use the correct string", (tester) async {
    await tester.pumpWidget(
      await widgetBuilder(
        TimeAgo(amountTimeUnit: TimeUnit.seconds, amount: 55, remainder: 0, remainderTimeUnit: TimeUnit.hours),
      ),
    );

    await tester.pumpAndSettle();

    expect((find.byType(Text).evaluate().first.widget as Text).data, "55 seconds ago");
  });

  testWidgets("When using formattedTimeAgo for minutes, with zero as remainder, it should only show the minutes ago", (
    tester,
  ) async {
    await tester.pumpWidget(
      await widgetBuilder(
        TimeAgo(amountTimeUnit: TimeUnit.minutes, amount: 55, remainder: 0, remainderTimeUnit: TimeUnit.seconds),
      ),
    );

    await tester.pumpAndSettle();

    expect((find.byType(Text).evaluate().first.widget as Text).data, "55 minutes ago");
  });

  testWidgets(
    "When using formattedTimeAgo for minutes, with non-zero as remainder, it should show the minutes and seconds ago",
    (tester) async {
      await tester.pumpWidget(
        await widgetBuilder(
          TimeAgo(amountTimeUnit: TimeUnit.minutes, amount: 55, remainder: 25, remainderTimeUnit: TimeUnit.seconds),
        ),
      );

      await tester.pumpAndSettle();

      expect((find.byType(Text).evaluate().first.widget as Text).data, "55 minutes and 25 seconds ago");
    },
  );

  testWidgets(
    "When using formattedTimeAgo for hours, with non-zero as remainder, it should show the hours and minutes ago",
    (tester) async {
      await tester.pumpWidget(
        await widgetBuilder(
          TimeAgo(amountTimeUnit: TimeUnit.hours, amount: 23, remainder: 54, remainderTimeUnit: TimeUnit.minutes),
        ),
      );

      await tester.pumpAndSettle();

      expect((find.byType(Text).evaluate().first.widget as Text).data, "23 hours and 54 minutes ago");
    },
  );

  testWidgets(
    """When using formattedTimeAgo for hours, with zero as remainder,
    it should not show the minutes ago, only the hours""",
    (tester) async {
      await tester.pumpWidget(
        await widgetBuilder(
          TimeAgo(amountTimeUnit: TimeUnit.hours, amount: 23, remainder: 0, remainderTimeUnit: TimeUnit.minutes),
        ),
      );

      await tester.pumpAndSettle();

      expect((find.byType(Text).evaluate().first.widget as Text).data, "23 hours ago");
    },
  );

  testWidgets(
    """When using formattedTimeAgo for days, with zero as remainder,
    it should not show the hours ago, only the days""",
    (tester) async {
      await tester.pumpWidget(
        await widgetBuilder(
          TimeAgo(amountTimeUnit: TimeUnit.days, amount: 11, remainder: 0, remainderTimeUnit: TimeUnit.hours),
        ),
      );

      await tester.pumpAndSettle();

      expect((find.byType(Text).evaluate().first.widget as Text).data, "11 days ago");
    },
  );

  testWidgets(
    """When using formattedTimeAgo for days, with non-zero as remainder,
    it should show the days and hours ago""",
    (tester) async {
      await tester.pumpWidget(
        await widgetBuilder(
          TimeAgo(amountTimeUnit: TimeUnit.days, amount: 18, remainder: 22, remainderTimeUnit: TimeUnit.hours),
        ),
      );

      await tester.pumpAndSettle();

      expect((find.byType(Text).evaluate().first.widget as Text).data, "18 days and 22 hours ago");
    },
  );

  testWidgets(
    """When using formattedTimeAgo for months, with zero as remainder,
    it should not show the days ago, only the months""",
    (tester) async {
      await tester.pumpWidget(
        await widgetBuilder(
          TimeAgo(amountTimeUnit: TimeUnit.months, amount: 11, remainder: 0, remainderTimeUnit: TimeUnit.days),
        ),
      );

      await tester.pumpAndSettle();

      expect((find.byType(Text).evaluate().first.widget as Text).data, "11 months ago");
    },
  );

  testWidgets(
    """When using formattedTimeAgo for months, with non-zero as remainder,
    it should show the months and days ago""",
    (tester) async {
      await tester.pumpWidget(
        await widgetBuilder(
          TimeAgo(amountTimeUnit: TimeUnit.months, amount: 18, remainder: 22, remainderTimeUnit: TimeUnit.days),
        ),
      );

      await tester.pumpAndSettle();

      expect((find.byType(Text).evaluate().first.widget as Text).data, "18 months and 22 days ago");
    },
  );

  testWidgets(
    """When using formattedTimeAgo for years, with zero as remainder,
    it should not show the months ago, only the years""",
    (tester) async {
      await tester.pumpWidget(
        await widgetBuilder(
          TimeAgo(amountTimeUnit: TimeUnit.years, amount: 11, remainder: 0, remainderTimeUnit: TimeUnit.months),
        ),
      );

      await tester.pumpAndSettle();

      expect((find.byType(Text).evaluate().first.widget as Text).data, "11 years ago");
    },
  );

  testWidgets(
    """When using formattedTimeAgo for years, with non-zero as remainder,
    it should show the years and months ago""",
    (tester) async {
      await tester.pumpWidget(
        await widgetBuilder(
          TimeAgo(amountTimeUnit: TimeUnit.years, amount: 18, remainder: 22, remainderTimeUnit: TimeUnit.months),
        ),
      );

      await tester.pumpAndSettle();

      expect((find.byType(Text).evaluate().first.widget as Text).data, "18 years and 22 months ago");
    },
  );
}
