import 'package:flutter/material.dart';
import 'package:zup_app/core/dtos/single_chain_token_dto.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_ui_kit/zup_network_image.dart';
import 'package:zup_ui_kit/zup_remote_avatar.dart';

class PoolToken extends StatelessWidget {
  PoolToken({super.key, required this.token});

  final SingleChainTokenDto token;
  final zupNetworkImage = inject<ZupNetworkImage>();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ZupRemoteAvatar(
          avatarUrl: token.logoUrl,
          errorPlaceholder: token.name[0],
          size: 30,
          zupNetworkImage: zupNetworkImage,
        ),
        const SizedBox(width: 10),
        Text(token.symbol, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
