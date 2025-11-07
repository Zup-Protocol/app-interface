import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:lottie/lottie.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web3kit/core/ethereum_constants.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/app/create/yields/yields_cubit.dart';
import 'package:zup_app/app/create/yields/yields_page.dart';
import 'package:zup_app/core/cache.dart';
import 'package:zup_app/core/dtos/liquidity_pool_dto.dart';
import 'package:zup_app/core/dtos/liquidity_pools_search_result_dto.dart';
import 'package:zup_app/core/dtos/pool_search_filters_dto.dart';
import 'package:zup_app/core/dtos/pool_search_settings_dto.dart';
import 'package:zup_app/core/dtos/pool_stats_dto.dart';
import 'package:zup_app/core/dtos/single_chain_token_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/enums/pool_data_timeframe.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/zup_navigator.dart';
import 'package:zup_app/core/zup_route_params_names.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/widgets/yield_card.dart';
import 'package:zup_core/test_utils.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

import '../../../golden_config.dart';
import '../../../mocks.dart';

void main() {
  late YieldsCubit cubit;
  late ZupNavigator navigator;
  late AppCubit appCubit;
  late Cache appCache;

  setUp(() {
    registerFallbackValue(LiquidityPoolDto.fixture());
    registerFallbackValue(PoolDataTimeframe.day);

    navigator = ZupNavigatorMock();
    cubit = YieldsCubitMock();
    appCache = CacheMock();
    appCubit = AppCubitMock();

    inject.registerFactory<ZupNavigator>(() => navigator);
    inject.registerFactory<Cache>(() => appCache);
    inject.registerFactory<AppCubit>(() => appCubit);

    inject.registerFactory<LottieBuilder>(
      () => Assets.lotties.empty.lottie(animate: false),
      instanceName: InjectInstanceNames.lottieEmpty,
    );

    inject.registerFactory<LottieBuilder>(
      () => Assets.lotties.radar.lottie(animate: false),
      instanceName: InjectInstanceNames.lottieRadar,
    );

    inject.registerFactory<LottieBuilder>(
      () => Assets.lotties.numbers.lottie(animate: false),
      instanceName: InjectInstanceNames.lottieNumbers,
    );

    inject.registerFactory<LottieBuilder>(
      () => Assets.lotties.matching.lottie(animate: false),
      instanceName: InjectInstanceNames.lottieMatching,
    );

    inject.registerFactory<LottieBuilder>(
      () => Assets.lotties.list.lottie(animate: false),
      instanceName: InjectInstanceNames.lottieList,
    );

    inject.registerFactory<ScrollController>(
      () => GoldenConfig.scrollController,
      instanceName: InjectInstanceNames.appScrollController,
    );

    inject.registerFactory<ZupNetworkImage>(() => mockZupNetworkImage());

    inject.registerFactory<bool>(() => false, instanceName: InjectInstanceNames.infinityAnimationAutoPlay);

    when(() => navigator.navigateToNewPosition()).thenAnswer((_) => Future.value());
    when(() => appCache.getPoolSearchSettings()).thenReturn(PoolSearchSettingsDto(minLiquidityUSD: 122));
    when(() => appCubit.selectedNetwork).thenAnswer((_) => AppNetworks.sepolia);
    when(() => cubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => cubit.state).thenReturn(const YieldsState.initial());
    when(
      () => cubit.fetchYields(
        token0AddressOrId: any(named: "token0AddressOrId"),
        token1AddressOrId: any(named: "token1AddressOrId"),
        group0Id: any(named: "group0Id"),
        group1Id: any(named: "group1Id"),
        ignoreMinLiquidity: any(named: "ignoreMinLiquidity"),
      ),
    ).thenAnswer((_) => Future.value());
  });

  tearDown(() => inject.reset());

  Future<DeviceBuilder> goldenBuilder({bool isMobile = false}) async {
    return await goldenDeviceBuilder(
      BlocProvider.value(value: cubit, child: const YieldsPage()),
      device: isMobile ? GoldenDevice.mobile : GoldenDevice.pc,
    );
  }

  zGoldenTest(
    """When initializing the page, it should call the app cubit
    to set the app network for the one defined in the url params""",
    (tester) async {
      when(() => navigator.getQueryParam(YieldsRouteParamsNames().network)).thenReturn(AppNetworks.base.name);

      await tester.runAsync(() async {
        await tester.pumpDeviceBuilder(await goldenBuilder());
        await tester.pumpAndSettle();
      });

      verify(() => appCubit.updateAppNetwork(AppNetworks.base)).called(1);
    },
  );

  zGoldenTest(
    """When initializing the page, it should call the yields cubit
    to get the yields for the token0, token1 and group0, group1 defined
    in the url params""",
    (tester) async {
      const token0Id = "Xabas1";
      const token1Id = "Xabas2";
      const group0Id = "121";
      const group1Id = "gta1";

      when(() => navigator.getQueryParam(YieldsRouteParamsNames().token0)).thenReturn(token0Id);
      when(() => navigator.getQueryParam(YieldsRouteParamsNames().token1)).thenReturn(token1Id);
      when(() => navigator.getQueryParam(YieldsRouteParamsNames().group0)).thenReturn(group0Id);
      when(() => navigator.getQueryParam(YieldsRouteParamsNames().group1)).thenReturn(group1Id);

      await tester.runAsync(() async {
        await tester.pumpDeviceBuilder(await goldenBuilder());
        await tester.pumpAndSettle();
      });

      verify(
        () => cubit.fetchYields(
          token0AddressOrId: token0Id,
          token1AddressOrId: token1Id,
          group0Id: group0Id,
          group1Id: group1Id,
          ignoreMinLiquidity: false,
        ),
      ).called(1);
    },
  );

  zGoldenTest(
    "When the cubit state is error, it should show the error state",
    goldenFileName: "yields_page_error_state",
    (tester) async {
      when(() => cubit.state).thenReturn(const YieldsState.error("", ""));

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the user clicks the helper button in the error state,
    it try to fetch yields again, using the params from the url""",
    (tester) async {
      const token0Id = "toko-11";
      const token1Id = "toko-12";
      const group0Id = "gorpo-1";
      const group1Id = "gorpo-2";

      when(() => navigator.getQueryParam(YieldsRouteParamsNames().token0)).thenReturn(token0Id);
      when(() => navigator.getQueryParam(YieldsRouteParamsNames().token1)).thenReturn(token1Id);
      when(() => navigator.getQueryParam(YieldsRouteParamsNames().group0)).thenReturn(group0Id);
      when(() => navigator.getQueryParam(YieldsRouteParamsNames().group1)).thenReturn(group1Id);

      when(() => cubit.state).thenReturn(const YieldsState.error("", ""));

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("help-button")));
      await tester.pumpAndSettle();

      verify(
        () => cubit.fetchYields(
          token0AddressOrId: token0Id,
          token1AddressOrId: token1Id,
          group0Id: group0Id,
          group1Id: group1Id,
          ignoreMinLiquidity: false,
        ),
      ).called(
        2,
      ); // the first call is when the page is initialized and the second is when the user clicks the help button
    },
  );

  zGoldenTest(
    "When the cubit state is no yields, it should show the no yields state",
    goldenFileName: "yields_page_no_yields_state",
    (tester) async {
      when(
        () => cubit.state,
      ).thenReturn(const YieldsState.noYields(filtersApplied: PoolSearchFiltersDto(minTvlUsd: 0)));

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the state is no yields, and the minTvlUSD in the filters is greater than 0,
    it should an alert that says the min tvl usd is set""",
    goldenFileName: "yields_page_no_yields_state_min_tvl_set",
    (tester) async {
      when(
        () => cubit.state,
      ).thenReturn(const YieldsState.noYields(filtersApplied: PoolSearchFiltersDto(minTvlUsd: 12517821)));

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When clicking to search all pools in the min tvl usd alert at the no yields state,
    it should call the cubit to get yields again with the same params from the url,
    but setting true to ignore min liquidity""",
    (tester) async {
      const token0Id = "tok-21";
      const token1Id = "tok-98";
      const group0Id = "gpo-44";
      const group1Id = "gorpo-75";

      when(() => navigator.getQueryParam(YieldsRouteParamsNames().token0)).thenReturn(token0Id);
      when(() => navigator.getQueryParam(YieldsRouteParamsNames().token1)).thenReturn(token1Id);
      when(() => navigator.getQueryParam(YieldsRouteParamsNames().group0)).thenReturn(group0Id);
      when(() => navigator.getQueryParam(YieldsRouteParamsNames().group1)).thenReturn(group1Id);
      when(
        () => cubit.state,
      ).thenReturn(const YieldsState.noYields(filtersApplied: PoolSearchFiltersDto(minTvlUsd: 12517821)));

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("zup-inline-action-button-button")));
      await tester.pumpAndSettle();

      verify(
        () => cubit.fetchYields(
          token0AddressOrId: token0Id,
          token1AddressOrId: token1Id,
          group0Id: group0Id,
          group1Id: group1Id,
          ignoreMinLiquidity: true,
        ),
      ).called(1);
    },
  );

  zGoldenTest(
    """When clicking the helper button in the no yields state, it should try to navigate back
    to new position page""",
    (tester) async {
      when(() => cubit.state).thenReturn(YieldsState.noYields(filtersApplied: PoolSearchFiltersDto.fixture()));

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("help-button")));
      await tester.pumpAndSettle();

      verify(() => navigator.navigateToNewPosition()).called(1);
    },
  );

  zGoldenTest(
    """When the cubit state is success, and the yields page is the first one,
  the button to move to previous page (left button) should be disabled""",
    goldenFileName: "yields_page_success_first_page_left_button_disabled",
    (tester) async {
      when(() => cubit.state).thenReturn(
        YieldsState.success(
          LiquidityPoolsSearchResultDto.fixture().copyWith(
            pools: [
              LiquidityPoolDto.fixture(),
              LiquidityPoolDto.fixture(),
              LiquidityPoolDto.fixture(),
              LiquidityPoolDto.fixture(),
              LiquidityPoolDto.fixture(),
            ],
          ),
        ),
      );

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the page is the second one, the button to move to previous page (left button) should be enabled""",
    goldenFileName: "yields_page_success_second_page_left_button_enabled",
    (tester) async {
      when(() => cubit.state).thenReturn(
        YieldsState.success(
          LiquidityPoolsSearchResultDto.fixture().copyWith(
            pools: [
              LiquidityPoolDto.fixture().copyWith(
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 100),
              ),
              LiquidityPoolDto.fixture().copyWith(
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 200),
              ),
              LiquidityPoolDto.fixture().copyWith(
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 300),
              ),
              LiquidityPoolDto.fixture().copyWith(
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 400),
              ),
              LiquidityPoolDto.fixture().copyWith(
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 500),
              ),
            ],
          ),
        ),
      );

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("move-to-next-yields-page-button")));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the page is the second one, and clicking the button to move to previous page (left button)
    it should move to the first page again""",
    goldenFileName: "yields_page_success_first_page_coming_back",
    (tester) async {
      when(() => cubit.state).thenReturn(
        YieldsState.success(
          LiquidityPoolsSearchResultDto.fixture().copyWith(
            pools: [
              LiquidityPoolDto.fixture().copyWith(
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 100),
              ),
              LiquidityPoolDto.fixture().copyWith(
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 200),
              ),
              LiquidityPoolDto.fixture().copyWith(
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 300),
              ),
              LiquidityPoolDto.fixture().copyWith(
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 400),
              ),
              LiquidityPoolDto.fixture().copyWith(
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 500),
              ),
            ],
          ),
        ),
      );

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("move-to-next-yields-page-button")));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("move-to-previous-yields-page-button")));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the device has mobile size, the success state should be rendered with only one
    yield per page, without the pagination buttons""",
    goldenFileName: "yields_page_success_mobile",
    (tester) async {
      when(() => cubit.state).thenReturn(
        YieldsState.success(
          LiquidityPoolsSearchResultDto.fixture().copyWith(
            pools: [
              LiquidityPoolDto.fixture().copyWith(
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 100),
              ),
              LiquidityPoolDto.fixture().copyWith(
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 200),
              ),
              LiquidityPoolDto.fixture().copyWith(
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 300),
              ),
              LiquidityPoolDto.fixture().copyWith(
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 400),
              ),
              LiquidityPoolDto.fixture().copyWith(
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 500),
              ),
            ],
          ),
        ),
      );

      await tester.pumpDeviceBuilder(await goldenBuilder(isMobile: true));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When clicking the back button, to navigate back to select tokens,
  it should call the navigator to navigate to new position screen""",
    (tester) async {
      when(() => cubit.state).thenReturn(
        YieldsState.success(
          LiquidityPoolsSearchResultDto.fixture().copyWith(
            pools: [
              LiquidityPoolDto.fixture(),
              LiquidityPoolDto.fixture(),
              LiquidityPoolDto.fixture(),
              LiquidityPoolDto.fixture(),
              LiquidityPoolDto.fixture(),
            ],
          ),
        ),
      );

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("back-button")));
      await tester.pumpAndSettle();

      verify(() => navigator.navigateToNewPosition()).called(1);
    },
  );

  zGoldenTest(
    """When clicking the 7d button in the timeframe selector, in the success state,
    it should sort the yields by 7d yield (Z-A)""",
    goldenFileName: "yields_page_success_sorted_by_7d",
    (tester) async {
      when(() => cubit.state).thenReturn(
        YieldsState.success(
          LiquidityPoolsSearchResultDto.fixture().copyWith(
            pools: [
              LiquidityPoolDto.fixture().copyWith(
                total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 1000),
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 1),
              ),
              LiquidityPoolDto.fixture().copyWith(
                total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 2000),
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 10),
              ),
              LiquidityPoolDto.fixture().copyWith(
                total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 3000),
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 100),
              ),
              LiquidityPoolDto.fixture().copyWith(
                total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 4000),
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 1000),
              ),
              LiquidityPoolDto.fixture().copyWith(
                total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 5000),
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 1000),
              ),
            ],
          ),
        ),
      );

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key("${PoolDataTimeframe.week.name}-timeframe-button")));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When clicking the 30d button in the timeframe selector, in the success state,
    it should sort the yields by 30d yield (Z-A)""",
    goldenFileName: "yields_page_success_sorted_by_30d",
    (tester) async {
      when(() => cubit.state).thenReturn(
        YieldsState.success(
          LiquidityPoolsSearchResultDto.fixture().copyWith(
            pools: [
              LiquidityPoolDto.fixture().copyWith(
                total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 1000),
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 1),
                total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 2000),
              ),
              LiquidityPoolDto.fixture().copyWith(
                total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 2000),
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 10),
                total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 4000),
              ),
              LiquidityPoolDto.fixture().copyWith(
                total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 3000),
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 100),
                total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 6000),
              ),
              LiquidityPoolDto.fixture().copyWith(
                total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 4000),
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 1000),
                total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 8000),
              ),
              LiquidityPoolDto.fixture().copyWith(
                total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 5000),
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 1000),
                total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 10000),
              ),
            ],
          ),
        ),
      );

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key("${PoolDataTimeframe.month.name}-timeframe-button")));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When clicking the 90d button in the timeframe selector, in the success state,
    it should sort the yields by 90d yield (Z-A)""",
    goldenFileName: "yields_page_success_sorted_by_90d",
    (tester) async {
      when(() => cubit.state).thenReturn(
        YieldsState.success(
          LiquidityPoolsSearchResultDto.fixture().copyWith(
            pools: [
              LiquidityPoolDto.fixture().copyWith(
                total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 1000),
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 1),
                total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 2000),
                total90dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 4000),
              ),
              LiquidityPoolDto.fixture().copyWith(
                total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 2000),
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 10),
                total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 4000),
                total90dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 8000),
              ),
              LiquidityPoolDto.fixture().copyWith(
                total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 3000),
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 100),
                total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 6000),
                total90dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 12000),
              ),
              LiquidityPoolDto.fixture().copyWith(
                total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 4000),
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 1000),
                total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 8000),
                total90dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 16000),
              ),
              LiquidityPoolDto.fixture().copyWith(
                total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 5000),
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 1000),
                total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 10000),
                total90dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 20000),
              ),
            ],
          ),
        ),
      );

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key("${PoolDataTimeframe.threeMonth.name}-timeframe-button")));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the user move a page forward in the yields page, and then select another timeframe,
    it should sort the yields by the selected timeframe (Z-A) and reset the page to the first page""",
    goldenFileName: "yields_page_success_sorted_reset_page",
    (tester) async {
      when(() => cubit.state).thenReturn(
        YieldsState.success(
          LiquidityPoolsSearchResultDto.fixture().copyWith(
            pools: [
              LiquidityPoolDto.fixture().copyWith(
                total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 1000),
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 1),
                total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 2000),
                total90dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 4000),
              ),
              LiquidityPoolDto.fixture().copyWith(
                total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 2000),
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 10),
                total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 4000),
                total90dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 8000),
              ),
              LiquidityPoolDto.fixture().copyWith(
                total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 3000),
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 100),
                total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 6000),
                total90dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 12000),
              ),
              LiquidityPoolDto.fixture().copyWith(
                total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 4000),
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 1000),
                total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 8000),
                total90dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 16000),
              ),
              LiquidityPoolDto.fixture().copyWith(
                total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 5000),
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 1000),
                total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 10000),
                total90dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 20000),
              ),
            ],
          ),
        ),
      );

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("move-to-next-yields-page-button")));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key("${PoolDataTimeframe.week.name}-timeframe-button")));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the device is mobile, and the user swipe a yield from the right to the left,
  it should pass to the next yield page""",
    goldenFileName: "yields_page_success_swipe_to_next_page",
    (tester) async {
      when(() => cubit.state).thenReturn(
        YieldsState.success(
          LiquidityPoolsSearchResultDto.fixture().copyWith(
            pools: [
              LiquidityPoolDto.fixture().copyWith(
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 100),
              ),
              LiquidityPoolDto.fixture().copyWith(
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 200),
              ),
              LiquidityPoolDto.fixture().copyWith(
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 300),
              ),
              LiquidityPoolDto.fixture().copyWith(
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 400),
              ),
              LiquidityPoolDto.fixture().copyWith(
                total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 500),
              ),
            ],
          ),
        ),
      );

      await tester.pumpDeviceBuilder(await goldenBuilder(isMobile: true));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(YieldCard), const Offset(-350, 0));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    "When having a odd number of yields, the last yield page should be only one yield card",
    goldenFileName: "yields_page_success_odd_number_of_yields_last_page",
    (tester) async {
      final yields = [
        LiquidityPoolDto.fixture().copyWith(total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 100)),
        LiquidityPoolDto.fixture().copyWith(total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 200)),
        LiquidityPoolDto.fixture().copyWith(total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 300)),
        LiquidityPoolDto.fixture().copyWith(total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 400)),
        LiquidityPoolDto.fixture().copyWith(total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 500)),
      ];
      when(
        () => cubit.state,
      ).thenReturn(YieldsState.success(LiquidityPoolsSearchResultDto.fixture().copyWith(pools: yields)));

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      for (int i = 0; i < (yields.length / 2).ceil(); i++) {
        await tester.tap(find.byKey(const Key("move-to-next-yields-page-button")));
        await tester.pumpAndSettle();
      }
    },
  );

  zGoldenTest(
    """When having only one yield for the selected tokens,
    the page controller and page indicator should not be visible""",
    goldenFileName: "yields_page_success_one_yield_only",
    (tester) async {
      final yields = [
        LiquidityPoolDto.fixture().copyWith(total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 100)),
      ];
      when(
        () => cubit.state,
      ).thenReturn(YieldsState.success(LiquidityPoolsSearchResultDto.fixture().copyWith(pools: yields)));

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When having only two yields for the selected tokens,
    the page controller and page indicator should not be visible""",
    goldenFileName: "yields_page_success_two_yields_only",
    (tester) async {
      final yields = [
        LiquidityPoolDto.fixture().copyWith(total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 100)),
        LiquidityPoolDto.fixture().copyWith(total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 200)),
      ];
      when(
        () => cubit.state,
      ).thenReturn(YieldsState.success(LiquidityPoolsSearchResultDto.fixture().copyWith(pools: yields)));

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When hovering the page indicator in the success state,
    the page indicator size should be bigger""",
    goldenFileName: "yields_page_success_hover_page_indicator",
    (tester) async {
      final yields = List.generate(
        10,
        (_) =>
            LiquidityPoolDto.fixture().copyWith(total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 100)),
      );

      when(
        () => cubit.state,
      ).thenReturn(YieldsState.success(LiquidityPoolsSearchResultDto.fixture().copyWith(pools: yields)));

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.hover(find.byKey(const Key("yield-page-indicator-3")));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When clicking the page indicator in the success state,
    it should navigate to the corresponding page""",
    goldenFileName: "yields_page_success_click_page_indicator",
    (tester) async {
      final yields = List.generate(
        10,
        (index) => LiquidityPoolDto.fixture().copyWith(
          total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 100 * index),
        ),
      );

      when(
        () => cubit.state,
      ).thenReturn(YieldsState.success(LiquidityPoolsSearchResultDto.fixture().copyWith(pools: yields)));

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("yield-page-indicator-3")));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the search filters passed in the succes state has a min tvl with more than zero,
    it should show a message + button below the yields cards explaining that the
    search was only done for pools with a min tvl of the specified USD""",
    goldenFileName: "yields_page_success_min_tvl_warning",
    (tester) async {
      final yields = List.generate(
        2,
        (index) => LiquidityPoolDto.fixture().copyWith(
          total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 100 * index),
        ),
      );

      when(() => cubit.state).thenReturn(
        YieldsState.success(
          LiquidityPoolsSearchResultDto.fixture().copyWith(
            pools: yields,
            filters: const PoolSearchFiltersDto(minTvlUsd: 99898),
          ),
        ),
      );

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When clicking 'search all pools' in the min TVL Usd set warning,
    it should refetch pools without the min usd filter (zero) but use
    the same params got from the url""",
    (tester) async {
      final yields = List.generate(
        2,
        (index) => LiquidityPoolDto.fixture().copyWith(
          total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 100 * index),
        ),
      );
      const token0Id = "xabas";
      const token1Id = "sabax";
      const group0Id = "iuyip";
      const group1Id = "sayiji";

      when(() => navigator.getQueryParam(YieldsRouteParamsNames().token0)).thenReturn(token0Id);
      when(() => navigator.getQueryParam(YieldsRouteParamsNames().token1)).thenReturn(token1Id);
      when(() => navigator.getQueryParam(YieldsRouteParamsNames().group0)).thenReturn(group0Id);
      when(() => navigator.getQueryParam(YieldsRouteParamsNames().group1)).thenReturn(group1Id);

      when(() => cubit.state).thenReturn(
        YieldsState.success(
          LiquidityPoolsSearchResultDto.fixture().copyWith(
            pools: yields,
            filters: const PoolSearchFiltersDto(minTvlUsd: 99898),
          ),
        ),
      );

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("zup-inline-action-button-button")));
      await tester.pumpAndSettle();

      verify(
        () => cubit.fetchYields(
          token0AddressOrId: token0Id,
          token1AddressOrId: token1Id,
          group0Id: group0Id,
          group1Id: group1Id,
          ignoreMinLiquidity: true,
        ),
      ).called(1);
    },
  );

  zGoldenTest(
    """When the search filters passed in the succes state has a min tvl as zero,
    but the saved one in the cache, was a min tvl greater than zero,
    it should show a message + button below the yields cards explaining
    that the search was fone for all pools without a min tvl""",
    goldenFileName: "yields_page_success_no_min_tvl_warning",
    (tester) async {
      final yields = List.generate(
        2,
        (index) => LiquidityPoolDto.fixture().copyWith(
          total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 100 * index),
        ),
      );

      when(() => appCache.getPoolSearchSettings()).thenReturn(PoolSearchSettingsDto(minLiquidityUSD: 122));
      when(() => cubit.state).thenReturn(
        YieldsState.success(
          LiquidityPoolsSearchResultDto.fixture().copyWith(
            pools: yields,
            filters: const PoolSearchFiltersDto(minTvlUsd: 0),
          ),
        ),
      );

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When clicking the button of the warning that the search is displaying all pools,
    without min tvl, it should refetch pools with the flag to ignore min usd false and use
    the same params got from the url at the initial request""",
    (tester) async {
      final yields = List.generate(
        2,
        (index) => LiquidityPoolDto.fixture().copyWith(
          total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 100 * index),
        ),
      );
      const token0Id = "xabas";
      const token1Id = "sabax";
      const group0Id = "iuyip";
      const group1Id = "sayiji";

      when(() => navigator.getQueryParam(YieldsRouteParamsNames().token0)).thenReturn(token0Id);
      when(() => navigator.getQueryParam(YieldsRouteParamsNames().token1)).thenReturn(token1Id);
      when(() => navigator.getQueryParam(YieldsRouteParamsNames().group0)).thenReturn(group0Id);
      when(() => navigator.getQueryParam(YieldsRouteParamsNames().group1)).thenReturn(group1Id);

      when(() => appCache.getPoolSearchSettings()).thenReturn(PoolSearchSettingsDto(minLiquidityUSD: 122));
      when(() => cubit.state).thenReturn(
        YieldsState.success(
          LiquidityPoolsSearchResultDto.fixture().copyWith(
            pools: yields,
            filters: const PoolSearchFiltersDto(minTvlUsd: 0),
          ),
        ),
      );

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("zup-inline-action-button-button")));
      await tester.pumpAndSettle();

      verify(
        () => cubit.fetchYields(
          token0AddressOrId: token0Id,
          token1AddressOrId: token1Id,
          group0Id: group0Id,
          group1Id: group1Id,
          ignoreMinLiquidity: false,
        ),
      ).called(2); // the first one is the initial request and the second one is the refetch
    },
  );

  zGoldenTest(
    """When clicking the deposit button in the yield card,
  it should call the navigator to navigate to the deposit page
  passing the yield pool that was clicked""",
    (tester) async {
      final yields = List.generate(
        2,
        (index) => LiquidityPoolDto.fixture().copyWith(
          total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 100 * index),
          poolAddress: "0x$index",
        ),
      );

      when(
        () => navigator.navigateToDeposit(
          yieldPool: any(named: "yieldPool"),
          selectedTimeframe: any(named: "selectedTimeframe"),
          parseWrappedToNative: any(named: "parseWrappedToNative"),
        ),
      ).thenAnswer((invocation) async {});

      when(() => cubit.state).thenReturn(
        YieldsState.success(
          LiquidityPoolsSearchResultDto.fixture().copyWith(
            pools: yields,
            filters: const PoolSearchFiltersDto(minTvlUsd: 0),
          ),
        ),
      );

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key("deposit-button-${yields[0].poolAddress}")));
      await tester.pumpAndSettle();

      verify(
        () => navigator.navigateToDeposit(
          yieldPool: yields[0],
          parseWrappedToNative: any(named: "parseWrappedToNative"),
          selectedTimeframe: any(named: "selectedTimeframe"),
        ),
      ).called(1);
    },
  );

  zGoldenTest(
    """When clicking the deposit button in the yield card,
  and the selected timeframe is week, it should pass the
  week timeframe to the navigator to navigate to the deposit page""",
    (tester) async {
      final yields = List.generate(
        2,
        (index) => LiquidityPoolDto.fixture().copyWith(
          total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 100 * index),
          poolAddress: "0x$index",
        ),
      );

      when(
        () => navigator.navigateToDeposit(
          yieldPool: any(named: "yieldPool"),
          selectedTimeframe: any(named: "selectedTimeframe"),
          parseWrappedToNative: any(named: "parseWrappedToNative"),
        ),
      ).thenAnswer((invocation) async {});

      when(() => cubit.state).thenReturn(
        YieldsState.success(
          LiquidityPoolsSearchResultDto.fixture().copyWith(
            pools: yields,
            filters: const PoolSearchFiltersDto(minTvlUsd: 0),
          ),
        ),
      );

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key("${PoolDataTimeframe.week.name}-timeframe-button")));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key("deposit-button-${yields[0].poolAddress}")));
      await tester.pumpAndSettle();

      verify(
        () => navigator.navigateToDeposit(
          yieldPool: any(named: "yieldPool"),
          parseWrappedToNative: any(named: "parseWrappedToNative"),
          selectedTimeframe: PoolDataTimeframe.week,
        ),
      ).called(1);
    },
  );

  zGoldenTest(
    """When clicking the deposit button in the yield card,
  and the selected timeframe is month, it should pass the
  month timeframe to the navigator to navigate to the deposit page""",
    (tester) async {
      final yields = List.generate(
        2,
        (index) => LiquidityPoolDto.fixture().copyWith(
          total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 100 * index),
          poolAddress: "0x$index",
        ),
      );

      when(
        () => navigator.navigateToDeposit(
          yieldPool: any(named: "yieldPool"),
          selectedTimeframe: any(named: "selectedTimeframe"),
          parseWrappedToNative: any(named: "parseWrappedToNative"),
        ),
      ).thenAnswer((invocation) async {});

      when(() => cubit.state).thenReturn(
        YieldsState.success(
          LiquidityPoolsSearchResultDto.fixture().copyWith(
            pools: yields,
            filters: const PoolSearchFiltersDto(minTvlUsd: 0),
          ),
        ),
      );

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key("${PoolDataTimeframe.month.name}-timeframe-button")));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key("deposit-button-${yields[0].poolAddress}")));
      await tester.pumpAndSettle();

      verify(
        () => navigator.navigateToDeposit(
          yieldPool: any(named: "yieldPool"),
          parseWrappedToNative: any(named: "parseWrappedToNative"),
          selectedTimeframe: PoolDataTimeframe.month,
        ),
      ).called(1);
    },
  );

  zGoldenTest(
    """When clicking the deposit button in the yield card,
  and the user didn't select any timeframe, the default
  passed to the navigator to navigate to the deposit page
  should be the day timeframe""",
    (tester) async {
      final yields = List.generate(
        2,
        (index) => LiquidityPoolDto.fixture().copyWith(
          total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 100 * index),
          poolAddress: "0x$index",
        ),
      );

      when(
        () => navigator.navigateToDeposit(
          yieldPool: any(named: "yieldPool"),
          selectedTimeframe: any(named: "selectedTimeframe"),
          parseWrappedToNative: any(named: "parseWrappedToNative"),
        ),
      ).thenAnswer((invocation) async {});

      when(() => cubit.state).thenReturn(
        YieldsState.success(
          LiquidityPoolsSearchResultDto.fixture().copyWith(
            pools: yields,
            filters: const PoolSearchFiltersDto(minTvlUsd: 0),
          ),
        ),
      );

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key("${PoolDataTimeframe.day.name}-timeframe-button")));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key("deposit-button-${yields[0].poolAddress}")));
      await tester.pumpAndSettle();

      verify(
        () => navigator.navigateToDeposit(
          yieldPool: any(named: "yieldPool"),
          parseWrappedToNative: any(named: "parseWrappedToNative"),
          selectedTimeframe: PoolDataTimeframe.day,
        ),
      ).called(1);
    },
  );

  zGoldenTest(
    """When clicking the deposit button in the yield card,
  and the address of the token0 in the pool for the network
  is zero, it should pass parseWrappedToNative as true
  to the navigator to navigate to the deposit page""",
    (tester) async {
      const yieldNetwork = AppNetworks.sepolia;

      final yields = List.generate(
        2,
        (index) => LiquidityPoolDto.fixture().copyWith(
          total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 100 * index),
          poolAddress: "0x$index",
          chainId: yieldNetwork.chainId,
          token0: const SingleChainTokenDto(address: EthereumConstants.zeroAddress),
        ),
      );

      when(
        () => navigator.navigateToDeposit(
          yieldPool: any(named: "yieldPool"),
          selectedTimeframe: any(named: "selectedTimeframe"),
          parseWrappedToNative: any(named: "parseWrappedToNative"),
        ),
      ).thenAnswer((invocation) async {});

      when(() => cubit.state).thenReturn(
        YieldsState.success(
          LiquidityPoolsSearchResultDto.fixture().copyWith(
            pools: yields,
            filters: const PoolSearchFiltersDto(minTvlUsd: 0),
          ),
        ),
      );

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key("deposit-button-${yields[0].poolAddress}")));
      await tester.pumpAndSettle();

      verify(
        () => navigator.navigateToDeposit(
          yieldPool: any(named: "yieldPool"),
          parseWrappedToNative: true,
          selectedTimeframe: any(named: "selectedTimeframe"),
        ),
      ).called(1);
    },
  );

  zGoldenTest(
    """When clicking the deposit button in the yield card,
  and the address of the token1 in the pool for the network
  is zero, it should pass parseWrappedToNative as true
  to the navigator to navigate to the deposit page""",
    (tester) async {
      const yieldNetwork = AppNetworks.sepolia;

      final yields = List.generate(
        2,
        (index) => LiquidityPoolDto.fixture().copyWith(
          total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 100 * index),
          poolAddress: "0x$index",
          chainId: yieldNetwork.chainId,
          token1: const SingleChainTokenDto(address: EthereumConstants.zeroAddress),
        ),
      );

      when(
        () => navigator.navigateToDeposit(
          yieldPool: any(named: "yieldPool"),
          selectedTimeframe: any(named: "selectedTimeframe"),
          parseWrappedToNative: any(named: "parseWrappedToNative"),
        ),
      ).thenAnswer((invocation) async {});

      when(() => cubit.state).thenReturn(
        YieldsState.success(
          LiquidityPoolsSearchResultDto.fixture().copyWith(
            pools: yields,
            filters: const PoolSearchFiltersDto(minTvlUsd: 0),
          ),
        ),
      );

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key("deposit-button-${yields[0].poolAddress}")));
      await tester.pumpAndSettle();

      verify(
        () => navigator.navigateToDeposit(
          yieldPool: any(named: "yieldPool"),
          parseWrappedToNative: true,
          selectedTimeframe: any(named: "selectedTimeframe"),
        ),
      ).called(1);
    },
  );

  zGoldenTest(
    """When clicking the deposit button in the yield card,
  and the address of the token1 in the pool for the network
  is wrapped native, it should not pass parseWrappedToNative as true
  to the navigator to navigate to the deposit page""",
    (tester) async {
      const yieldNetwork = AppNetworks.sepolia;

      final yields = List.generate(
        2,
        (index) => LiquidityPoolDto.fixture().copyWith(
          total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 100 * index),
          poolAddress: "0x$index",
          chainId: yieldNetwork.chainId,
          token1: SingleChainTokenDto(address: yieldNetwork.wrappedNativeTokenAddress),
        ),
      );

      when(
        () => navigator.navigateToDeposit(
          yieldPool: any(named: "yieldPool"),
          selectedTimeframe: any(named: "selectedTimeframe"),
          parseWrappedToNative: any(named: "parseWrappedToNative"),
        ),
      ).thenAnswer((invocation) async {});

      when(() => cubit.state).thenReturn(
        YieldsState.success(
          LiquidityPoolsSearchResultDto.fixture().copyWith(
            pools: yields,
            filters: const PoolSearchFiltersDto(minTvlUsd: 0),
          ),
        ),
      );

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key("deposit-button-${yields[0].poolAddress}")));
      await tester.pumpAndSettle();

      verify(
        () => navigator.navigateToDeposit(
          yieldPool: any(named: "yieldPool"),
          parseWrappedToNative: false,
          selectedTimeframe: any(named: "selectedTimeframe"),
        ),
      ).called(1);
    },
  );

  zGoldenTest(
    """When clicking the deposit button in the yield card,
  and the address of the token0 in the pool for the network
  is wrapped native, it should not pass parseWrappedToNative as true
  to the navigator to navigate to the deposit page""",
    (tester) async {
      const yieldNetwork = AppNetworks.sepolia;

      final yields = List.generate(
        2,
        (index) => LiquidityPoolDto.fixture().copyWith(
          total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 100 * index),
          poolAddress: "0x$index",
          chainId: yieldNetwork.chainId,
          token0: SingleChainTokenDto(address: yieldNetwork.wrappedNativeTokenAddress),
        ),
      );

      when(
        () => navigator.navigateToDeposit(
          yieldPool: any(named: "yieldPool"),
          selectedTimeframe: any(named: "selectedTimeframe"),
          parseWrappedToNative: any(named: "parseWrappedToNative"),
        ),
      ).thenAnswer((invocation) async {});

      when(() => cubit.state).thenReturn(
        YieldsState.success(
          LiquidityPoolsSearchResultDto.fixture().copyWith(
            pools: yields,
            filters: const PoolSearchFiltersDto(minTvlUsd: 0),
          ),
        ),
      );

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key("deposit-button-${yields[0].poolAddress}")));
      await tester.pumpAndSettle();

      verify(
        () => navigator.navigateToDeposit(
          yieldPool: any(named: "yieldPool"),
          parseWrappedToNative: false,
          selectedTimeframe: any(named: "selectedTimeframe"),
        ),
      ).called(1);
    },
  );

  zGoldenTest(
    "When clicking the pool stats button in the yield card, it should open the pool info side panel",
    goldenFileName: "yields_page_open_pool_stats_modal",
    (tester) async {
      final yields = [LiquidityPoolDto.fixture()];
      when(
        () => cubit.state,
      ).thenReturn(YieldsState.success(LiquidityPoolsSearchResultDto.fixture().copyWith(pools: yields)));

      await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key("pool-stats-button-${yields[0].poolAddress}")));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    "When clicking the pool stats button in the yield card, and the device is mobile, it should open the pool info as bottom sheet",
    goldenFileName: "yields_page_open_pool_stats_modal_as_bottom_sheet",
    (tester) async {
      final yields = [LiquidityPoolDto.fixture()];
      when(
        () => cubit.state,
      ).thenReturn(YieldsState.success(LiquidityPoolsSearchResultDto.fixture().copyWith(pools: yields)));

      await tester.pumpDeviceBuilder(await goldenBuilder(isMobile: true), wrapper: GoldenConfig.localizationsWrapper());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key("pool-stats-button-${yields[0].poolAddress}")));
      await tester.pumpAndSettle();
    },
  );
}
