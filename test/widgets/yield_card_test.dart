import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:zup_app/core/dtos/pool_stats_dto.dart';
import 'package:zup_app/core/dtos/protocol_dto.dart';
import 'package:zup_app/core/dtos/single_chain_token_dto.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/enums/pool_data_timeframe.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/widgets/yield_card.dart';
import 'package:zup_core/test_utils.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

import '../golden_config.dart';
import '../mocks.dart';

void main() {
  setUp(() {
    inject.registerLazySingleton<ZupNetworkImage>(() => mockZupNetworkImage());
    inject.registerFactory<bool>(() => false, instanceName: InjectInstanceNames.infinityAnimationAutoPlay);
  });

  tearDown(() => inject.reset());

  Future<DeviceBuilder> goldenBuilder({
    bool isHotestYield = true,
    YieldDto? yieldPool,
    PoolDataTimeframe? yieldTimeFrame,
    bool snapshotDarkMode = false,
    bool showYieldTimeframe = false,
    ZupIconButton? secondaryButton,
  }) async => await goldenDeviceBuilder(
    darkMode: snapshotDarkMode,
    Center(
      child: SizedBox(
        height: 315,
        width: 340,
        child: YieldCard(
          showTimeframe: showYieldTimeframe,
          showHotestYieldAnimation: false,
          yieldPool: yieldPool ?? YieldDto.fixture(),
          yieldTimeFrame: yieldTimeFrame ?? PoolDataTimeframe.day,
          secondaryButton: secondaryButton,
          mainButton: ZupPrimaryButton(title: "Main Action", onPressed: (buttonContext) {}, height: 45),
        ),
      ),
    ),
  );

  zGoldenTest(
    """When passing the yield timeframe as day,
    it should show the day yield from the passed yield pool""",
    goldenFileName: "yield_card_day_timeframe",
    (tester) async {
      final pool = YieldDto.fixture().copyWith(
        total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 12518721),
      );
      await tester.pumpDeviceBuilder(await goldenBuilder(yieldTimeFrame: PoolDataTimeframe.day, yieldPool: pool));
    },
  );

  zGoldenTest(
    """When passing the yield timeframe as week,
    it should show the week yield from the passed yield pool""",
    goldenFileName: "yield_card_week_timeframe",
    (tester) async {
      final pool = YieldDto.fixture().copyWith(
        total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 111122111),
      );
      await tester.pumpDeviceBuilder(await goldenBuilder(yieldTimeFrame: PoolDataTimeframe.week, yieldPool: pool));
    },
  );

  zGoldenTest(
    """When passing the yield timeframe as month,
    it should show the month yield from the passed yield pool""",
    goldenFileName: "yield_card_month_timeframe",
    (tester) async {
      final pool = YieldDto.fixture().copyWith(total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 991));
      await tester.pumpDeviceBuilder(await goldenBuilder(yieldTimeFrame: PoolDataTimeframe.month, yieldPool: pool));
    },
  );

  zGoldenTest(
    """When passing the yield timeframe as three months,
    it should show the three months yield from the passed yield pool""",
    goldenFileName: "yield_card_three_months_timeframe",
    (tester) async {
      final pool = YieldDto.fixture().copyWith(total90dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 654));
      await tester.pumpDeviceBuilder(
        await goldenBuilder(yieldTimeFrame: PoolDataTimeframe.threeMonth, yieldPool: pool),
      );
    },
  );

  zGoldenTest(
    "When the theme is in dark mode, the card should be in dark mode",
    goldenFileName: "yield_card_dark_mode",
    (tester) async {
      await tester.pumpDeviceBuilder(await goldenBuilder(snapshotDarkMode: true));
    },
  );

  zGoldenTest(
    """When the user hovers the blockchain icon, it should display a tooltip
    explaining that the pool is at n blockchain""",
    goldenFileName: "yield_card_blockchain_tooltip_hover",
    (tester) async {
      final yieldPool = YieldDto.fixture();
      await tester.pumpDeviceBuilder(await goldenBuilder(yieldPool: yieldPool));

      await tester.hover(find.byKey(Key("yield-card-network-${yieldPool.network.label}")));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When hovering the info icon after the yield percent, it should display a tooltip
    explaining the yield percent, and showing other timesframes yields""",
    goldenFileName: "yield_card_yield_tooltip_hover",
    (tester) async {
      final yieldPool = YieldDto.fixture().copyWith(
        total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 2919),
        total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 9824),
        total90dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 1111),
        total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 1212),
      );
      await tester.pumpDeviceBuilder(await goldenBuilder(yieldPool: yieldPool));

      await tester.hover(find.byKey(Key("yield-breakdown-tooltip-${yieldPool.poolAddress}")));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the device is mobile, and the user clicks the yield, it should display a tooltip
    explaining the yield percent, and showing other timesframes yields""",
    goldenFileName: "yield_card_yield_tap_mobile",
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      final yieldPool = YieldDto.fixture().copyWith(
        total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 2919),
        total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 9824),
        total90dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 1111),
        total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 1212),
      );
      await tester.pumpDeviceBuilder(await goldenBuilder(yieldPool: yieldPool));

      await tester.hover(find.byKey(Key("yield-card-yield-${yieldPool.poolAddress}")));
      await tester.pumpAndSettle();

      debugDefaultTargetPlatformOverride = null;
    },
  );

  zGoldenTest(
    "When the tvl decimals is greater than 2, the tvl should be compact",
    goldenFileName: "yield_card_compacte_tvl",
    (tester) async {
      final pool = YieldDto.fixture().copyWith(totalValueLockedUSD: 112152871.219201);
      await tester.pumpDeviceBuilder(await goldenBuilder(yieldPool: pool));
    },
  );

  zGoldenTest(
    "When the protocol name is too big, it add a overflow ellipsis",
    goldenFileName: "yield_card_overflow_protocol_name",
    (tester) async {
      final pool = YieldDto.fixture().copyWith(
        protocol: ProtocolDto.fixture().copyWith(name: "Lorem ipsum dolor sit amet consectetur adipiscing elit"),
      );
      await tester.pumpDeviceBuilder(await goldenBuilder(yieldPool: pool));
    },
  );

  zGoldenTest(
    "When the token symbol pass 8 chars, it should be overflowed with an ellipsis",
    goldenFileName: "yield_card_overflow_token_symbol",
    (tester) async {
      final pool = YieldDto.fixture().copyWith(
        token0: SingleChainTokenDto.fixture().copyWith(
          symbol: "Lorem ipsum dolor sit amet consectetur adipiscing elit",
        ),
        token1: SingleChainTokenDto.fixture().copyWith(
          symbol: "elit adipiscing consectetur amet sit dolor ipsum Lorem",
        ),
      );
      await tester.pumpDeviceBuilder(await goldenBuilder(yieldPool: pool));
    },
  );

  zGoldenTest(
    "When passing 'showYieldTimframe' true, it should show the timeframe of the yield in the card",
    goldenFileName: "yield_card_show_yield_timeframe",
    (tester) async {
      final pool = YieldDto.fixture().copyWith(total90dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 654));
      await tester.pumpDeviceBuilder(
        await goldenBuilder(yieldTimeFrame: PoolDataTimeframe.threeMonth, yieldPool: pool, showYieldTimeframe: true),
      );
    },
  );

  zGoldenTest(
    "When passing a secondary button, it should be displayed in the card",
    goldenFileName: "yield_card_secondary_button",
    (tester) async {
      await tester.pumpDeviceBuilder(
        await goldenBuilder(
          secondaryButton: ZupIconButton(icon: const Icon(Icons.place), onPressed: (_) {}),
        ),
      );
    },
  );
}
