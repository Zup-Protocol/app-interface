import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/core/cache.dart';
import 'package:zup_app/core/concentrated_liquidity_utils/cl_pool_conversors_mixin.dart';
import 'package:zup_app/core/dtos/deposit_page_arguments_dto.dart';
import 'package:zup_app/core/dtos/deposit_settings_dto.dart';
import 'package:zup_app/core/dtos/pool_search_settings_dto.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/mixins/keys_mixin.dart';
import 'package:zup_app/core/pool_service.dart';
import 'package:zup_app/core/repositories/yield_repository.dart';
import 'package:zup_app/core/slippage.dart';
import 'package:zup_app/core/zup_navigator.dart';
import 'package:zup_app/core/zup_route_params_names.dart';
import 'package:zup_core/zup_core.dart';

part 'deposit_cubit.freezed.dart';
part 'deposit_state.dart';

class DepositCubit extends Cubit<DepositState> with KeysMixin, CLPoolConversorsMixin {
  DepositCubit(
    this._yieldRepository,
    this._zupSingletonCache,
    this._wallet,
    this._cache,
    this._poolService,
    this._navigator,
  ) : super(const DepositState.initial()) {
    final yieldPoolFromArguments = DepositPageArgumentsDto.fromJson(_navigator.currentPageArguments).yieldPool;

    if (yieldPoolFromArguments != null) {
      yieldPool = yieldPoolFromArguments;
      _latestPoolSqrtPriceX96 = BigInt.parse(yieldPoolFromArguments.latestSqrtPriceX96);

      Future.microtask(
        () => _poolSqrtPriceX96StreamController.add(BigInt.parse(yieldPoolFromArguments.latestSqrtPriceX96)),
      );

      emit(DepositState.success(yieldPoolFromArguments));
    } else {
      fetchCurrentPoolInfo();
    }
  }

  final YieldRepository _yieldRepository;
  final ZupNavigator _navigator;
  final ZupSingletonCache _zupSingletonCache;
  final Wallet _wallet;
  final PoolService _poolService;
  final Cache _cache;

  final StreamController<BigInt?> _poolSqrtPriceX96StreamController = StreamController.broadcast();
  final Duration _poolSqrtPriceX96CacheExpiration = const Duration(seconds: 30);

  BigInt? _latestPoolSqrtPriceX96;
  YieldDto? yieldPool;

  late final Stream<BigInt?> poolSqrtPriceX96Stream = _poolSqrtPriceX96StreamController.stream;

  BigInt? get latestPoolSqrtPriceX96 => _latestPoolSqrtPriceX96;
  DepositSettingsDto get depositSettings => _cache.getDepositSettings();
  PoolSearchSettingsDto get poolSearchSettings => _cache.getPoolSearchSettings();

  void setup() async {
    Timer.periodic(_poolSqrtPriceX96CacheExpiration, (timer) {
      if (_poolSqrtPriceX96StreamController.isClosed) return timer.cancel();

      if (yieldPool != null) getPoolSqrtPriceX96();
    });
  }

  Future<void> fetchCurrentPoolInfo() async {
    try {
      emit(const DepositState.loading());

      final poolNetwork = AppNetworks.fromValue(_navigator.getQueryParam(DepositRouteParamsNames().network) ?? "");
      final poolAddress = _navigator.getIdFromPath;
      final parseWrappedToNative =
          bool.tryParse(_navigator.getQueryParam(DepositRouteParamsNames().parseWrappedToNative).toString()) ?? true;

      final pool = await _yieldRepository.getPoolInfo(
        poolAddress: poolAddress!,
        poolNetwork: poolNetwork!,
        parseWrappedToNative: parseWrappedToNative,
      );

      yieldPool = pool;

      await getPoolSqrtPriceX96();

      emit(DepositState.success(pool));
    } catch (e) {
      emit(const DepositState.error());
    }
  }

  Future<void> getPoolSqrtPriceX96({bool forceRefresh = false}) async {
    final sqrtPriceX96 = await _zupSingletonCache.run(
      () => _poolService.getSqrtPriceX96(yieldPool!),
      expiration: _poolSqrtPriceX96CacheExpiration - const Duration(seconds: 1),
      ignoreCache: forceRefresh,
      key: poolSqrtPriceCacheKey(network: yieldPool!.network, poolAddress: yieldPool!.poolAddress),
    );

    _poolSqrtPriceX96StreamController.add(sqrtPriceX96);
    _latestPoolSqrtPriceX96 = sqrtPriceX96;
  }

  Future<double> getWalletTokenAmount(String tokenAddress, {required AppNetworks network}) async {
    if (_wallet.signer == null) return 0.0;

    final walletAddress = await _wallet.signer!.address;

    return await _zupSingletonCache.run(
      () async {
        try {
          return await _wallet.nativeOrTokenBalance(tokenAddress, rpcUrl: network.rpcUrl);
        } catch (_) {
          return 0.0;
        }
      },
      key: userTokenBalanceCacheKey(
        tokenAddress: tokenAddress,
        userAddress: walletAddress,
        isNative: tokenAddress == EthereumConstants.zeroAddress,
        network: network,
      ),
      expiration: const Duration(minutes: 10),
    );
  }

  Future<void> saveDepositSettings(Slippage slippage, Duration deadline) async {
    await _cache.saveDepositSettings(
      DepositSettingsDto(deadlineMinutes: deadline.inMinutes, maxSlippage: slippage.value.toDouble()),
    );
  }

  @override
  Future<void> close() async {
    await _poolSqrtPriceX96StreamController.close();
    return super.close();
  }
}
