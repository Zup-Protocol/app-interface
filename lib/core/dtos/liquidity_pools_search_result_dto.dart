import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zup_app/core/dtos/liquidity_pool_dto.dart';
import 'package:zup_app/core/dtos/pool_search_filters_dto.dart';
import 'package:zup_app/core/dtos/pool_stats_dto.dart';
import 'package:zup_app/core/dtos/protocol_dto.dart';
import 'package:zup_app/core/dtos/single_chain_token_dto.dart';
import 'package:zup_app/core/enums/pool_data_timeframe.dart';
import 'package:zup_app/core/enums/pool_type.dart';
import 'package:zup_app/core/enums/protocol_id.dart';

part 'liquidity_pools_search_result_dto.freezed.dart';
part 'liquidity_pools_search_result_dto.g.dart';

@freezed
sealed class LiquidityPoolsSearchResultDto with _$LiquidityPoolsSearchResultDto {
  const LiquidityPoolsSearchResultDto._();

  @JsonSerializable(explicitToJson: true)
  const factory LiquidityPoolsSearchResultDto({
    @Default(<LiquidityPoolDto>[]) @JsonKey(name: "pools") List<LiquidityPoolDto> pools,
    @Default(PoolSearchFiltersDto()) PoolSearchFiltersDto filters,
  }) = _LiquidityPoolsSearchResultDto;

  bool get isEmpty => pools.isEmpty;

  List<LiquidityPoolDto> get poolsSortedBy24hYield {
    return [...pools]..sort((a, b) => b.total24hStats?.yearlyYield.compareTo(a.total24hStats?.yearlyYield ?? 0) ?? 0);
  }

  List<LiquidityPoolDto> get poolsSortedBy7dYield {
    return [...pools]..sort((a, b) => b.total7dStats?.yearlyYield.compareTo(a.total7dStats?.yearlyYield ?? 0) ?? 0);
  }

  List<LiquidityPoolDto> get poolsSortedBy30dYield {
    return [...pools]..sort((a, b) => b.total30dStats?.yearlyYield.compareTo(a.total30dStats?.yearlyYield ?? 0) ?? 0);
  }

  List<LiquidityPoolDto> get poolsSortedBy90dYield {
    return [...pools]..sort((a, b) => b.total90dStats?.yearlyYield.compareTo(a.total90dStats?.yearlyYield ?? 0) ?? 0);
  }

  List<LiquidityPoolDto> poolsSortedByTimeframe(PoolDataTimeframe timeframe) {
    switch (timeframe) {
      case PoolDataTimeframe.day:
        return poolsSortedBy24hYield;
      case PoolDataTimeframe.week:
        return poolsSortedBy7dYield;
      case PoolDataTimeframe.month:
        return poolsSortedBy30dYield;
      case PoolDataTimeframe.threeMonth:
        return poolsSortedBy90dYield;
    }
  }

  factory LiquidityPoolsSearchResultDto.fromJson(Map<String, dynamic> json) =>
      _$LiquidityPoolsSearchResultDtoFromJson(json);

  factory LiquidityPoolsSearchResultDto.empty() => const LiquidityPoolsSearchResultDto(pools: []);

  factory LiquidityPoolsSearchResultDto.fixture() => LiquidityPoolsSearchResultDto(
    filters: PoolSearchFiltersDto.fixture(),
    pools: [
      LiquidityPoolDto(
        createdAtTimestamp: DateTime(1992).millisecondsSinceEpoch,
        latestTick: "637812562",
        latestSqrtPriceX96: "5240418162556390792557189",
        positionManagerAddress: "0x06eFdBFf2a14a7c8E15944D1F4A48F9F95F663A4",
        poolType: PoolType.v3,
        total24hStats: PoolTotalStatsDTO.fixture(),
        total7dStats: PoolTotalStatsDTO.fixture(),
        total30dStats: PoolTotalStatsDTO.fixture(),
        total90dStats: PoolTotalStatsDTO.fixture(),
        token0: const SingleChainTokenDto(
          address: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
          decimals: 18,
          name: "Wrapped Ether",
          symbol: "WETH",
          logoUrl:
              "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/scroll/assets/0x5300000000000000000000000000000000000004/logo.png",
        ),
        token1: const SingleChainTokenDto(
          address: "0xdAC17F958D2ee523a2206206994597C13D831ec7",
          decimals: 6,
          logoUrl:
              "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/scroll/assets/0x06eFdBFf2a14a7c8E15944D1F4A48F9F95F663A4/logo.png",
          name: "USDC",
          symbol: "USDC",
        ),
        chainId: 1,
        poolAddress: "0x4040CE732c1A538A4Ac3157FDC35179D73ea76cd",
        tickSpacing: 10,

        totalValueLockedUSD: 65434567890.21,
        initialFeeTier: 500,
        currentFeeTier: 500,
        protocol: ProtocolDto(
          id: ProtocolId.pancakeSwapInfinityCL,
          rawId: ProtocolId.pancakeSwapInfinityCL.toRawJsonValue,
          name: "PancakeSwap",
          logo: "https://raw.githubusercontent.com/trustwallet/assets/master/dapps/exchange.pancakeswap.finance.png",
        ),
      ),
    ],
  );
}
