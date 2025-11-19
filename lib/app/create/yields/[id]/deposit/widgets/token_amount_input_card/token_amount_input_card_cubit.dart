import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zup_app/core/dtos/single_chain_token_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/mixins/keys_mixin.dart';
import 'package:zup_app/core/repositories/tokens_repository.dart';
import 'package:zup_core/zup_core.dart';

part 'token_amount_input_card_cubit.freezed.dart';
part 'token_amount_input_card_state.dart';

class TokenAmountInputCardCubit extends Cubit<TokenAmountInputCardState> with KeysMixin {
  TokenAmountInputCardCubit(this._tokensRepository, this._zupSingletonCache, this._zupHolder)
    : super(const TokenAmountInputCardState.initial());

  final TokensRepository _tokensRepository;
  final ZupSingletonCache _zupSingletonCache;
  final ZupHolder _zupHolder;

  Future<num> getTokenPrice({required SingleChainTokenDto token, required AppNetworks network}) async {
    try {
      return await _zupHolder.hold(
        () async => await _zupSingletonCache.run(
          () async => (await _tokensRepository.getTokenPrice(token.address, network)).usdPrice,
          expiration: const Duration(minutes: 1),
          key: tokenPriceCacheKey(tokenAddress: token.address, network: network),
        ),
      );
    } catch (_) {
      return 0;
    }
  }
}
