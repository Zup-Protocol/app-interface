import 'package:freezed_annotation/freezed_annotation.dart';

part 'pool_search_filters_dto.freezed.dart';
part 'pool_search_filters_dto.g.dart';

@freezed
sealed class PoolSearchFiltersDto with _$PoolSearchFiltersDto {
  @JsonSerializable(explicitToJson: true)
  const factory PoolSearchFiltersDto({@Default(0) num minTvlUsd, @Default(<String>[]) List<String> blockedProtocols}) =
      _PoolSearchFiltersDto;

  const PoolSearchFiltersDto._();

  factory PoolSearchFiltersDto.fromJson(Map<String, dynamic> json) => _$PoolSearchFiltersDtoFromJson(json);

  factory PoolSearchFiltersDto.fixture() =>
      const PoolSearchFiltersDto(blockedProtocols: ["nuri-exchange"], minTvlUsd: 121782617);
}
