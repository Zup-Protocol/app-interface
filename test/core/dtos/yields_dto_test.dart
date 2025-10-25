import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zup_app/core/dtos/pool_stats_dto.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/dtos/yields_dto.dart';
import 'package:zup_app/core/enums/pool_data_timeframe.dart';

void main() {
  test("When calling 'poolsSortedBy24hYield' it should short pools descending by 24h yield", () {
    final pools = [
      YieldDto.fixture().copyWith(total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 100)),
      YieldDto.fixture().copyWith(total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 87)),
      YieldDto.fixture().copyWith(total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 0)),
      YieldDto.fixture().copyWith(total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 2000)),
    ];

    final yields = YieldsDto.fixture().copyWith(pools: pools);

    expect(
      yields.poolsSortedBy24hYield,
      pools.sorted((a, b) => b.total24hStats!.yearlyYield.compareTo(a.total24hStats!.yearlyYield)),
    );
  });

  test("When calling 'poolsSortedBy7dYield' it should short pools descending by 7d yield", () {
    final pools = [
      YieldDto.fixture().copyWith(total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 12681)),
      YieldDto.fixture().copyWith(total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 111)),
      YieldDto.fixture().copyWith(total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 0)),
      YieldDto.fixture().copyWith(total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 21971972891)),
    ];

    final yields = YieldsDto.fixture().copyWith(pools: pools);

    expect(
      yields.poolsSortedBy7dYield,
      pools.sorted((a, b) => b.total7dStats!.yearlyYield.compareTo(a.total7dStats!.yearlyYield)),
    );
  });

  test("When calling 'poolsSortedBy30dYield' it should short pools descending by 30d yield", () {
    final pools = [
      YieldDto.fixture().copyWith(total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 089889888)),
      YieldDto.fixture().copyWith(total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 2222)),
      YieldDto.fixture().copyWith(total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 0)),
      YieldDto.fixture().copyWith(total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 12615654)),
    ];

    final yields = YieldsDto.fixture().copyWith(pools: pools);

    expect(
      yields.poolsSortedBy30dYield,
      pools.sorted((a, b) => b.total30dStats!.yearlyYield.compareTo(a.total30dStats!.yearlyYield)),
    );
  });

  test("When calling 'poolsSortedBy90dYield' it should short pools descending by 90d yield", () {
    final pools = [
      YieldDto.fixture().copyWith(total90dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 978888)),
      YieldDto.fixture().copyWith(total90dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 121)),
      YieldDto.fixture().copyWith(total90dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 0)),
      YieldDto.fixture().copyWith(total90dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 329087902)),
    ];

    final yields = YieldsDto.fixture().copyWith(pools: pools);

    expect(
      yields.poolsSortedBy90dYield,
      pools.sorted((a, b) => b.total90dStats!.yearlyYield.compareTo(a.total90dStats!.yearlyYield)),
    );
  });

  test("when calling 'poolsSortedByTimeframe' passing YieldTimeFrame.day it should return poolsSortedBy24hYield", () {
    final pools = [
      YieldDto.fixture().copyWith(total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 100)),
      YieldDto.fixture().copyWith(total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 87)),
      YieldDto.fixture().copyWith(total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 0)),
      YieldDto.fixture().copyWith(total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 2000)),
    ];

    final yields = YieldsDto.fixture().copyWith(pools: pools);

    expect(yields.poolsSortedByTimeframe(PoolDataTimeframe.day), yields.poolsSortedBy24hYield);
  });

  test("when calling 'poolsSortedByTimeframe' passing YieldTimeFrame.week it should return poolsSortedBy7dYield", () {
    final pools = [
      YieldDto.fixture().copyWith(total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 12681)),
      YieldDto.fixture().copyWith(total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 111)),
      YieldDto.fixture().copyWith(total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 0)),
      YieldDto.fixture().copyWith(total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 21971972891)),
    ];

    final yields = YieldsDto.fixture().copyWith(pools: pools);

    expect(yields.poolsSortedByTimeframe(PoolDataTimeframe.week), yields.poolsSortedBy7dYield);
  });

  test("when calling 'poolsSortedByTimeframe' passing YieldTimeFrame.month it should return poolsSortedBy30dYield", () {
    final pools = [
      YieldDto.fixture().copyWith(total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 089889888)),
      YieldDto.fixture().copyWith(total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 2222)),
      YieldDto.fixture().copyWith(total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 0)),
      YieldDto.fixture().copyWith(total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 12615654)),
    ];

    final yields = YieldsDto.fixture().copyWith(pools: pools);

    expect(yields.poolsSortedByTimeframe(PoolDataTimeframe.month), yields.poolsSortedBy30dYield);
  });

  test(
    "when calling 'poolsSortedByTimeframe' passing YieldTimeFrame.threeMonth it should return poolsSortedBy90dYield",
    () {
      final pools = [
        YieldDto.fixture().copyWith(total90dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 978888)),
        YieldDto.fixture().copyWith(total90dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 121)),
        YieldDto.fixture().copyWith(total90dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 0)),
        YieldDto.fixture().copyWith(total90dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 329087902)),
      ];

      final yields = YieldsDto.fixture().copyWith(pools: pools);

      expect(yields.poolsSortedByTimeframe(PoolDataTimeframe.threeMonth), yields.poolsSortedBy90dYield);
    },
  );
}
