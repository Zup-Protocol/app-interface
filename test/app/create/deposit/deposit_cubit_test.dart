import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/abis/uniswap_v3_pool.abi.g.dart';
import 'package:zup_app/app/create/yields/%5Bid%5D/deposit/deposit_cubit.dart';
import 'package:zup_app/core/cache.dart';
import 'package:zup_app/core/dtos/deposit_page_arguments_dto.dart';
import 'package:zup_app/core/dtos/deposit_settings_dto.dart';
import 'package:zup_app/core/dtos/liquidity_pool_dto.dart';
import 'package:zup_app/core/dtos/liquidity_pools_search_result_dto.dart';
import 'package:zup_app/core/dtos/pool_search_settings_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/pool_service.dart';
import 'package:zup_app/core/repositories/yield_repository.dart';
import 'package:zup_app/core/slippage.dart';
import 'package:zup_app/core/zup_navigator.dart';
import 'package:zup_app/core/zup_route_params_names.dart';
import 'package:zup_core/zup_singleton_cache.dart';

import '../../../mocks.dart';

void main() {
  late YieldRepository yieldRepository;
  late ZupSingletonCache zupSingletonCache;
  late Wallet wallet;
  late UniswapV3Pool uniswapV3Pool;
  late UniswapV3PoolImpl uniswapV3PoolImpl;
  late DepositCubit sut;
  late Cache cache;
  late ZupNavigator navigator;
  late PoolService poolService;
  final poolSqrtPriceX96 = BigInt.from(31276567121);

  setUp(() {
    registerFallbackValue(DepositSettingsDto.fixture());
    registerFallbackValue(AppNetworks.sepolia);
    registerFallbackValue(PoolSearchSettingsDto.fixture());
    registerFallbackValue(LiquidityPoolDto.fixture());
    poolService = PoolServiceMock();

    yieldRepository = YieldRepositoryMock();
    zupSingletonCache = ZupSingletonCache.shared;
    wallet = WalletMock();
    uniswapV3Pool = UniswapV3PoolMock();
    uniswapV3PoolImpl = UniswapV3PoolImplMock();
    cache = CacheMock();
    navigator = ZupNavigatorMock();

    when(
      () => navigator.currentPageArguments,
    ).thenReturn(const DepositPageArgumentsDto().copyWith(yieldPool: LiquidityPoolDto.fixture()).toJson());

    sut = DepositCubit(yieldRepository, zupSingletonCache, wallet, cache, poolService, navigator);

    when(() => cache.blockedProtocolsIds).thenReturn([]);
    when(
      () => yieldRepository.getAllNetworksYield(
        token0InternalId: any(named: "token0InternalId"),
        token1InternalId: any(named: "token1InternalId"),
        searchSettings: any(named: "searchSettings"),
        blockedProtocolIds: any(named: "blockedProtocolIds"),
        group0Id: any(named: "group0Id"),
        group1Id: any(named: "group1Id"),
        testnetMode: any(named: "testnetMode"),
      ),
    ).thenAnswer((_) async => LiquidityPoolsSearchResultDto.fixture());

    when(() => cache.getPoolSearchSettings()).thenReturn(PoolSearchSettingsDto.fixture());
    when(
      () => uniswapV3Pool.fromRpcProvider(
        contractAddress: any(named: "contractAddress"),
        rpcUrl: any(named: "rpcUrl"),
      ),
    ).thenReturn(uniswapV3PoolImpl);

    when(() => uniswapV3PoolImpl.slot0()).thenAnswer(
      (_) async => (
        feeProtocol: BigInt.zero,
        observationCardinality: BigInt.zero,
        observationCardinalityNext: BigInt.zero,
        observationIndex: BigInt.zero,
        sqrtPriceX96: poolSqrtPriceX96,
        tick: BigInt.zero,
        unlocked: true,
      ),
    );

    when(() => poolService.getSqrtPriceX96(any())).thenAnswer((_) async => poolSqrtPriceX96);
    when(() => cache.getPoolSearchSettings()).thenReturn(PoolSearchSettingsDto(minLiquidityUSD: 129816));
  });

  tearDown(() async {
    await zupSingletonCache.clear();
  });

  group(
    "When calling `setup`, the cubit should register a periodic task to get the pool sqrtPriceX96 every half minute. ",
    () {
      test("And if the selected yield is not null, it should execute the task to get the pool sqrtPriceX96", () async {
        BigInt? actualLastEmittedSqrtPriceX96;
        int eventsCounter = 0;
        const minutesPassed = 3;

        fakeAsync((async) {
          sut.setup();

          sut.poolSqrtPriceX96Stream.listen((event) {
            actualLastEmittedSqrtPriceX96 = event;
            eventsCounter++;
          });

          async.elapse(const Duration(minutes: minutesPassed));

          expect(actualLastEmittedSqrtPriceX96, poolSqrtPriceX96);
          expect(eventsCounter, minutesPassed * 2);
        });
      });

      test(
        """And when the minuted passed, but the selected yield is null
        it should not execute the task to get the pool sqrtPriceX96""",
        () async {
          when(() => navigator.currentPageArguments).thenReturn({});

          sut = DepositCubit(yieldRepository, zupSingletonCache, wallet, cache, poolService, navigator);

          int eventsCounter = 0;
          const minutesPassed = 3;

          fakeAsync((async) {
            sut.setup();

            sut.poolSqrtPriceX96Stream.listen((event) {
              eventsCounter++;
            });

            async.elapse(const Duration(minutes: minutesPassed));

            expect(eventsCounter, 0);
          });
        },
      );

      test(
        """If the cubit is closed, and the minuted passed,
         it should not execute the task to get the pool sqrtPriceX96
        and cancel the periodic task""",
        () async {
          int eventCount = 0;

          fakeAsync((async) {
            sut.setup();
            sut.close();

            sut.poolSqrtPriceX96Stream.listen((_) {
              eventCount++;
            });

            async.elapse(const Duration(minutes: 10));

            expect(async.periodicTimerCount, 0);
            expect(eventCount, 0);
          });
        },
      );
    },
  );

  test("when closing the cubit, it should close the pool sqrtPriceX96 stream", () async {
    await sut.close();

    expect(() async => await sut.getPoolSqrtPriceX96(), throwsA(isA<StateError>()));
  });

  test("When calling `getWalletTokenAmount` and there's no connected signer, it should return 0", () async {
    final tokenAmount = await sut.getWalletTokenAmount("", network: AppNetworks.sepolia);

    expect(tokenAmount, 0);
  });

  test(
    "When calling `getWalletTokenAmount` and there's a connected signer it should get the wallet token amount",
    () async {
      final signer = SignerMock();
      const tokenAddress = "0x0";
      const network = AppNetworks.sepolia;
      const expectedTokenBalance = 1243.542;

      when(
        () => wallet.nativeOrTokenBalance(tokenAddress, rpcUrl: any(named: "rpcUrl")),
      ).thenAnswer((_) async => 1243.542);
      when(() => wallet.signer).thenReturn(signer);
      when(() => signer.address).thenAnswer((_) async => "0x99E3CfADCD8Feecb5DdF91f88998cFfB3145F78c");

      final actualTokenBalance = await sut.getWalletTokenAmount(tokenAddress, network: network);

      expect(actualTokenBalance, expectedTokenBalance);
      verify(() => wallet.nativeOrTokenBalance(tokenAddress, rpcUrl: network.rpcUrl)).called(1);
    },
  );

  test(
    "When calling `getWalletTokenAmount` it should use zup singleton cache to return the cached value if the cache is not more than 10 minutes old",
    () async {
      const tokenAddress = "0x0";
      final signer = SignerMock();
      const network = AppNetworks.sepolia;
      const expectedTokenBalance = 1243.542;
      const notExpectedTokenBalance = 498361387.42;

      when(
        () => wallet.nativeOrTokenBalance(tokenAddress, rpcUrl: any(named: "rpcUrl")),
      ).thenAnswer((_) async => 1243.542);
      when(() => wallet.signer).thenReturn(signer);
      when(() => signer.address).thenAnswer((_) async => "0x99E3CfADCD8Feecb5DdF91f88998cFfB3145F78c");

      final actualTokenBalance1 = await sut.getWalletTokenAmount(tokenAddress, network: network);

      when(
        () => wallet.nativeOrTokenBalance(tokenAddress, rpcUrl: any(named: "rpcUrl")),
      ).thenAnswer((_) async => notExpectedTokenBalance);

      final actualTokenBalance2 = await sut.getWalletTokenAmount(tokenAddress, network: network);

      verify(() => wallet.nativeOrTokenBalance(tokenAddress, rpcUrl: network.rpcUrl)).called(1);

      expect(actualTokenBalance1, expectedTokenBalance);
      expect(actualTokenBalance2, expectedTokenBalance);
    },
  );

  test(
    "When calling `getWalletTokenAmount` it should use zup singleton cache with a 10 minutes expiration time",
    () async {
      const tokenAddress = "0x0";
      final signer = SignerMock();
      const network = AppNetworks.sepolia;
      const expectedTokenBalance = 1243.542;
      const notExpectedTokenBalance = 498361387.42;

      when(
        () => wallet.nativeOrTokenBalance(tokenAddress, rpcUrl: any(named: "rpcUrl")),
      ).thenAnswer((_) async => notExpectedTokenBalance);
      when(() => wallet.signer).thenReturn(signer);
      when(() => signer.address).thenAnswer((_) async => "0x99E3CfADCD8Feecb5DdF91f88998cFfB3145F78c");

      await sut.getWalletTokenAmount(tokenAddress, network: network);

      await withClock(Clock(() => DateTime.now().add(const Duration(minutes: 11))), () async {
        when(
          () => wallet.nativeOrTokenBalance(tokenAddress, rpcUrl: any(named: "rpcUrl")),
        ).thenAnswer((_) async => expectedTokenBalance);

        final actualTokenBalance2 = await sut.getWalletTokenAmount(tokenAddress, network: network);

        verify(
          () => wallet.nativeOrTokenBalance(tokenAddress, rpcUrl: network.rpcUrl),
        ).called(2); // it should call the method twice because the cache is expired

        expect(actualTokenBalance2, expectedTokenBalance);
      });
    },
  );

  test(
    "When calling `getWalletTokenAmount` and an error occurs getting the wallet balance, it should return 0",
    () async {
      final signer = SignerMock();
      const tokenAddress = "0x0";
      const network = AppNetworks.sepolia;

      when(() => wallet.tokenBalance(tokenAddress, rpcUrl: any(named: "rpcUrl"))).thenThrow(Exception());
      when(() => wallet.signer).thenReturn(signer);
      when(() => signer.address).thenAnswer((_) async => "0x99E3CfADCD8Feecb5DdF91f88998cFfB3145F78c");

      final actualTokenBalance = await sut.getWalletTokenAmount(tokenAddress, network: network);

      expect(actualTokenBalance, 0.0);
    },
  );

  test("When calling `saveDepositSettings` it should save the passed params in the cache", () async {
    when(() => cache.saveDepositSettings(any())).thenAnswer((_) async => () {});

    const slippage = Slippage.zeroPointOnePercent;
    const deadline = Duration(minutes: 5);

    final expectedDepositSettings = DepositSettingsDto(
      deadlineMinutes: deadline.inMinutes,
      maxSlippage: slippage.value.toDouble(),
    );

    await sut.saveDepositSettings(slippage, deadline);

    verify(() => cache.saveDepositSettings(expectedDepositSettings)).called(1);
  });

  test("When calling `depositSettings` it should get the deposit settings from the cache", () {
    const expectedDepositSettings = DepositSettingsDto(deadlineMinutes: 5, maxSlippage: 0.01);

    when(() => cache.getDepositSettings()).thenReturn(expectedDepositSettings);

    final actualDepositSettings = sut.depositSettings;

    expect(actualDepositSettings, expectedDepositSettings);
  });

  test("When calling 'poolSearchSettings' it should get the pool search settings from the cache", () {
    final expectedPoolSearchSettings = PoolSearchSettingsDto(minLiquidityUSD: 129816);

    when(() => cache.getPoolSearchSettings()).thenReturn(expectedPoolSearchSettings);
    final actualPoolSearchSettings = sut.poolSearchSettings;

    expect(actualPoolSearchSettings, expectedPoolSearchSettings);
  });

  test("When calling 'fetchCurrentPoolInfo' it should emit the loading state", () async {
    expectLater(sut.stream, emits(const DepositState.loading()));

    await sut.fetchCurrentPoolInfo();
  });

  test(
    """When calling 'fetchCurrentPoolInfo' it should call the yield repository
    to fetch pool data, using the params from the url gotten from the navigator""",
    () async {
      const expectedNetwork = AppNetworks.sepolia;
      const expectedPoolAddress = "0x12322";
      const expectedParseWrappedToNative = true;

      when(() => navigator.getQueryParam(DepositRouteParamsNames().network)).thenReturn(expectedNetwork.name);
      when(() => navigator.getIdFromPath).thenReturn(expectedPoolAddress);
      when(
        () => navigator.getQueryParam(DepositRouteParamsNames().parseWrappedToNative),
      ).thenReturn(expectedParseWrappedToNative.toString());

      await sut.fetchCurrentPoolInfo();

      verify(
        () => yieldRepository.getPoolInfo(
          poolAddress: expectedPoolAddress,
          poolNetwork: expectedNetwork,
          parseWrappedToNative: expectedParseWrappedToNative,
        ),
      ).called(1);
    },
  );

  test(
    """When calling 'fetchCurrentPoolInfo', after fetching the pool data from the repository,
    it should get the pool sqrt price from the pool service, and emit the new sqrt price gotten""",
    () async {
      final pool = LiquidityPoolDto.fixture();
      final expectedSqrtPriceX96 = BigInt.from(126128912198);

      when(() => poolService.getSqrtPriceX96(pool)).thenAnswer((_) async => expectedSqrtPriceX96);
      when(() => navigator.getQueryParam(DepositRouteParamsNames().network)).thenReturn("sepolia");
      when(() => navigator.getIdFromPath).thenReturn("0xbas");
      when(() => navigator.getQueryParam(DepositRouteParamsNames().parseWrappedToNative)).thenReturn(true.toString());
      when(
        () => yieldRepository.getPoolInfo(
          poolAddress: any(named: "poolAddress"),
          poolNetwork: any(named: "poolNetwork"),
          parseWrappedToNative: any(named: "parseWrappedToNative"),
        ),
      ).thenAnswer((_) async => pool);

      expectLater(sut.poolSqrtPriceX96Stream, emits(expectedSqrtPriceX96));

      await sut.fetchCurrentPoolInfo();

      verify(() => poolService.getSqrtPriceX96(pool)).called(1);
    },
  );

  test(
    """When calling 'fetchCurrentPoolInfo', after fetching the pool data from the repository,
    it should get the pool sqrt price from the pool service, and assign it to the latest
    poolSqrtPriceX96 variable""",
    () async {
      final pool = LiquidityPoolDto.fixture();
      final expectedSqrtPriceX96 = BigInt.from(1111);

      when(() => poolService.getSqrtPriceX96(pool)).thenAnswer((_) async => expectedSqrtPriceX96);
      when(() => navigator.getQueryParam(DepositRouteParamsNames().network)).thenReturn("sepolia");
      when(() => navigator.getIdFromPath).thenReturn("0xbas");
      when(() => navigator.getQueryParam(DepositRouteParamsNames().parseWrappedToNative)).thenReturn(true.toString());
      when(
        () => yieldRepository.getPoolInfo(
          poolAddress: any(named: "poolAddress"),
          poolNetwork: any(named: "poolNetwork"),
          parseWrappedToNative: any(named: "parseWrappedToNative"),
        ),
      ).thenAnswer((_) async => pool);

      await sut.fetchCurrentPoolInfo();

      expect(sut.latestPoolSqrtPriceX96, expectedSqrtPriceX96);
      verify(() => poolService.getSqrtPriceX96(pool)).called(1);
    },
  );

  test(
    """When calling 'fetchCurrentPoolInfo', after fetching the pool data from the repository,
    it should emit the success state with the pool data""",
    () async {
      final pool = LiquidityPoolDto.fixture().copyWith(poolAddress: "pool for testing emit success");

      when(() => navigator.getQueryParam(DepositRouteParamsNames().network)).thenReturn("sepolia");
      when(() => navigator.getIdFromPath).thenReturn("0xbas");
      when(() => navigator.getQueryParam(DepositRouteParamsNames().parseWrappedToNative)).thenReturn(true.toString());
      when(
        () => yieldRepository.getPoolInfo(
          poolAddress: any(named: "poolAddress"),
          poolNetwork: any(named: "poolNetwork"),
          parseWrappedToNative: any(named: "parseWrappedToNative"),
        ),
      ).thenAnswer((_) async => pool);

      await sut.fetchCurrentPoolInfo();

      expect(sut.state, DepositState.success(pool));
    },
  );

  test(
    """When instanciating the cubit, and there is no pool coming from the arguments,
  it should fetch the pool info using the params from the url""",
    () {
      const poolAddress = "0x98abas";
      const poolNetwork = AppNetworks.base;
      const parseWrappedToNative = true;

      when(() => navigator.getQueryParam(DepositRouteParamsNames().network)).thenReturn(poolNetwork.name);
      when(() => navigator.getIdFromPath).thenReturn(poolAddress);
      when(
        () => navigator.getQueryParam(DepositRouteParamsNames().parseWrappedToNative),
      ).thenReturn(parseWrappedToNative.toString());

      when(() => navigator.currentPageArguments).thenReturn({});

      sut = DepositCubit(yieldRepository, zupSingletonCache, wallet, cache, poolService, navigator);

      verify(
        () => yieldRepository.getPoolInfo(
          poolAddress: poolAddress,
          poolNetwork: poolNetwork,
          parseWrappedToNative: parseWrappedToNative,
        ),
      ).called(1);
    },
  );

  test(
    """When instaciating the cubit, and there is a pool coming from the arguments,
    it should assign it to the yieldpool variable and not fetch the pool info from the repository""",
    () {
      final pool = LiquidityPoolDto.fixture().copyWith(poolAddress: "jajajajaja");

      when(() => navigator.currentPageArguments).thenReturn(DepositPageArgumentsDto(yieldPool: pool).toJson());

      sut = DepositCubit(yieldRepository, zupSingletonCache, wallet, cache, poolService, navigator);

      expect(sut.yieldPool, pool);

      verifyNever(
        () => yieldRepository.getPoolInfo(
          poolAddress: any(named: "poolAddress"),
          poolNetwork: any(named: "poolNetwork"),
          parseWrappedToNative: any(named: "parseWrappedToNative"),
        ),
      );
    },
  );

  test(
    """When instaciating the cubit, and there is a pool coming from the arguments,
    it should emit a new pool sqrt price got from the yield dto""",
    () async {
      final expectedSqrtPriceX96 = BigInt.from(989998899);
      final pool = LiquidityPoolDto.fixture().copyWith(
        poolAddress: "jajajajaja",
        latestSqrtPriceX96: expectedSqrtPriceX96.toString(),
      );

      when(() => navigator.currentPageArguments).thenReturn(DepositPageArgumentsDto(yieldPool: pool).toJson());

      await expectLater(
        DepositCubit(yieldRepository, zupSingletonCache, wallet, cache, poolService, navigator).poolSqrtPriceX96Stream,
        emits(expectedSqrtPriceX96),
      );
    },
  );

  test(
    """When instaciating the cubit, and there is a pool coming from the arguments,
    it should assign the pool sqrt price to the latest pool sqrt price variable""",
    () async {
      final expectedSqrtPriceX96 = BigInt.from(5545529927344);
      final pool = LiquidityPoolDto.fixture().copyWith(
        poolAddress: "jajajajaja",
        latestSqrtPriceX96: expectedSqrtPriceX96.toString(),
      );

      when(() => navigator.currentPageArguments).thenReturn(DepositPageArgumentsDto(yieldPool: pool).toJson());

      final cubit = DepositCubit(yieldRepository, zupSingletonCache, wallet, cache, poolService, navigator);

      expect(cubit.latestPoolSqrtPriceX96, expectedSqrtPriceX96);
    },
  );

  test(
    """When instaciating the cubit, and there is a pool coming from the arguments,
    it should emit the success state passing the pool from the arguments""",
    () async {
      final pool = LiquidityPoolDto.fixture().copyWith(poolAddress: "someel cool pool idool");

      when(() => navigator.currentPageArguments).thenReturn(DepositPageArgumentsDto(yieldPool: pool).toJson());

      final cubit = DepositCubit(yieldRepository, zupSingletonCache, wallet, cache, poolService, navigator);

      expect(cubit.state, DepositState.success(pool));
    },
  );

  test(
    """When calling 'getPoolSqrtPriceX96' it should use the zup singleton cache to get the pool sqrt price,
  with a expiration of 29 seconds""",
    () async {
      final mockZupSingletonCache = ZupSingletonCacheMock();

      when(
        () => mockZupSingletonCache.run<BigInt>(
          any(),
          expiration: any(named: "expiration"),
          ignoreCache: any(named: "ignoreCache"),
          key: any(named: "key"),
        ),
      ).thenAnswer((_) async => BigInt.from(989998899));

      final cubit = DepositCubit(yieldRepository, mockZupSingletonCache, wallet, cache, poolService, navigator);
      await cubit.getPoolSqrtPriceX96();

      verify(
        () => mockZupSingletonCache.run<BigInt>(
          any(),
          expiration: 29.seconds,
          ignoreCache: any(named: "ignoreCache"),
          key: any(named: "key"),
        ),
      ).called(1);
    },
  );

  test(
    """When calling 'getPoolSqrtPriceX96' with ignore cache true, it should use the zup singleton
    cache to get the pool sqrt price, passing ignoreCache to true""",
    () async {
      final mockZupSingletonCache = ZupSingletonCacheMock();

      when(
        () => mockZupSingletonCache.run<BigInt>(
          any(),
          expiration: any(named: "expiration"),
          ignoreCache: any(named: "ignoreCache"),
          key: any(named: "key"),
        ),
      ).thenAnswer((_) async => BigInt.from(989998899));

      final cubit = DepositCubit(yieldRepository, mockZupSingletonCache, wallet, cache, poolService, navigator);
      await cubit.getPoolSqrtPriceX96(forceRefresh: true);

      verify(
        () => mockZupSingletonCache.run<BigInt>(
          any(),
          expiration: any(named: "expiration"),
          ignoreCache: true,
          key: any(named: "key"),
        ),
      ).called(1);
    },
  );

  test(
    """When calling 'getPoolSqrtPriceX96' with ignore cache true, it should use the zup singleton
    cache to get the pool sqrt price, passing the correct key""",
    () async {
      final mockZupSingletonCache = ZupSingletonCacheMock();

      when(
        () => mockZupSingletonCache.run<BigInt>(
          any(),
          expiration: any(named: "expiration"),
          ignoreCache: any(named: "ignoreCache"),
          key: any(named: "key"),
        ),
      ).thenAnswer((_) async => BigInt.from(989998899));

      final cubit = DepositCubit(yieldRepository, mockZupSingletonCache, wallet, cache, poolService, navigator);
      await cubit.getPoolSqrtPriceX96(forceRefresh: true);

      verify(
        () => mockZupSingletonCache.run<BigInt>(
          any(),
          expiration: any(named: "expiration"),
          ignoreCache: true,
          key: "sqrtPrice-${cubit.yieldPool!.poolAddress}-${cubit.yieldPool!.network.name}",
        ),
      ).called(1);
    },
  );
}
