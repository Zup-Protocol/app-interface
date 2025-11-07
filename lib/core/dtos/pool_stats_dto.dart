import 'package:freezed_annotation/freezed_annotation.dart';

part 'pool_stats_dto.freezed.dart';
part 'pool_stats_dto.g.dart';

@freezed
sealed class PoolTotalStatsDTO with _$PoolTotalStatsDTO {
  @JsonSerializable(explicitToJson: true)
  const factory PoolTotalStatsDTO({
    @Default(0) num totalVolume,
    @Default(0) num totalFees,
    @Default(0) @JsonKey(name: "yield") num yearlyYield,
    @Default(0) num totalNetInflow,
  }) = _PoolTotalStatsDTO;

  factory PoolTotalStatsDTO.fromJson(Map<String, dynamic> json) => _$PoolTotalStatsDTOFromJson(json);

  factory PoolTotalStatsDTO.fixture() => const PoolTotalStatsDTO(totalVolume: 100, totalFees: 10, yearlyYield: 10);
}
