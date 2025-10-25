part of '../pool_info_modal.dart';

class _AboutPage extends StatefulWidget {
  const _AboutPage(this.liquidityPool);

  final YieldDto liquidityPool;

  @override
  State<_AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<_AboutPage> with DeviceInfoMixin {
  final zupNetworkImage = inject<ZupNetworkImage>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Wrap(
          runSpacing: 10,
          children: [
            ZupTooltip.text(
              message: isMobileDevice
                  ? S
                        .of(context)
                        .poolInfoModalAboutPageFeeDescription(
                          isDynamicFee: widget.liquidityPool.isDynamicFee.toString(),
                          formattedFee: widget.liquidityPool.currentFeeTierFormatted,
                        )
                  : "",
              child: ZupTitledValueTag(
                value: widget.liquidityPool.isDynamicFee ? "Dynamic" : widget.liquidityPool.currentFeeTierFormatted,
                title: S.of(context).poolInfoModalAboutPageFee,
                trailingIcon: ZupTooltip.text(
                  key: const Key("fee-tooltip"),
                  message: S
                      .of(context)
                      .poolInfoModalAboutPageFeeDescription(
                        isDynamicFee: widget.liquidityPool.isDynamicFee.toString(),
                        formattedFee: widget.liquidityPool.currentFeeTierFormatted,
                      ),
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: Assets.icons.infoCircle.svg(
                    height: 15,
                    width: 15,
                    colorFilter: const ColorFilter.mode(ZupColors.gray, BlendMode.srcIn),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ZupTooltip.text(
              message: isMobileDevice ? widget.liquidityPool.poolType.description(context) : "",
              child: ZupTitledValueTag(
                title: S.of(context).poolInfoModalAboutPageType,
                value: S.of(context).poolInfoModalAboutPagePoolTypeValue(poolType: widget.liquidityPool.poolType.label),
                trailingIcon: ZupTooltip.text(
                  key: const Key("pool-type-tooltip"),
                  message: widget.liquidityPool.poolType.description(context),
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: Assets.icons.infoCircle.svg(
                    height: 15,
                    width: 15,
                    colorFilter: const ColorFilter.mode(ZupColors.gray, BlendMode.srcIn),
                  ),
                ),
              ),
            ),
            if (widget.liquidityPool.poolType.isV4) ...[
              const SizedBox(width: 10),
              ZupTooltip.text(
                message: isMobileDevice ? S.of(context).poolInfoModalAboutPageHooksDescription : "",
                child: ZupTitledValueTag(
                  title: S.of(context).poolInfoModalAboutPageHooks,
                  value:
                      widget.liquidityPool.hook?.address.shortAddress(prefixAndSuffixLength: 4) ??
                      S.of(context).poolInfoModalAboutPageHooksNo,
                  trailingIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.liquidityPool.hook != null) ...[
                        ZupSwitchingIconButton(
                          key: const Key("copy-hook-button"),
                          restIconTooltipMessage: S.of(context).poolInfoModalAboutPageCopyHook,
                          pressedIconTooltipMessage: S.of(context).poolInfoModalAboutPageHookCopied,
                          padding: const EdgeInsets.all(2),
                          backgroundColor: Colors.transparent,
                          restIcon: Assets.icons.documentOnDocument.svg(
                            height: 15,
                            width: 15,
                            colorFilter: ColorFilter.mode(
                              ZupThemeColors.backgroundInverse.themed(context.brightness),
                              BlendMode.srcIn,
                            ),
                          ),
                          pressedIcon: Assets.icons.checkmarkCircleFill.svg(
                            colorFilter: ColorFilter.mode(
                              ZupThemeColors.success.themed(context.brightness),
                              BlendMode.srcIn,
                            ),
                          ),
                          onPressed: (buttonContext) {
                            return Clipboard.setData(ClipboardData(text: widget.liquidityPool.hook!.address));
                          },
                        ),
                        const SizedBox(width: 5),
                      ],
                      ZupTooltip.text(
                        key: const Key("hooks-tooltip"),
                        message: S.of(context).poolInfoModalAboutPageHooksDescription,
                        constraints: const BoxConstraints(maxWidth: 200),
                        child: Assets.icons.infoCircle.svg(
                          height: 15,
                          width: 15,
                          colorFilter: const ColorFilter.mode(ZupColors.gray, BlendMode.srcIn),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),
        Text(
          S.of(context).poolInfoModalAboutPageTokens,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: ZupColors.gray),
        ),
        const SizedBox(height: 5),
        buildTokenButton(context, widget.liquidityPool.token0),
        const SizedBox(height: 10),
        buildTokenButton(context, widget.liquidityPool.token1),
        const SizedBox(height: 20),
        Text(
          S.of(context).poolInfoModalAboutPageProtocol,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: ZupColors.gray),
        ),
        const SizedBox(height: 5),
        ZupOutlinedButton(
          key: const Key("protocol-button"),
          onPressed: () {
            return launchUrl(Uri.parse(widget.liquidityPool.protocol.url), mode: LaunchMode.externalApplication);
          },
          leadingIcon: ZupRemoteAvatar(
            avatarUrl: widget.liquidityPool.protocol.logo,
            zupNetworkImage: zupNetworkImage,
            size: 20,
          ),

          trailingIcon: Assets.icons.arrowUpRight.svg(
            height: 9,
            width: 9,
            colorFilter: ColorFilter.mode(ZupThemeColors.primaryText.themed(context.brightness), BlendMode.srcIn),
          ),
          title: Text(
            widget.liquidityPool.protocol.name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: ZupThemeColors.primaryText.themed(context.brightness),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          S.of(context).poolInfoModalAboutPageNetwork,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: ZupColors.gray),
        ),
        const SizedBox(height: 5),
        ZupOutlinedButton(
          key: const Key("network-button"),
          onPressed: () {
            launchUrl(Uri.parse(widget.liquidityPool.network.websiteUrl), mode: LaunchMode.externalApplication);
          },
          title: Text(
            widget.liquidityPool.network.label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: ZupThemeColors.primaryText.themed(context.brightness),
            ),
          ),
          leadingIcon: SizedBox(width: 24, height: 24, child: widget.liquidityPool.network.icon(context.brightness)),
          trailingIcon: Assets.icons.arrowUpRight.svg(
            height: 9,
            width: 9,
            colorFilter: ColorFilter.mode(ZupThemeColors.primaryText.themed(context.brightness), BlendMode.srcIn),
          ),
        ),

        const SizedBox(height: 40),
        const Spacer(),
        Center(
          child: Text(
            S
                .of(context)
                .poolInfoModalAboutPageTimeCreatedAgo(
                  timeAgo: DateTime.fromMillisecondsSinceEpoch(
                    widget.liquidityPool.createdAtMillisecondsTimestamp,
                  ).timeAgo.formattedTimeAgo(context),
                ),
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: ZupColors.gray),
          ),
        ),
      ],
    );
  }

  Widget buildTokenButton(BuildContext context, SingleChainTokenDto token) => Row(
    children: [
      ZupOutlinedButton(
        key: Key("${token.address}-button"),
        onPressed: token.address != EthereumConstants.zeroAddress
            ? () => widget.liquidityPool.network.openAddress(token.address)
            : null,
        title: Text(
          token.symbol,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: token.address != EthereumConstants.zeroAddress
                ? ZupThemeColors.primaryText.themed(context.brightness)
                : ZupThemeColors.primaryText.themed(context.brightness),
          ),
        ),
        leadingIcon: ZupRemoteAvatar(
          avatarUrl: token.logoUrl,
          size: 20,
          errorPlaceholder: token.name[0],
          zupNetworkImage: zupNetworkImage,
        ),
        trailingIcon: token.address == EthereumConstants.zeroAddress
            ? null
            : Row(
                children: [
                  Text(
                    token.address.shortAddress(prefixAndSuffixLength: 3),
                    style: TextStyle(color: ZupThemeColors.primaryText.themed(context.brightness)),
                  ),
                  const SizedBox(width: 10),
                  Assets.icons.arrowUpRight.svg(
                    height: 9,
                    width: 9,
                    colorFilter: ColorFilter.mode(
                      ZupThemeColors.primaryText.themed(context.brightness),
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
      ),
      if (token.address != EthereumConstants.zeroAddress) ...[
        const SizedBox(width: 10),
        ZupSwitchingIconButton(
          key: Key("${token.address}-copy-button"),
          restIconTooltipMessage: S.of(context).poolInfoModalAboutPageCopyToken,
          pressedIconTooltipMessage: S.of(context).poolInfoModalAboutPageTokenCopied,
          restIcon: Assets.icons.documentOnDocument.svg(
            height: 18,
            width: 18,
            colorFilter: const ColorFilter.mode(ZupColors.gray, BlendMode.srcIn),
          ),
          pressedIcon: Assets.icons.checkmarkCircleFill.svg(
            height: 18,
            width: 18,
            colorFilter: ColorFilter.mode(ZupThemeColors.success.themed(context.brightness), BlendMode.srcIn),
          ),
          onPressed: (buttonContext) => Clipboard.setData(ClipboardData(text: token.address)),
        ),
      ],
    ],
  );
}
