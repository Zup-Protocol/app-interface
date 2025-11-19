import 'package:dio/dio.dart';
import 'package:zup_app/core/dtos/multi_chain_token_dto.dart';
import 'package:zup_app/core/dtos/single_chain_token_dto.dart';
import 'package:zup_app/core/dtos/token_list_dto.dart';
import 'package:zup_app/core/dtos/token_price_dto.dart';
import 'package:zup_app/core/enums/networks.dart';

class TokensRepository {
  TokensRepository(this._zupAPIDio);

  final Dio _zupAPIDio;
  bool isSearchingTokens = false;
  CancelToken? _searchTokenLastCancelToken;

  Future<TokenListDto> getTokenList(AppNetworks network) async {
    final request = await _zupAPIDio.get(
      "/tokens/list",
      queryParameters: {if (!network.isAllNetworks) "chainId": int.parse(network.chainInfo.hexChainId)},
    );

    return TokenListDto.fromJson(request.data);
  }

  Future<List<MultiChainTokenDto>> searchToken(String query, AppNetworks network) async {
    if (_searchTokenLastCancelToken != null) _searchTokenLastCancelToken!.cancel();

    _searchTokenLastCancelToken = CancelToken();

    if (network.isAllNetworks) {
      final allNetworksResponse = await _zupAPIDio.get(
        "/tokens/search/all",
        cancelToken: _searchTokenLastCancelToken,
        queryParameters: {"query": query},
      );

      _searchTokenLastCancelToken = null;
      return (allNetworksResponse.data as List<dynamic>).map((token) => MultiChainTokenDto.fromJson(token)).toList();
    }

    final singleNetworkResponse = await _zupAPIDio.get(
      "/tokens/search/${network.chainId}",
      cancelToken: _searchTokenLastCancelToken,
      queryParameters: {"query": query},
    );

    _searchTokenLastCancelToken = null;
    return (singleNetworkResponse.data as List<dynamic>).map((token) {
      final singleChainToken = SingleChainTokenDto.fromJson(token);

      return MultiChainTokenDto(
        addresses: {network.chainId: singleChainToken.address},
        decimals: {network.chainId: singleChainToken.decimals},
        logoUrl: singleChainToken.logoUrl,
        name: singleChainToken.name,
        symbol: singleChainToken.symbol,
      );
    }).toList();
  }

  Future<TokenPriceDto> getTokenPrice(String address, AppNetworks network) async {
    final response = await _zupAPIDio.get("/tokens/$address/${network.chainId}/price");

    return TokenPriceDto.fromJson(response.data);
  }
}
