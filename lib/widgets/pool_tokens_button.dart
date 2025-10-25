import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';
import 'package:zup_app/widgets/pool_tokens_avatar.dart';
import 'package:zup_core/extensions/extensions.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

class PoolTokensButton extends StatelessWidget {
  const PoolTokensButton({super.key, required this.liquidityPool});

  final YieldDto liquidityPool;

  bool get canLaunchAtDexscreener => liquidityPool.network.dexscreenerUrl != null;

  @override
  Widget build(BuildContext context) {
    return ZupTooltip.text(
      message: canLaunchAtDexscreener ? S.of(context).poolTokensButtonViewAtDexcreener : "",
      margin: const EdgeInsets.only(top: 10),
      constraints: const BoxConstraints(maxWidth: 200),
      child: ZupOutlinedButton(
        onPressed: canLaunchAtDexscreener
            ? () => launchUrl(Uri.parse("${liquidityPool.network.dexscreenerUrl}/${liquidityPool.poolAddress}"))
            : null,
        leadingIconSpacing: 5,
        title: Text(
          "${liquidityPool.token0.symbol.clamped(8)}/${liquidityPool.token1.symbol.clamped(8)}",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: canLaunchAtDexscreener ? ZupColors.brand : ZupThemeColors.primaryText.themed(context.brightness),
            fontSize: 16,
          ),
        ),
        trailingIcon: canLaunchAtDexscreener
            ? Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ZupThemeColors.backgroundInverse.themed(context.brightness),
                ),
                child: Assets.logos.dexscreener.svg(
                  height: 15,
                  width: 15,
                  colorFilter: ColorFilter.mode(ZupThemeColors.background.themed(context.brightness), BlendMode.srcIn),
                ),
              )
            : null,
        leadingIcon: PoolTokensAvatar(liquidityPool: liquidityPool),
      ),
    );
  }
}
