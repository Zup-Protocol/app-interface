import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routefly/routefly.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/core/dtos/deposit_page_arguments_dto.dart';
import 'package:zup_app/core/dtos/liquidity_pool_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/enums/pool_data_timeframe.dart';
import 'package:zup_app/core/enums/zup_navigator_paths.dart';
import 'package:zup_app/core/zup_navigator.dart';
import 'package:zup_app/core/zup_route_params_names.dart';
import 'package:zup_app/zup_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MaterialApp material;

  setUp(() {
    material = MaterialApp.router(
      key: GlobalKey(),
      localizationsDelegates: const [Web3KitLocalizations.delegate],
      routerConfig: Routefly.routerConfig(
        navigatorKey: GlobalKey(),
        routes: routes,
        initialPath: ZupNavigatorPaths.initial.path,
        routeBuilder: (context, settings, child) =>
            PageRouteBuilder(settings: settings, pageBuilder: (context, __, ___) => const SizedBox()),
      ),
    );
  });

  tearDown(() {
    Routefly.navigate("/", arguments: null);
  });

  testWidgets("When calling `navigateToNewPosition` it should use routefly to navigate to the new position page", (
    tester,
  ) async {
    await tester.pumpWidget(material);

    await ZupNavigator().navigateToNewPosition();

    expect(Routefly.currentUri.path, ZupNavigatorPaths.newPosition.path);
  });

  testWidgets("When calling `navigateToInitial` it should use routefly to navigate to the initial page", (
    tester,
  ) async {
    runApp(material);

    await ZupNavigator().navigateToInitial();

    expect(Routefly.currentUri.path, ZupNavigatorPaths.initial.path);
  });

  testWidgets("When calling `currentRoute` it should use routefly to get the current route", (tester) async {
    runApp(material);

    await Routefly.navigate(ZupNavigatorPaths.newPosition.path);

    expect(ZupNavigator().currentRoute, ZupNavigatorPaths.newPosition.path);
  });

  testWidgets("When using `listenable` to listen route change events, it should delegate to Routefly listenable", (
    tester,
  ) async {
    runApp(material);

    bool listenerCalled = false;

    ZupNavigator().listenable.addListener(() => listenerCalled = true);

    await Routefly.navigate(ZupNavigatorPaths.newPosition.path);

    expect(listenerCalled, true);
  });

  testWidgets("When calling `navigateToYields` it should pass the params to the query", (tester) async {
    runApp(material);
    const group0 = "0x123";
    const group1 = "0x456";
    const token0 = "0x789";
    const token1 = "0xabc";
    const network = AppNetworks.mainnet;

    await ZupNavigator().navigateToYields(
      group0: group0,
      group1: group1,
      token0: token0,
      token1: token1,
      network: network,
    );

    expect(Routefly.query.params, {
      YieldsRouteParamsNames().group0: group0,
      YieldsRouteParamsNames().group1: group1,
      YieldsRouteParamsNames().token0: token0,
      YieldsRouteParamsNames().token1: token1,
      YieldsRouteParamsNames().network: network.name,
    });
  });

  testWidgets("When calling `navigateToYields` without group0, it should not pass it to the query", (tester) async {
    runApp(material);

    const group1 = "0x456";
    const token0 = "0x789";
    const token1 = "0xabc";
    const network = AppNetworks.mainnet;

    await ZupNavigator().navigateToYields(
      group0: null,
      group1: group1,
      token0: token0,
      token1: token1,
      network: network,
    );

    expect(Routefly.query.params, {
      YieldsRouteParamsNames().group1: group1,
      YieldsRouteParamsNames().token0: token0,
      YieldsRouteParamsNames().token1: token1,
      YieldsRouteParamsNames().network: network.name,
    });
  });

  testWidgets("When calling `navigateToYields` without group1, it should not pass it to the query", (tester) async {
    runApp(material);

    const group0 = "0x456";
    const token0 = "0x789";
    const token1 = "0xabc";
    const network = AppNetworks.mainnet;

    await ZupNavigator().navigateToYields(
      group0: group0,
      group1: null,
      token0: token0,
      token1: token1,
      network: network,
    );

    expect(Routefly.query.params, {
      YieldsRouteParamsNames().group0: group0,
      YieldsRouteParamsNames().token0: token0,
      YieldsRouteParamsNames().token1: token1,
      YieldsRouteParamsNames().network: network.name,
    });
  });

  testWidgets("When calling `navigateToYields` without groups, it should not pass it to the query", (tester) async {
    runApp(material);

    const token0 = "0x789";
    const token1 = "0xabc";
    const network = AppNetworks.mainnet;

    await ZupNavigator().navigateToYields(group0: null, group1: null, token0: token0, token1: token1, network: network);

    expect(Routefly.query.params, {
      YieldsRouteParamsNames().token0: token0,
      YieldsRouteParamsNames().token1: token1,
      YieldsRouteParamsNames().network: network.name,
    });
  });

  testWidgets("When calling `navigateToYields` without token0, it should not pass it to the query", (tester) async {
    runApp(material);
    const group0 = "0x123";
    const group1 = "0x456";
    const token1 = "0xabc";
    const network = AppNetworks.mainnet;

    await ZupNavigator().navigateToYields(
      group0: group0,
      group1: group1,
      token0: null,
      token1: token1,
      network: network,
    );

    expect(Routefly.query.params, {
      YieldsRouteParamsNames().group0: group0,
      YieldsRouteParamsNames().group1: group1,
      YieldsRouteParamsNames().token1: token1,
      YieldsRouteParamsNames().network: network.name,
    });
  });

  testWidgets("When calling `navigateToYields` without token1, it should not pass it to the query", (tester) async {
    runApp(material);
    const group0 = "0x123";
    const group1 = "0x456";
    const token0 = "0xabc";
    const network = AppNetworks.mainnet;

    await ZupNavigator().navigateToYields(
      group0: group0,
      group1: group1,
      token0: token0,
      token1: null,
      network: network,
    );

    expect(Routefly.query.params, {
      YieldsRouteParamsNames().group0: group0,
      YieldsRouteParamsNames().group1: group1,
      YieldsRouteParamsNames().token0: token0,
      YieldsRouteParamsNames().network: network.name,
    });
  });

  testWidgets("When calling `navigateToYields` without tokens, it should not pass it to the query", (tester) async {
    runApp(material);
    const group0 = "0x123";
    const group1 = "0x456";
    const network = AppNetworks.mainnet;

    await ZupNavigator().navigateToYields(group0: group0, group1: group1, token0: null, token1: null, network: network);

    expect(Routefly.query.params, {
      YieldsRouteParamsNames().group0: group0,
      YieldsRouteParamsNames().group1: group1,
      YieldsRouteParamsNames().network: network.name,
    });
  });

  testWidgets(
    """When calling `navigateToDeposit` it should add the pool network name to the query params,
  and assigned the passed timeframe and parseWrappedToNative to the query params""",
    (tester) async {
      runApp(material);

      const network = AppNetworks.mainnet;
      final yieldPool = LiquidityPoolDto.fixture().copyWith(chainId: network.chainId);
      const yieldTimeFrame = PoolDataTimeframe.month;
      const parseWrappedToNative = true;

      await ZupNavigator().navigateToDeposit(
        yieldPool: yieldPool,
        selectedTimeframe: yieldTimeFrame,
        parseWrappedToNative: parseWrappedToNative,
      );

      expect(Routefly.query.params, {
        DepositRouteParamsNames().network: network.name,
        DepositRouteParamsNames().timeframe: yieldTimeFrame.name,
        DepositRouteParamsNames().parseWrappedToNative: parseWrappedToNative.toString(),
      });
    },
  );

  testWidgets("When calling `navigateToDeposit` it should replace the id part with the pool address", (tester) async {
    runApp(material);

    const network = AppNetworks.mainnet;
    final yieldPool = LiquidityPoolDto.fixture().copyWith(chainId: network.chainId, poolAddress: "xabasRAaa");
    const yieldTimeFrame = PoolDataTimeframe.month;
    const parseWrappedToNative = true;

    await ZupNavigator().navigateToDeposit(
      yieldPool: yieldPool,
      selectedTimeframe: yieldTimeFrame,
      parseWrappedToNative: parseWrappedToNative,
    );

    expect(Routefly.currentUri.path, ZupNavigatorPaths.deposit.path.changes({"id": yieldPool.poolAddress}));
  });

  testWidgets("When calling `navigateToDeposit` it should pass the pool dto as argument", (tester) async {
    await tester.pumpWidget(material);

    final yieldPool = LiquidityPoolDto.fixture().copyWith(
      chainId: AppNetworks.mainnet.chainId,
      poolAddress: "Pull Address",
    );
    const yieldTimeFrame = PoolDataTimeframe.month;
    const parseWrappedToNative = true;

    await ZupNavigator().navigateToDeposit(
      yieldPool: yieldPool,
      selectedTimeframe: yieldTimeFrame,
      parseWrappedToNative: parseWrappedToNative,
    );

    await tester.pumpAndSettle();

    expect(Routefly.query.arguments, DepositPageArgumentsDto(yieldPool: yieldPool).toJson());
  });
}
