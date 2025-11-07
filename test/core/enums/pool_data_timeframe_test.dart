import 'package:flutter_test/flutter_test.dart';
import 'package:zup_app/core/enums/pool_data_timeframe.dart';

void main() {
  test("When calling 'isDay' and the timeframe is day, it should return true", () {
    expect(PoolDataTimeframe.day.isDay, true);
  });

  test("When calling 'isDay' and the timeframe is not day, it should return false", () {
    expect(PoolDataTimeframe.week.isDay, false);
  });

  test("When calling isWeek and the timeframe is week, it should return true", () {
    expect(PoolDataTimeframe.week.isWeek, true);
  });

  test("When calling isWeek and the timeframe is not week, it should return false", () {
    expect(PoolDataTimeframe.day.isWeek, false);
  });

  test("When calling isMonth and the timeframe is month, it should return true", () {
    expect(PoolDataTimeframe.month.isMonth, true);
  });

  test("When calling isMonth and the timeframe is not month, it should return false", () {
    expect(PoolDataTimeframe.day.isMonth, false);
  });

  test("When calling isThreeMonth and the timeframe is threeMonth, it should return true", () {
    expect(PoolDataTimeframe.threeMonth.isThreeMonth, true);
  });

  test("When calling isThreeMonth and the timeframe is not threeMonth, it should return false", () {
    expect(PoolDataTimeframe.day.isThreeMonth, false);
  });
}
