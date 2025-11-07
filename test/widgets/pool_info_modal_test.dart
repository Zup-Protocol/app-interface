import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:web3kit/core/core.dart';
import 'package:zup_app/core/dtos/hook_dto.dart';
import 'package:zup_app/core/dtos/liquidity_pool_dto.dart';
import 'package:zup_app/core/dtos/pool_stats_dto.dart';
import 'package:zup_app/core/dtos/protocol_dto.dart';
import 'package:zup_app/core/dtos/single_chain_token_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/enums/pool_data_timeframe.dart';
import 'package:zup_app/core/enums/pool_type.dart';
import 'package:zup_app/core/extensions/num_extension.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/zup_navigator.dart';
import 'package:zup_app/widgets/pool_info_modal/pool_info_modal.dart';
import 'package:zup_core/test_utils.dart';
import 'package:zup_ui_kit/zup_network_image.dart';

import '../golden_config.dart';
import '../mocks.dart';

void main() {
  late ZupNavigator navigator;

  setUp(() {
    registerFallbackValue(LiquidityPoolDto.fixture());
    registerFallbackValue(PoolDataTimeframe.day);

    UrlLauncherPlatform.instance = UrlLauncherPlatformCustomMock();

    navigator = ZupNavigatorMock();

    inject.registerFactory<ZupNavigator>(() => navigator);
    inject.registerFactory<ZupNetworkImage>(() => mockZupNetworkImage());

    when(
      () => navigator.navigateToDeposit(
        parseWrappedToNative: any(named: "parseWrappedToNative"),
        selectedTimeframe: any(named: "selectedTimeframe"),
        yieldPool: any(named: "yieldPool"),
      ),
    ).thenAnswer((_) async {});
  });

  tearDown(() => inject.reset());

  Future<DeviceBuilder> goldenBuilder({
    LiquidityPoolDto? customPool,
    PoolDataTimeframe selectedTimeframe = PoolDataTimeframe.day,
    bool isMobile = false,
  }) async => await goldenDeviceBuilder(
    device: isMobile ? GoldenDevice.mobile : GoldenDevice.pc,
    Builder(
      builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          PoolInfoModal.show(
            context,
            liquidityPool: customPool ?? LiquidityPoolDto.fixture(),
            selectedTimeframe: selectedTimeframe,
            showAsBottomSheet: isMobile,
          );
        });

        return const SizedBox();
      },
    ),
  );

  zGoldenTest("When clicking the copy icon, it should copy the pool address to the clipboard", (tester) async {
    String? clipboardData;

    tester.onSetClipboard((clipboardText) => clipboardData = clipboardText);

    const poolAddress = "xabasMaPol";
    final pool = LiquidityPoolDto.fixture().copyWith(poolAddress: poolAddress);
    await tester.pumpDeviceBuilder(await goldenBuilder(customPool: pool), wrapper: GoldenConfig.localizationsWrapper());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("pool-info-modal-copy-pool-address")));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(clipboardData, poolAddress);
  });

  zGoldenTest(
    """When hovering the copy pool address button, it should show a tooltip
  explaning that the address will be copied on click""",
    goldenFileName: "pool_info_modal_copy_pool_address_tooltip",
    (tester) async {
      await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
      await tester.pumpAndSettle();

      await tester.hover(find.byKey(const Key("pool-info-modal-copy-pool-address")));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When pressing the copy pool address button, while hovering
    it should change the tooltip to "Copied!" and show a checkmark icon""",
    (tester) async {
      await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
      await tester.pumpAndSettle();

      await tester.hover(find.byKey(const Key("pool-info-modal-copy-pool-address")));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("pool-info-modal-copy-pool-address")));
      await tester.pumpAndSettle();

      await screenMatchesGolden(tester, "pool_info_modal_copy_pool_address_tooltip_copied");
      await tester.pumpAndSettle(const Duration(seconds: 10));
    },
  );

  zGoldenTest(
    """When clicking the add liquidity button, it should pop the modal, and navigate to deposit page
    passing the pool object and the selected timeframe""",
    goldenFileName: "pool_info_modal_add_liquidity_pop",
    (tester) async {
      const expectedTimeframe = PoolDataTimeframe.week;
      final expectedPool = LiquidityPoolDto.fixture().copyWith(poolAddress: "some random address");

      await tester.pumpDeviceBuilder(
        await goldenBuilder(customPool: expectedPool, selectedTimeframe: expectedTimeframe),
        wrapper: GoldenConfig.localizationsWrapper(),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("pool-info-modal-add-liquidity")));
      await tester.pumpAndSettle();

      verify(
        () => navigator.navigateToDeposit(
          parseWrappedToNative: any(named: "parseWrappedToNative"),
          selectedTimeframe: expectedTimeframe,
          yieldPool: expectedPool,
        ),
      ).called(1);
    },
  );

  zGoldenTest(
    """When clicking the add liquidity button with a pool that has the token 0 as native,
    it should pass to parseWrappedToNative true when navigating to the deposit page""",
    (tester) async {
      await tester.pumpDeviceBuilder(
        await goldenBuilder(
          customPool: LiquidityPoolDto.fixture().copyWith(
            token0: const SingleChainTokenDto(address: EthereumConstants.zeroAddress),
            token1: const SingleChainTokenDto(address: "0x123"),
          ),
        ),
        wrapper: GoldenConfig.localizationsWrapper(),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("pool-info-modal-add-liquidity")));
      await tester.pumpAndSettle();

      verify(
        () => navigator.navigateToDeposit(
          parseWrappedToNative: true,
          selectedTimeframe: any(named: "selectedTimeframe"),
          yieldPool: any(named: "yieldPool"),
        ),
      ).called(1);
    },
  );

  zGoldenTest(
    """When clicking the add liquidity button with a pool that has the token 1 as native,
    it should pass to parseWrappedToNative true when navigating to the deposit page""",
    (tester) async {
      await tester.pumpDeviceBuilder(
        await goldenBuilder(
          customPool: LiquidityPoolDto.fixture().copyWith(
            token0: const SingleChainTokenDto(address: "0x123"),
            token1: const SingleChainTokenDto(address: EthereumConstants.zeroAddress),
          ),
        ),
        wrapper: GoldenConfig.localizationsWrapper(),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("pool-info-modal-add-liquidity")));
      await tester.pumpAndSettle();

      verify(
        () => navigator.navigateToDeposit(
          parseWrappedToNative: true,
          selectedTimeframe: any(named: "selectedTimeframe"),
          yieldPool: any(named: "yieldPool"),
        ),
      ).called(1);
    },
  );

  zGoldenTest(
    """When clicking the add liquidity button with a pool that does not have the
    token 0 or 1 as native, it should pass to parseWrappedToNative false when
    navigating to the deposit page""",
    (tester) async {
      await tester.pumpDeviceBuilder(
        await goldenBuilder(
          customPool: LiquidityPoolDto.fixture().copyWith(
            token0: const SingleChainTokenDto(address: "0x123"),
            token1: const SingleChainTokenDto(address: "0x456"),
          ),
        ),
        wrapper: GoldenConfig.localizationsWrapper(),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("pool-info-modal-add-liquidity")));
      await tester.pumpAndSettle();

      verify(
        () => navigator.navigateToDeposit(
          parseWrappedToNative: false,
          selectedTimeframe: any(named: "selectedTimeframe"),
          yieldPool: any(named: "yieldPool"),
        ),
      ).called(1);
    },
  );

  group("Pool Stats Page Tests", () {
    final poolWithTimeframeStats = LiquidityPoolDto.fixture().copyWith(
      totalValueLockedUSD: 787878,
      total24hStats: const PoolTotalStatsDTO(
        totalFees: 242424,
        totalNetInflow: 240240240,
        totalVolume: 240024002400,
        yearlyYield: 240002400024000,
      ),
      total7dStats: const PoolTotalStatsDTO(
        totalFees: 777,
        totalNetInflow: 7777,
        totalVolume: 77777,
        yearlyYield: 777777,
      ),
      total30dStats: const PoolTotalStatsDTO(
        totalFees: 303030,
        totalNetInflow: 300300300,
        totalVolume: 300030003000,
        yearlyYield: 3000030003000,
      ),
      total90dStats: const PoolTotalStatsDTO(
        totalFees: 909090,
        totalNetInflow: 900900900,
        totalVolume: 900090009000,
        yearlyYield: 9000090009000,
      ),
    );

    zGoldenTest(
      """When passing the 24h timeframe, it should show the 24h stats
    when opening the modal""",
      goldenFileName: "pool_info_modal_24h_initial",
      (tester) async {
        const expectedTimeframe = PoolDataTimeframe.day;

        await tester.pumpDeviceBuilder(
          await goldenBuilder(customPool: poolWithTimeframeStats, selectedTimeframe: expectedTimeframe),
          wrapper: GoldenConfig.localizationsWrapper(),
        );

        await tester.pumpAndSettle();
      },
    );

    zGoldenTest(
      """When passing the 7d timeframe, it should show the 7d stats
    when opening the modal""",
      goldenFileName: "pool_info_modal_7d_initial",
      (tester) async {
        const expectedTimeframe = PoolDataTimeframe.week;

        await tester.pumpDeviceBuilder(
          await goldenBuilder(customPool: poolWithTimeframeStats, selectedTimeframe: expectedTimeframe),
          wrapper: GoldenConfig.localizationsWrapper(),
        );

        await tester.pumpAndSettle();
      },
    );

    zGoldenTest(
      """When passing the 30d timeframe, it should show the 30d stats
    when opening the modal""",
      goldenFileName: "pool_info_modal_30d_initial",
      (tester) async {
        const expectedTimeframe = PoolDataTimeframe.month;

        await tester.pumpDeviceBuilder(
          await goldenBuilder(customPool: poolWithTimeframeStats, selectedTimeframe: expectedTimeframe),
          wrapper: GoldenConfig.localizationsWrapper(),
        );

        await tester.pumpAndSettle();
      },
    );

    zGoldenTest(
      """When passing the 90d timeframe, it should show the 90d stats
    when opening the modal""",
      goldenFileName: "pool_info_modal_90d_initial",
      (tester) async {
        const expectedTimeframe = PoolDataTimeframe.threeMonth;

        await tester.pumpDeviceBuilder(
          await goldenBuilder(customPool: poolWithTimeframeStats, selectedTimeframe: expectedTimeframe),
          wrapper: GoldenConfig.localizationsWrapper(),
        );

        await tester.pumpAndSettle();
      },
    );

    zGoldenTest(
      "When starting with 24h timeframe, but the user clicks on the 7d timeframe, it should show the 7d stats",
      goldenFileName: "pool_info_modal_switch_to_7d",
      (tester) async {
        await tester.pumpDeviceBuilder(
          await goldenBuilder(customPool: poolWithTimeframeStats, selectedTimeframe: PoolDataTimeframe.day),
          wrapper: GoldenConfig.localizationsWrapper(),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(Key("${PoolDataTimeframe.week.name}-timeframe-button")));
        await tester.pumpAndSettle();
      },
    );

    zGoldenTest(
      "When starting with 24h timeframe, but the user clicks on the 30d timeframe, it should show the 30d stats",
      goldenFileName: "pool_info_modal_switch_to_30d",
      (tester) async {
        await tester.pumpDeviceBuilder(
          await goldenBuilder(customPool: poolWithTimeframeStats, selectedTimeframe: PoolDataTimeframe.day),
          wrapper: GoldenConfig.localizationsWrapper(),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(Key("${PoolDataTimeframe.month.name}-timeframe-button")));
        await tester.pumpAndSettle();
      },
    );

    zGoldenTest(
      "When starting with 24h timeframe, but the user clicks on the 90d timeframe, it should show the 90d stats",
      goldenFileName: "pool_info_modal_switch_to_90d",
      (tester) async {
        await tester.pumpDeviceBuilder(
          await goldenBuilder(customPool: poolWithTimeframeStats, selectedTimeframe: PoolDataTimeframe.day),
          wrapper: GoldenConfig.localizationsWrapper(),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(Key("${PoolDataTimeframe.threeMonth.name}-timeframe-button")));
        await tester.pumpAndSettle();
      },
    );

    zGoldenTest(
      "When starting with 7d timeframe, but the user clicks on the 24h timeframe, it should show the 24h stats",
      goldenFileName: "pool_info_modal_switch_to_24h",
      (tester) async {
        await tester.pumpDeviceBuilder(
          await goldenBuilder(customPool: poolWithTimeframeStats, selectedTimeframe: PoolDataTimeframe.week),
          wrapper: GoldenConfig.localizationsWrapper(),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(Key("${PoolDataTimeframe.day.name}-timeframe-button")));
        await tester.pumpAndSettle();
      },
    );

    zGoldenTest(
      "When hovering the tvl info icon, it should show a tooltip explaining the TVL and Timeframe",
      goldenFileName: "pool_info_modal_tvl_tooltip",
      (tester) async {
        await tester.pumpDeviceBuilder(
          await goldenBuilder(customPool: poolWithTimeframeStats),
          wrapper: GoldenConfig.localizationsWrapper(),
        );
        await tester.pumpAndSettle();

        await tester.hover(find.byKey(const Key("TVL-tooltip")));
        await tester.pumpAndSettle();
      },
    );

    zGoldenTest(
      "When the device size is mobile, and the user clicks the tvl value, it should show a tooltip explaining the TVL and Timeframe",
      goldenFileName: "pool_info_modal_tvl_tooltip_mobile",
      (tester) async {
        await tester.pumpDeviceBuilder(
          await goldenBuilder(customPool: poolWithTimeframeStats, isMobile: true),
          wrapper: GoldenConfig.localizationsWrapper(),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text(poolWithTimeframeStats.totalValueLockedUSD.formatCompactCurrency().toString()));
        await tester.pumpAndSettle();
      },
    );

    zGoldenTest(
      "When hovering the swap volume info icon, it should show a tooltip explaining the Swap Volume and Timeframe",
      goldenFileName: "pool_info_modal_swap_volume_tooltip",
      (tester) async {
        await tester.pumpDeviceBuilder(
          await goldenBuilder(customPool: poolWithTimeframeStats),
          wrapper: GoldenConfig.localizationsWrapper(),
        );
        await tester.pumpAndSettle();

        await tester.hover(find.byKey(const Key("24h Swap Volume-tooltip")));
        await tester.pumpAndSettle();
      },
    );

    zGoldenTest(
      "When the device size is mobile, and the user clicks the swap volume value, it should show a tooltip explaining it",
      goldenFileName: "pool_info_modal_swap_volume_tooltip_mobile",
      (tester) async {
        await tester.pumpDeviceBuilder(
          await goldenBuilder(customPool: poolWithTimeframeStats, isMobile: true),
          wrapper: GoldenConfig.localizationsWrapper(),
        );
        await tester.pumpAndSettle();

        await tester.tap(
          find.text(poolWithTimeframeStats.total24hStats!.totalVolume.formatCompactCurrency().toString()),
        );
        await tester.pumpAndSettle();
      },
    );

    zGoldenTest(
      "When hovering the fees info icon, it should show a tooltip explaining the Fees and Timeframe",
      goldenFileName: "pool_info_modal_fees_tooltip",
      (tester) async {
        await tester.pumpDeviceBuilder(
          await goldenBuilder(customPool: poolWithTimeframeStats),
          wrapper: GoldenConfig.localizationsWrapper(),
        );
        await tester.pumpAndSettle();

        await tester.hover(find.byKey(const Key("24h Fees-tooltip")));
        await tester.pumpAndSettle();
      },
    );

    zGoldenTest(
      "When the device size is mobile, and the user clicks the fees value, it should show a tooltip explaining it",
      goldenFileName: "pool_info_modal_fees_tooltip_mobile",
      (tester) async {
        await tester.pumpDeviceBuilder(
          await goldenBuilder(customPool: poolWithTimeframeStats, isMobile: true),
          wrapper: GoldenConfig.localizationsWrapper(),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text(poolWithTimeframeStats.total24hStats!.totalFees.formatCompactCurrency().toString()));
        await tester.pumpAndSettle();
      },
    );

    zGoldenTest(
      "When hovering the net inflow info icon, it should show a tooltip explaining it",
      goldenFileName: "pool_info_modal_net_inflow_tooltip",
      (tester) async {
        await tester.pumpDeviceBuilder(
          await goldenBuilder(customPool: poolWithTimeframeStats),
          wrapper: GoldenConfig.localizationsWrapper(),
        );
        await tester.pumpAndSettle();

        await tester.hover(find.byKey(const Key("24h Net Inflow-tooltip")));
        await tester.pumpAndSettle();
      },
    );

    zGoldenTest(
      "When the device size is mobile, and the user clicks the net inflow value, it should show a tooltip explaining it",
      goldenFileName: "pool_info_modal_net_inflow_tooltip_mobile",
      (tester) async {
        await tester.pumpDeviceBuilder(
          await goldenBuilder(customPool: poolWithTimeframeStats, isMobile: true),
          wrapper: GoldenConfig.localizationsWrapper(),
        );
        await tester.pumpAndSettle();

        await tester.tap(
          find.text(poolWithTimeframeStats.total24hStats!.totalNetInflow.formatCompactCurrency().toString()),
        );
        await tester.pumpAndSettle();
      },
    );

    zGoldenTest(
      "When hovering the yearly yield info icon, it should show a tooltip explaining it",
      goldenFileName: "pool_info_modal_yearly_yield_tooltip",
      (tester) async {
        await tester.pumpDeviceBuilder(
          await goldenBuilder(customPool: poolWithTimeframeStats),
          wrapper: GoldenConfig.localizationsWrapper(),
        );
        await tester.pumpAndSettle();

        await tester.hover(find.byKey(const Key("24h Yearly Yield-tooltip")));
        await tester.pumpAndSettle();
      },
    );

    zGoldenTest(
      "When the device size is mobile, and the user clicks the yearly yield value, it should show a tooltip explaining it",
      goldenFileName: "pool_info_modal_yearly_yield_tooltip_mobile",
      (tester) async {
        await tester.pumpDeviceBuilder(
          await goldenBuilder(customPool: poolWithTimeframeStats, isMobile: true),
          wrapper: GoldenConfig.localizationsWrapper(),
        );

        await tester.pumpAndSettle();

        await tester.drag(
          find.text(poolWithTimeframeStats.total24hStats!.totalFees.formatCompactCurrency().toString()),
          const Offset(0, -500),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text(poolWithTimeframeStats.total24hStats!.yearlyYield.formatRoundingPercent.toString()));
        await tester.pumpAndSettle();
      },
    );

    zGoldenTest(
      "When the net inflow value is negative, it should be red",
      goldenFileName: "pool_info_modal_negative_net_inflow",
      (tester) async {
        await tester.pumpDeviceBuilder(
          await goldenBuilder(
            customPool: poolWithTimeframeStats.copyWith(
              total24hStats: poolWithTimeframeStats.total24hStats!.copyWith(totalNetInflow: -12189),
            ),
          ),
          wrapper: GoldenConfig.localizationsWrapper(),
        );

        await tester.pumpAndSettle();
      },
    );

    zGoldenTest(
      "When the net inflow value is zero, it should be gray",
      goldenFileName: "pool_info_modal_neutral_net_inflow",
      (tester) async {
        await tester.pumpDeviceBuilder(
          await goldenBuilder(
            customPool: poolWithTimeframeStats.copyWith(
              total24hStats: poolWithTimeframeStats.total24hStats!.copyWith(totalNetInflow: 0),
            ),
          ),
          wrapper: GoldenConfig.localizationsWrapper(),
        );

        await tester.pumpAndSettle();
      },
    );
  });

  group("About pool page", () {
    final poolWithAbout = LiquidityPoolDto.fixture().copyWith(
      currentFeeTier: 1200,
      chainId: AppNetworks.base.chainId,
      poolType: PoolType.v3,
    );

    zGoldenTest(
      "When clicking the about tab bar, it should switch to the about page",
      goldenFileName: "pool_info_modal_about_tab_switch",
      (tester) async {
        await tester.pumpDeviceBuilder(
          await goldenBuilder(customPool: poolWithAbout),
          wrapper: GoldenConfig.localizationsWrapper(),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("about-tab")));
        await tester.pumpAndSettle();
      },
    );

    zGoldenTest(
      "When hovering the info icon in the fee, it should show a tooltip explaining the fee tier",
      goldenFileName: "pool_info_modal_about_tab_fee_tier_tooltip",
      (tester) async {
        await tester.pumpDeviceBuilder(
          await goldenBuilder(customPool: poolWithAbout),
          wrapper: GoldenConfig.localizationsWrapper(),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("about-tab")));
        await tester.pumpAndSettle();

        await tester.hover(find.byKey(const Key("fee-tooltip")));
        await tester.pumpAndSettle();
      },
    );

    zGoldenTest(
      "When clicking the fee tier value, and the device size is mobile, it should show a tooltip explaining the fee tier",
      goldenFileName: "pool_info_modal_about_tab_fee_tier_tooltip_mobile",
      (tester) async {
        await tester.pumpDeviceBuilder(
          await goldenBuilder(customPool: poolWithAbout, isMobile: true),
          wrapper: GoldenConfig.localizationsWrapper(),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("about-tab")));
        await tester.pumpAndSettle();

        await tester.tap(find.text(poolWithAbout.currentFeeTierFormatted));
        await tester.pumpAndSettle();
      },
    );

    zGoldenTest(
      """When the pool hook is dynamic fee, it should show dynamic in the fee tier field
      and in the tooltip""",
      goldenFileName: "pool_info_modal_dynamic_fee",
      (tester) async {
        await tester.pumpDeviceBuilder(
          await goldenBuilder(customPool: poolWithAbout.copyWith(hook: HookDto.fixture().copyWith(isDynamicFee: true))),
          wrapper: GoldenConfig.localizationsWrapper(),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("about-tab")));
        await tester.pumpAndSettle();

        await tester.hover(find.byKey(const Key("fee-tooltip")));
        await tester.pumpAndSettle();
      },
    );

    zGoldenTest(
      """When hovering the info icon in the pool type, and the pool type is v3,
      it should show a tooltip explaining the v3 pool type""",
      goldenFileName: "pool_info_modal_about_tab_v3_pool_type_tooltip",
      (tester) async {
        await tester.pumpDeviceBuilder(
          await goldenBuilder(customPool: poolWithAbout.copyWith(poolType: PoolType.v3)),
          wrapper: GoldenConfig.localizationsWrapper(),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("about-tab")));
        await tester.pumpAndSettle();

        await tester.hover(find.byKey(const Key("pool-type-tooltip")));
        await tester.pumpAndSettle();
      },
    );

    zGoldenTest(
      """When hovering the info icon in the pool type, and the pool type is v4,
      it should show a tooltip explaining the v4 pool type""",
      goldenFileName: "pool_info_modal_about_tab_v4_pool_type_tooltip",
      (tester) async {
        await tester.pumpDeviceBuilder(
          await goldenBuilder(customPool: poolWithAbout.copyWith(poolType: PoolType.v4)),
          wrapper: GoldenConfig.localizationsWrapper(),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("about-tab")));
        await tester.pumpAndSettle();

        await tester.hover(find.byKey(const Key("pool-type-tooltip")));
        await tester.pumpAndSettle();
      },
    );

    zGoldenTest(
      "When clicking the pool type value, and the device size is mobile, it should show a tooltip explaining the pool type",
      goldenFileName: "pool_info_modal_about_tab_pool_type_tooltip_mobile",
      (tester) async {
        await tester.pumpDeviceBuilder(
          await goldenBuilder(customPool: poolWithAbout.copyWith(poolType: PoolType.v3), isMobile: true),
          wrapper: GoldenConfig.localizationsWrapper(),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("about-tab")));
        await tester.pumpAndSettle();

        await tester.tap(find.text("V3 Pool"));
        await tester.pumpAndSettle();
      },
    );

    zGoldenTest(
      """When the pool is v4, and hover the info icon in the hooks field,
      it should show a tooltip explaining hooks""",
      goldenFileName: "pool_info_modal_about_tab_v4_hooks_tooltip",
      (tester) async {
        await tester.pumpDeviceBuilder(
          await goldenBuilder(customPool: poolWithAbout.copyWith(poolType: PoolType.v4)),
          wrapper: GoldenConfig.localizationsWrapper(),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("about-tab")));
        await tester.pumpAndSettle();

        await tester.hover(find.byKey(const Key("hooks-tooltip")));
        await tester.pumpAndSettle();
      },
    );

    zGoldenTest(
      "When clicking the hooks value, and the device size is mobile, it should show a tooltip explaining hooks",
      goldenFileName: "pool_info_modal_about_tab_hooks_tooltip_mobile",
      (tester) async {
        await tester.pumpDeviceBuilder(
          await goldenBuilder(customPool: poolWithAbout.copyWith(poolType: PoolType.v4), isMobile: true),
          wrapper: GoldenConfig.localizationsWrapper(),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("about-tab")));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Hooks"));
        await tester.pumpAndSettle();
      },
    );

    zGoldenTest(
      "When the pool is v4, and the hooks are not null, it should show the hooks address shortened",
      goldenFileName: "pool_info_modal_about_tab_v4_hooks_address",
      (tester) async {
        await tester.pumpDeviceBuilder(
          await goldenBuilder(
            customPool: poolWithAbout.copyWith(
              poolType: PoolType.v4,
              hook: const HookDto(address: "0x1234567891011", isDynamicFee: false),
            ),
          ),
          wrapper: GoldenConfig.localizationsWrapper(),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("about-tab")));
        await tester.pumpAndSettle();
      },
    );

    zGoldenTest(
      """When the pool is v4, the hooks are not null, and the user hover the copy button,
      it should show a tooltip explaining the copy button""",
      goldenFileName: "pool_info_modal_about_tab_v4_hooks_copy_tooltip",
      (tester) async {
        await tester.pumpDeviceBuilder(
          await goldenBuilder(
            customPool: poolWithAbout.copyWith(
              poolType: PoolType.v4,
              hook: const HookDto(address: "0x1234567891011", isDynamicFee: false),
            ),
          ),
          wrapper: GoldenConfig.localizationsWrapper(),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("about-tab")));
        await tester.pumpAndSettle();

        await tester.hover(find.byKey(const Key("copy-hook-button")));
        await tester.pumpAndSettle();
      },
    );

    zGoldenTest(
      """When the pool is v4, the hooks are not null, and the user hover the copy button,
      then click, it should show a tooltip that the address was copied""",
      (tester) async {
        await tester.pumpDeviceBuilder(
          await goldenBuilder(
            customPool: poolWithAbout.copyWith(
              poolType: PoolType.v4,
              hook: const HookDto(address: "0x1234567891011", isDynamicFee: false),
            ),
          ),
          wrapper: GoldenConfig.localizationsWrapper(),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("about-tab")));
        await tester.pumpAndSettle();

        await tester.hover(find.byKey(const Key("copy-hook-button")));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("copy-hook-button")));
        await tester.pumpAndSettle();

        await screenMatchesGolden(tester, "pool_info_modal_about_tab_v4_hooks_copied_tooltip");
        await tester.pumpAndSettle(const Duration(seconds: 10));
      },
    );

    zGoldenTest(
      """When the pool is v4, the hooks are not null, and the user click the copy
      hook address button, it should copy the hook address to clipboard""",
      (tester) async {
        String? copiedAdddress;
        const hooksAddress = "0x ma Hook aaaddrresss";

        tester.onSetClipboard((clipboard) => copiedAdddress = clipboard);

        await tester.pumpDeviceBuilder(
          await goldenBuilder(
            customPool: poolWithAbout.copyWith(
              poolType: PoolType.v4,
              hook: const HookDto(address: hooksAddress, isDynamicFee: false),
            ),
          ),
          wrapper: GoldenConfig.localizationsWrapper(),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("about-tab")));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("copy-hook-button")));
        await tester.pumpAndSettle(const Duration(seconds: 5));

        expect(copiedAdddress, hooksAddress);
      },
    );

    zGoldenTest(
      """When the token 0 is native, the button to navigate to the token address
      and the copy button should be hidden, and it should only show the symbol / image""",
      goldenFileName: "pool_info_modal_about_tab_token_0_native",
      (tester) async {
        await tester.pumpDeviceBuilder(
          await goldenBuilder(
            customPool: poolWithAbout.copyWith(
              token0: SingleChainTokenDto.fixture().copyWith(address: EthereumConstants.zeroAddress, symbol: "ETH"),
            ),
          ),
          wrapper: GoldenConfig.localizationsWrapper(),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("about-tab")));
        await tester.pumpAndSettle();
      },
    );

    zGoldenTest(
      """When the token 0 is not native, and clicking the token button,
      it should launch the network explorer at the token address""",
      (tester) async {
        await tester.pumpDeviceBuilder(
          await goldenBuilder(customPool: poolWithAbout),
          wrapper: GoldenConfig.localizationsWrapper(),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("about-tab")));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(Key("${poolWithAbout.token0.address}-button")));
        await tester.pumpAndSettle();

        expect(
          UrlLauncherPlatformCustomMock.lastLaunchedUrl,
          "${poolWithAbout.network.chainInfo.blockExplorerUrls?.first}/address/${poolWithAbout.token0.address}",
        );
      },
    );

    zGoldenTest(
      """When the token 0 is not native, and hovering the copy token address button
      it should show a tooltip explaining the copy button""",
      goldenFileName: "pool_info_modal_about_tab_token_0_copy_tooltip",
      (tester) async {
        await tester.pumpDeviceBuilder(
          await goldenBuilder(customPool: poolWithAbout),
          wrapper: GoldenConfig.localizationsWrapper(),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("about-tab")));
        await tester.pumpAndSettle();

        await tester.hover(find.byKey(Key("${poolWithAbout.token0.address}-copy-button")));
        await tester.pumpAndSettle();
      },
    );

    zGoldenTest(
      """When the token 1 is not native, and hovering the copy token address button
      it should show a tooltip explaining the copy button""",
      goldenFileName: "pool_info_modal_about_tab_token_1_copy_tooltip",
      (tester) async {
        await tester.pumpDeviceBuilder(
          await goldenBuilder(customPool: poolWithAbout),
          wrapper: GoldenConfig.localizationsWrapper(),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("about-tab")));
        await tester.pumpAndSettle();

        await tester.hover(find.byKey(Key("${poolWithAbout.token1.address}-copy-button")));
        await tester.pumpAndSettle();
      },
    );

    zGoldenTest(
      """When the token 0 is not native, and hovering the copy token address button
      then clicking it, it should show a tooltip saying the address was copied""",
      (tester) async {
        await tester.pumpDeviceBuilder(
          await goldenBuilder(customPool: poolWithAbout),
          wrapper: GoldenConfig.localizationsWrapper(),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("about-tab")));
        await tester.pumpAndSettle();

        await tester.hover(find.byKey(Key("${poolWithAbout.token0.address}-copy-button")));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(Key("${poolWithAbout.token0.address}-copy-button")));
        await tester.pumpAndSettle();

        await screenMatchesGolden(tester, "pool_info_modal_about_tab_token_0_copied_tooltip");
        await tester.pumpAndSettle(const Duration(seconds: 10));
      },
    );

    zGoldenTest(
      """When the token 1 is not native, and hovering the copy token address button
      then clicking it, it should show a tooltip saying the address was copied""",
      (tester) async {
        await tester.pumpDeviceBuilder(
          await goldenBuilder(customPool: poolWithAbout),
          wrapper: GoldenConfig.localizationsWrapper(),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("about-tab")));
        await tester.pumpAndSettle();

        await tester.hover(find.byKey(Key("${poolWithAbout.token1.address}-copy-button")));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(Key("${poolWithAbout.token1.address}-copy-button")));
        await tester.pumpAndSettle();

        await screenMatchesGolden(tester, "pool_info_modal_about_tab_token_1_copied_tooltip");
        await tester.pumpAndSettle(const Duration(seconds: 10));
      },
    );

    zGoldenTest("When clicking the token 0 copy button, it should copy the token0 address to clipboard", (
      tester,
    ) async {
      String? clipboardAddress;

      await tester.pumpDeviceBuilder(
        await goldenBuilder(customPool: poolWithAbout),
        wrapper: GoldenConfig.localizationsWrapper(),
      );

      tester.onSetClipboard((clipboardText) => clipboardAddress = clipboardText);

      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("about-tab")));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key("${poolWithAbout.token0.address}-copy-button")));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(clipboardAddress, poolWithAbout.token0.address);
    });

    zGoldenTest("When clicking the token 1 copy button, it should copy the token1 address to clipboard", (
      tester,
    ) async {
      String? clipboardAddress;

      await tester.pumpDeviceBuilder(
        await goldenBuilder(customPool: poolWithAbout),
        wrapper: GoldenConfig.localizationsWrapper(),
      );

      tester.onSetClipboard((clipboardText) => clipboardAddress = clipboardText);

      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("about-tab")));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key("${poolWithAbout.token1.address}-copy-button")));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(clipboardAddress, poolWithAbout.token1.address);
    });

    zGoldenTest(
      """When the token 1 is not native, and clicking the token button,
      it should launch the network explorer at the token address""",
      (tester) async {
        await tester.pumpDeviceBuilder(
          await goldenBuilder(customPool: poolWithAbout),
          wrapper: GoldenConfig.localizationsWrapper(),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("about-tab")));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(Key("${poolWithAbout.token1.address}-button")));
        await tester.pumpAndSettle();

        expect(
          UrlLauncherPlatformCustomMock.lastLaunchedUrl,
          "${poolWithAbout.network.chainInfo.blockExplorerUrls?.first}/address/${poolWithAbout.token1.address}",
        );
      },
    );

    zGoldenTest(
      """When the token 1 is native, the button to navigate to the token address
      and the copy button should be hidden, and it should only show the symbol / image""",
      goldenFileName: "pool_info_modal_about_tab_token_1_native",
      (tester) async {
        await tester.pumpDeviceBuilder(
          await goldenBuilder(
            customPool: poolWithAbout.copyWith(
              token1: SingleChainTokenDto.fixture().copyWith(address: EthereumConstants.zeroAddress, symbol: "ETH"),
            ),
          ),
          wrapper: GoldenConfig.localizationsWrapper(),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("about-tab")));
        await tester.pumpAndSettle();
      },
    );

    zGoldenTest("When clicking the protocol button, it should launch the protocol website", (tester) async {
      const protocolWebsite = "maProtocolWebsite";

      await tester.pumpDeviceBuilder(
        await goldenBuilder(
          customPool: poolWithAbout.copyWith(protocol: ProtocolDto.fixture().copyWith(url: protocolWebsite)),
        ),
        wrapper: GoldenConfig.localizationsWrapper(),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("about-tab")));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("protocol-button")));
      await tester.pumpAndSettle();

      expect(UrlLauncherPlatformCustomMock.lastLaunchedUrl, protocolWebsite);
    });

    zGoldenTest("When clicking the network button, it should launch the network website", (tester) async {
      await tester.pumpDeviceBuilder(
        await goldenBuilder(customPool: poolWithAbout),
        wrapper: GoldenConfig.localizationsWrapper(),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("about-tab")));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("network-button")));
      await tester.pumpAndSettle();

      expect(UrlLauncherPlatformCustomMock.lastLaunchedUrl, poolWithAbout.network.websiteUrl);
    });
  });
}
