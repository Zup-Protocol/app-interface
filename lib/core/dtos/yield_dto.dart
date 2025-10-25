import 'package:clock/clock.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:web3kit/core/ethereum_constants.dart';
import 'package:zup_app/core/concentrated_liquidity_utils/cl_pool_constants.dart';
import 'package:zup_app/core/dtos/hook_dto.dart';
import 'package:zup_app/core/dtos/pool_stats_dto.dart';
import 'package:zup_app/core/dtos/protocol_dto.dart';
import 'package:zup_app/core/dtos/single_chain_token_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/enums/pool_data_timeframe.dart';
import 'package:zup_app/core/enums/pool_type.dart';
import 'package:zup_app/core/extensions/num_extension.dart';

part 'yield_dto.freezed.dart';
part 'yield_dto.g.dart';

@freezed
sealed class YieldDto with _$YieldDto {
  const YieldDto._();
  @JsonSerializable(explicitToJson: true)
  const factory YieldDto({
    required SingleChainTokenDto token0,
    required SingleChainTokenDto token1,
    required String poolAddress,
    required String positionManagerAddress,
    required int tickSpacing,
    required ProtocolDto protocol,
    required int initialFeeTier,
    required int currentFeeTier,
    required int chainId,
    PoolTotalStatsDTO? total24hStats,
    PoolTotalStatsDTO? total7dStats,
    PoolTotalStatsDTO? total30dStats,
    PoolTotalStatsDTO? total90dStats,
    HookDto? hook,
    @Default(0) int createdAtTimestamp,
    @Default(PoolType.unknown) @JsonKey(unknownEnumValue: PoolType.unknown) PoolType poolType,
    @Default("0") String latestTick,
    @Default("0") String latestSqrtPriceX96,
    @Default(0) num totalValueLockedUSD,
    @Default(EthereumConstants.zeroAddress) @JsonKey(name: "deployerAddress") String deployerAddress,
    @JsonKey(name: "poolManagerAddress") String? v4PoolManager,
    @JsonKey(name: "stateViewAddress") String? v4StateView,
    @JsonKey(name: "permit2Address") String? permit2,
  }) = _YieldDto;

  AppNetworks get network => AppNetworks.fromChainId(chainId)!;

  bool get isToken0Native => token0.address == EthereumConstants.zeroAddress;
  bool get isToken1Native => token1.address == EthereumConstants.zeroAddress;

  String get currentFeeTierFormatted {
    return "${(currentFeeTier / CLPoolConstants.feeTierFactor)}%";
  }

  bool get isDynamicFee => hook?.isDynamicFee ?? false;

  int get createdAtMillisecondsTimestamp => createdAtTimestamp * 1000;

  String timeframedYieldFormatted(PoolDataTimeframe yieldTimeFrame) {
    switch (yieldTimeFrame) {
      case PoolDataTimeframe.day:
        return total24hStats?.yearlyYield == 0 ? "-" : total24hStats?.yearlyYield.formatRoundingPercent ?? "-";
      case PoolDataTimeframe.week:
        return total7dStats?.yearlyYield == 0 ? "-" : total7dStats?.yearlyYield.formatRoundingPercent ?? "-";
      case PoolDataTimeframe.month:
        return total30dStats?.yearlyYield == 0 ? "-" : total30dStats?.yearlyYield.formatRoundingPercent ?? "-";
      case PoolDataTimeframe.threeMonth:
        return total90dStats?.yearlyYield == 0 ? "-" : total90dStats?.yearlyYield.formatRoundingPercent ?? "-";
    }
  }

  num volumeTimeframed(PoolDataTimeframe yieldTimeFrame) {
    switch (yieldTimeFrame) {
      case PoolDataTimeframe.day:
        return total24hStats?.totalVolume ?? 0;
      case PoolDataTimeframe.week:
        return total7dStats?.totalVolume ?? 0;
      case PoolDataTimeframe.month:
        return total30dStats?.totalVolume ?? 0;
      case PoolDataTimeframe.threeMonth:
        return total90dStats?.totalVolume ?? 0;
    }
  }

  num feesTimeframed(PoolDataTimeframe yieldTimeFrame) {
    switch (yieldTimeFrame) {
      case PoolDataTimeframe.day:
        return total24hStats?.totalFees ?? 0;
      case PoolDataTimeframe.week:
        return total7dStats?.totalFees ?? 0;
      case PoolDataTimeframe.month:
        return total30dStats?.totalFees ?? 0;
      case PoolDataTimeframe.threeMonth:
        return total90dStats?.totalFees ?? 0;
    }
  }

  num netInflowTimeframed(PoolDataTimeframe yieldTimeFrame) {
    switch (yieldTimeFrame) {
      case PoolDataTimeframe.day:
        return total24hStats?.totalNetInflow ?? 0;
      case PoolDataTimeframe.week:
        return total7dStats?.totalNetInflow ?? 0;
      case PoolDataTimeframe.month:
        return total30dStats?.totalNetInflow ?? 0;
      case PoolDataTimeframe.threeMonth:
        return total90dStats?.totalNetInflow ?? 0;
    }
  }

  num yieldTimeframed(PoolDataTimeframe yieldTimeFrame) {
    switch (yieldTimeFrame) {
      case PoolDataTimeframe.day:
        return total24hStats?.yearlyYield ?? 0;
      case PoolDataTimeframe.week:
        return total7dStats?.yearlyYield ?? 0;
      case PoolDataTimeframe.month:
        return total30dStats?.yearlyYield ?? 0;
      case PoolDataTimeframe.threeMonth:
        return total90dStats?.yearlyYield ?? 0;
    }
  }

  factory YieldDto.fromJson(Map<String, dynamic> json) => _$YieldDtoFromJson(json);

  factory YieldDto.fixture() => YieldDto(
    initialFeeTier: 0,
    currentFeeTier: 0,
    createdAtTimestamp: (clock.now().copyWith(year: 2024, month: 2, day: 23).millisecondsSinceEpoch / 1000).toInt(),
    total24hStats: PoolTotalStatsDTO.fixture(),
    total7dStats: PoolTotalStatsDTO.fixture(),
    total30dStats: PoolTotalStatsDTO.fixture(),
    total90dStats: PoolTotalStatsDTO.fixture(),
    latestTick: "1567241",
    positionManagerAddress: "0x5Df2f0aFb5b5bB2Df9D1e9C7b6f5f0DD5f9eD5e0",
    poolAddress: "0x5Df2f0aFb5b5bB2Df9D1e9C7b6f5f0DD5f9eD5e0",
    poolType: PoolType.v3,
    token0: SingleChainTokenDto.fixture().copyWith(
      symbol: "USDC",
      decimals: 6,
      address: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
      logoUrl:
          "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48/logo.png",
    ),
    token1: SingleChainTokenDto.fixture().copyWith(
      symbol: "WETH",
      decimals: 18,
      address: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
      logoUrl:
          "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2/logo.png",
    ),
    tickSpacing: 10,
    protocol: ProtocolDto.fixture(),
    chainId: AppNetworks.sepolia.chainId,
  );
}
