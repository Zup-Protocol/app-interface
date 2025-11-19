import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zup_app/core/dtos/liquidity_pool_dto.dart';

part 'deposit_page_arguments_dto.freezed.dart';
part 'deposit_page_arguments_dto.g.dart';

@freezed
sealed class DepositPageArgumentsDto with _$DepositPageArgumentsDto {
  @JsonSerializable(explicitToJson: true)
  const factory DepositPageArgumentsDto({LiquidityPoolDto? yieldPool}) = _DepositPageArgumentsDto;

  factory DepositPageArgumentsDto.fromJson(Map<String, dynamic> json) => _$DepositPageArgumentsDtoFromJson(json);
}
