import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zup_app/core/enums/networks.dart';

part 'multi_chain_token_dto.freezed.dart';
part 'multi_chain_token_dto.g.dart';

@freezed
sealed class MultiChainTokenDto with _$MultiChainTokenDto {
  @JsonSerializable(explicitToJson: true)
  const factory MultiChainTokenDto({
    @JsonKey(name: "id") String? internalId,
    @Default("") String symbol,
    @Default("") String name,
    @Default("") String logoUrl,
    @Default({}) Map<int, String?> addresses,
    @Default({}) Map<int, int?> decimals,
  }) = _MultiChainTokenDto;

  factory MultiChainTokenDto.fromJson(Map<String, dynamic> json) => _$MultiChainTokenDtoFromJson(json);

  factory MultiChainTokenDto.empty() => const MultiChainTokenDto();

  factory MultiChainTokenDto.fixture() => MultiChainTokenDto(
    symbol: 'WETH',
    name: 'Wrapped Ether',
    decimals: Map.fromEntries(
      AppNetworks.values.where((network) => !network.isAllNetworks).map((network) {
        return MapEntry(network.chainId, 18);
      }),
    ),
    addresses: Map.fromEntries(
      AppNetworks.values.where((network) => !network.isAllNetworks).map((network) {
        return MapEntry(network.chainId, "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2");
      }),
    ),
    logoUrl:
        'https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2/logo.png',
  );
}
