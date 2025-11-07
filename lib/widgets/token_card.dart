import 'package:flutter/material.dart';
import 'package:zup_app/core/dtos/multi_chain_token_dto.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_core/extensions/extensions.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

class TokenCard extends StatefulWidget {
  const TokenCard({super.key, required this.asset, required this.onClick});

  final MultiChainTokenDto asset;
  final Function() onClick;

  @override
  State<TokenCard> createState() => _TokenCardState();
}

class _TokenCardState extends State<TokenCard> {
  bool isHovering = false;

  final zupNetworkImage = inject<ZupNetworkImage>();

  @override
  Widget build(BuildContext context) {
    return ZupSelectableCard(
      onPressed: () {
        widget.onClick();
      },
      onHoverChanged: (value) {
        setState(() => isHovering = value);
      },
      child: Row(
        children: [
          ZupRemoteAvatar(
            avatarUrl: widget.asset.logoUrl,
            errorPlaceholder: widget.asset.name[0],
            size: 35,
            zupNetworkImage: zupNetworkImage,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      widget.asset.symbol,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: isHovering ? ZupColors.brand : ZupThemeColors.primaryText.themed(context.brightness),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [Text(widget.asset.name, style: const TextStyle(fontSize: 14, color: ZupColors.gray))],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
