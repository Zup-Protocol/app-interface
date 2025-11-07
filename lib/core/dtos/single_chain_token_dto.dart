import 'package:freezed_annotation/freezed_annotation.dart';

part 'single_chain_token_dto.freezed.dart';
part 'single_chain_token_dto.g.dart';

@freezed
sealed class SingleChainTokenDto with _$SingleChainTokenDto {
  @JsonSerializable(explicitToJson: true)
  const factory SingleChainTokenDto({
    required String address,
    @Default(18) int decimals,
    @Default("") String name,
    @Default("") String symbol,
    @Default("") String logoUrl,
  }) = _SingleChainTokenDto;

  factory SingleChainTokenDto.fromJson(Map<String, dynamic> json) => _$SingleChainTokenDtoFromJson(json);

  factory SingleChainTokenDto.fixture() => const SingleChainTokenDto(
    address: '0x0000000000000000000000000000000000000000',
    decimals: 18,
    name: 'Test Token',
    symbol: 'TEST',
  );
}
