import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:web3kit/core/ethereum_constants.dart';

part 'hook_dto.freezed.dart';
part 'hook_dto.g.dart';

@freezed
sealed class HookDto with _$HookDto {
  @JsonSerializable(explicitToJson: true)
  const factory HookDto({@Default(EthereumConstants.zeroAddress) String address, @Default(false) bool isDynamicFee}) =
      _HookDto;

  factory HookDto.fromJson(Map<String, dynamic> json) => _$HookDtoFromJson(json);

  factory HookDto.fixture() => const HookDto(address: EthereumConstants.zeroAddress, isDynamicFee: false);
}
