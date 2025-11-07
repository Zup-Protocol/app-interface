import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zup_app/core/dtos/liquidity_pool_dto.dart';
import 'package:zup_app/core/dtos/liquidity_pools_search_result_dto.dart';
import 'package:zup_app/core/dtos/pool_stats_dto.dart';
import 'package:zup_app/core/enums/pool_data_timeframe.dart';

void main() {
  test("When calling 'poolsSortedBy24hYield' it should short pools descending by 24h yield", () {
    final pools = [
      LiquidityPoolDto.fixture().copyWith(total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 100)),
      LiquidityPoolDto.fixture().copyWith(total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 87)),
      LiquidityPoolDto.fixture().copyWith(total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 0)),
      LiquidityPoolDto.fixture().copyWith(total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 2000)),
    ];

    final yields = LiquidityPoolsSearchResultDto.fixture().copyWith(pools: pools);

    expect(
      yields.poolsSortedBy24hYield,
      pools.sorted((a, b) => b.total24hStats!.yearlyYield.compareTo(a.total24hStats!.yearlyYield)),
    );
  });

  test("When calling 'poolsSortedBy7dYield' it should short pools descending by 7d yield", () {
    final pools = [
      LiquidityPoolDto.fixture().copyWith(total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 12681)),
      LiquidityPoolDto.fixture().copyWith(total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 111)),
      LiquidityPoolDto.fixture().copyWith(total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 0)),
      LiquidityPoolDto.fixture().copyWith(total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 21971972891)),
    ];

    final yields = LiquidityPoolsSearchResultDto.fixture().copyWith(pools: pools);

    expect(
      yields.poolsSortedBy7dYield,
      pools.sorted((a, b) => b.total7dStats!.yearlyYield.compareTo(a.total7dStats!.yearlyYield)),
    );
  });

  test("When calling 'poolsSortedBy30dYield' it should short pools descending by 30d yield", () {
    final pools = [
      LiquidityPoolDto.fixture().copyWith(total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 089889888)),
      LiquidityPoolDto.fixture().copyWith(total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 2222)),
      LiquidityPoolDto.fixture().copyWith(total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 0)),
      LiquidityPoolDto.fixture().copyWith(total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 12615654)),
    ];

    final yields = LiquidityPoolsSearchResultDto.fixture().copyWith(pools: pools);

    expect(
      yields.poolsSortedBy30dYield,
      pools.sorted((a, b) => b.total30dStats!.yearlyYield.compareTo(a.total30dStats!.yearlyYield)),
    );
  });

  test("When calling 'poolsSortedBy90dYield' it should short pools descending by 90d yield", () {
    final pools = [
      LiquidityPoolDto.fixture().copyWith(total90dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 978888)),
      LiquidityPoolDto.fixture().copyWith(total90dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 121)),
      LiquidityPoolDto.fixture().copyWith(total90dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 0)),
      LiquidityPoolDto.fixture().copyWith(total90dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 329087902)),
    ];

    final yields = LiquidityPoolsSearchResultDto.fixture().copyWith(pools: pools);

    expect(
      yields.poolsSortedBy90dYield,
      pools.sorted((a, b) => b.total90dStats!.yearlyYield.compareTo(a.total90dStats!.yearlyYield)),
    );
  });

  test("when calling 'poolsSortedByTimeframe' passing YieldTimeFrame.day it should return poolsSortedBy24hYield", () {
    final pools = [
      LiquidityPoolDto.fixture().copyWith(total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 100)),
      LiquidityPoolDto.fixture().copyWith(total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 87)),
      LiquidityPoolDto.fixture().copyWith(total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 0)),
      LiquidityPoolDto.fixture().copyWith(total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 2000)),
    ];

    final yields = LiquidityPoolsSearchResultDto.fixture().copyWith(pools: pools);

    expect(yields.poolsSortedByTimeframe(PoolDataTimeframe.day), yields.poolsSortedBy24hYield);
  });

  test("when calling 'poolsSortedByTimeframe' passing YieldTimeFrame.week it should return poolsSortedBy7dYield", () {
    final pools = [
      LiquidityPoolDto.fixture().copyWith(total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 12681)),
      LiquidityPoolDto.fixture().copyWith(total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 111)),
      LiquidityPoolDto.fixture().copyWith(total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 0)),
      LiquidityPoolDto.fixture().copyWith(total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 21971972891)),
    ];

    final yields = LiquidityPoolsSearchResultDto.fixture().copyWith(pools: pools);

    expect(yields.poolsSortedByTimeframe(PoolDataTimeframe.week), yields.poolsSortedBy7dYield);
  });

  test("when calling 'poolsSortedByTimeframe' passing YieldTimeFrame.month it should return poolsSortedBy30dYield", () {
    final pools = [
      LiquidityPoolDto.fixture().copyWith(total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 089889888)),
      LiquidityPoolDto.fixture().copyWith(total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 2222)),
      LiquidityPoolDto.fixture().copyWith(total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 0)),
      LiquidityPoolDto.fixture().copyWith(total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 12615654)),
    ];

    final yields = LiquidityPoolsSearchResultDto.fixture().copyWith(pools: pools);

    expect(yields.poolsSortedByTimeframe(PoolDataTimeframe.month), yields.poolsSortedBy30dYield);
  });

  test(
    "when calling 'poolsSortedByTimeframe' passing YieldTimeFrame.threeMonth it should return poolsSortedBy90dYield",
    () {
      final pools = [
        LiquidityPoolDto.fixture().copyWith(total90dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 978888)),
        LiquidityPoolDto.fixture().copyWith(total90dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 121)),
        LiquidityPoolDto.fixture().copyWith(total90dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 0)),
        LiquidityPoolDto.fixture().copyWith(
          total90dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 329087902),
        ),
      ];

      final yields = LiquidityPoolsSearchResultDto.fixture().copyWith(pools: pools);

      expect(yields.poolsSortedByTimeframe(PoolDataTimeframe.threeMonth), yields.poolsSortedBy90dYield);
    },
  );
}
