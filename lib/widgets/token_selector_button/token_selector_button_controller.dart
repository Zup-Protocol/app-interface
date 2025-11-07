import 'dart:async';

import 'package:async/async.dart' show StreamGroup;
import 'package:zup_app/core/dtos/multi_chain_token_dto.dart';
import 'package:zup_app/core/dtos/token_group_dto.dart';

class TokenSelectorButtonController {
  MultiChainTokenDto? _selectedToken;
  TokenGroupDto? _selectedTokenGroup;

  final StreamController<MultiChainTokenDto?> _selectedTokenStreamController =
      StreamController<MultiChainTokenDto?>.broadcast();
  final StreamController<TokenGroupDto?> _selectedTokenGroupStreamController =
      StreamController<TokenGroupDto?>.broadcast();

  bool get hasSelection => _selectedToken != null || _selectedTokenGroup != null;

  MultiChainTokenDto? get selectedToken => _selectedToken;
  TokenGroupDto? get selectedTokenGroup => _selectedTokenGroup;

  Stream<MultiChainTokenDto?> get selectedTokenStream => _selectedTokenStreamController.stream;
  Stream<TokenGroupDto?> get selectedTokenGroupStream => _selectedTokenGroupStreamController.stream;
  Stream get selectionStream => StreamGroup.mergeBroadcast([selectedTokenStream, selectedTokenGroupStream]);

  void changeToken(MultiChainTokenDto? newToken) {
    if (newToken == _selectedToken) return;

    _selectedToken = newToken;
    _selectedTokenGroup = null;

    _selectedTokenStreamController.add(_selectedToken);
    _selectedTokenGroupStreamController.add(null);
  }

  void changeTokenGroup(TokenGroupDto? newTokenGroup) {
    if (newTokenGroup == _selectedTokenGroup) return;

    _selectedToken = null;
    _selectedTokenGroup = newTokenGroup;

    _selectedTokenGroupStreamController.add(_selectedTokenGroup);
    _selectedTokenStreamController.add(null);
  }
}
