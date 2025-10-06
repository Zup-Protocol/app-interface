import 'package:freezed_annotation/freezed_annotation.dart';

part 'deposit_page_path_params.freezed.dart';
part 'deposit_page_path_params.g.dart';

@freezed
sealed class DepositPagePathParamsDto with _$DepositPagePathParamsDto {
  static const String poolAddressQueryKey = "id";

  @JsonSerializable(explicitToJson: true)
  factory DepositPagePathParamsDto({
    @JsonKey(name: DepositPagePathParamsDto.poolAddressQueryKey) required String poolAddress,
  }) = _DepositPagePathParamsDto;

  factory DepositPagePathParamsDto.fromJson(Map<String, dynamic> json) => _$DepositPagePathParamsDtoFromJson(json);
}
