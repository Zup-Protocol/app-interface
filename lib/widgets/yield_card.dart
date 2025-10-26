import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart' hide ShimmerEffect;
import 'package:zup_app/core/dtos/liquidity_pool_dto.dart';
import 'package:zup_app/core/enums/pool_data_timeframe.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/mixins/keys_mixin.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';
import 'package:zup_app/widgets/pool_tokens_avatar.dart';
import 'package:zup_core/extensions/extensions.dart';
import 'package:zup_core/mixins/device_info_mixin.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

class YieldCard extends StatefulWidget {
  const YieldCard({
    super.key,
    required this.yieldPool,
    required this.yieldTimeFrame,
    required this.showHotestYieldAnimation,
    this.mainButton,
    this.expandWidth = false,
    this.showTimeframe = false,
    this.secondaryButton,
  });

  final LiquidityPoolDto yieldPool;
  final bool showHotestYieldAnimation;
  final bool showTimeframe;
  final bool expandWidth;
  final PoolDataTimeframe yieldTimeFrame;
  final ZupPrimaryButton? mainButton;
  final ZupIconButton? secondaryButton;

  @override
  State<YieldCard> createState() => _YieldCardState();
}

class _YieldCardState extends State<YieldCard> with DeviceInfoMixin, KeysMixin {
  final zupNetworkImage = inject<ZupNetworkImage>();
  final infinityAnimationAutoPlay = inject<bool>(instanceName: InjectInstanceNames.infinityAnimationAutoPlay);

  List<PoolDataTimeframe> get timeframesExcludingCurrent {
    return PoolDataTimeframe.values.where((timeframe) => timeframe != widget.yieldTimeFrame).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: yieldCardHeroKey(widget.yieldPool.poolAddress),
      flightShuttleBuilder:
          (
            BuildContext _,
            Animation<double> _,
            HeroFlightDirection _,
            BuildContext fromHeroContext,
            BuildContext toHeroContext,
          ) {
            return Align(alignment: Alignment.topRight, child: toHeroContext.widget);
          },
      child: Container(
        padding: const EdgeInsets.all(25),
        width: widget.expandWidth ? double.infinity : null,
        constraints: const BoxConstraints(maxWidth: 450),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: context.brightness.isDark ? ZupColors.black2 : ZupColors.white,
          border: context.brightness.isDark
              ? null
              : Border.all(width: 0.5, color: ZupThemeColors.borderOnBackgroundSurface.themed(context.brightness)),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 250),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PoolTokensAvatar(liquidityPool: widget.yieldPool, size: 27),
                  const SizedBox(width: 3),
                  Text(
                    "${widget.yieldPool.token0.symbol.clamped(8)}/${widget.yieldPool.token1.symbol.clamped(8)}",
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  ZupTooltip.text(
                    key: Key("yield-card-network-${widget.yieldPool.network.label}"),
                    message: S.of(context).yieldCardThisPoolIsAtNetwork(network: widget.yieldPool.network.label),
                    trailingIcon: widget.yieldPool.network.icon(context.brightness),
                    child: Container(
                      height: 40,
                      width: 40,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: context.brightness.isDark
                            ? ZupThemeColors.background.themed(Brightness.dark)
                            : ZupColors.gray6,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: widget.yieldPool.network.icon(context.brightness),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (widget.showHotestYieldAnimation) ...[
                            yieldPercentText.animate(
                              autoPlay: infinityAnimationAutoPlay,
                              onComplete: (controller) => controller.repeat(reverse: true),
                              effects: [
                                const ScaleEffect(
                                  duration: Duration(milliseconds: 200),
                                  alignment: Alignment.center,
                                  begin: Offset(1.1, 1.1),
                                  end: Offset(1, 1),
                                ),
                                ShimmerEffect(
                                  duration: const Duration(seconds: 2),
                                  color: context.brightness.isDark ? ZupColors.orange5 : ZupColors.orange,
                                  curve: Curves.decelerate,
                                  angle: 90,
                                  size: 1,
                                ),
                              ],
                            ),
                          ] else ...[
                            yieldPercentText,
                          ],
                          const SizedBox(width: 5),
                          Skeleton.ignore(
                            child: ZupTooltip.widget(
                              isChildBounded: true,
                              key: Key("yield-breakdown-tooltip-${widget.yieldPool.poolAddress}"),
                              tooltipChild: yieldBreakdownTooltipChild,
                              child: Assets.icons.infoCircle.svg(
                                width: 14,
                                height: 14,
                                colorFilter: const ColorFilter.mode(ZupColors.gray, BlendMode.srcIn),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "${S.of(context).yieldCardYearlyYield} ${widget.showTimeframe ? "(${widget.yieldTimeFrame.compactDaysLabel(context)})" : ""}",
                        style: const TextStyle(fontSize: 15, color: ZupColors.gray),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    height: 50,
                    width: 1,
                    color: ZupThemeColors.borderOnBackgroundSurface.themed(context.brightness),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        NumberFormat.compactSimpleCurrency(
                          decimalDigits: 2,
                        ).format(widget.yieldPool.totalValueLockedUSD),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                      ),
                      Text(S.of(context).tvl, style: const TextStyle(fontSize: 15, color: ZupColors.gray)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 35),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ZupRemoteAvatar(
                    avatarUrl: widget.yieldPool.protocol.logo,
                    size: 20,
                    zupNetworkImage: zupNetworkImage,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      widget.yieldPool.protocol.name,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              if (widget.mainButton != null || widget.secondaryButton != null) const SizedBox(height: 30),
              Row(
                children: [
                  if (widget.secondaryButton != null) ...[
                    widget.secondaryButton!,
                    if (widget.mainButton != null) const SizedBox(width: 10),
                  ],
                  if (widget.mainButton != null) Expanded(child: widget.mainButton!),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget get yieldPercentText {
    final text = Text(
      widget.yieldPool.timeframedYieldFormatted(widget.yieldTimeFrame),
      key: Key("yield-card-yield-${widget.yieldPool.poolAddress}"),
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 28,
        color: context.brightness.isDark ? ZupColors.brand5 : ZupColors.brand3,
      ),
    );

    if (isMobileDevice) return ZupTooltip.widget(tooltipChild: yieldBreakdownTooltipChild, child: text);

    return text;
  }

  Widget get yieldBreakdownTooltipChild => SizedBox(
    width: 200,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).yieldCardYieldExplanation(timeframeLabel: widget.yieldTimeFrame.compactDaysLabel(context)),
            style: const TextStyle(color: ZupColors.gray, fontSize: 14),
          ),
          const SizedBox(height: 16),

          ...timeframesExcludingCurrent.mapIndexed(
            (index, yieldTimeFrame) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      S.of(context).yieldCardTimeframeYield(timeframe: yieldTimeFrame.compactDaysLabel(context)),
                      style: TextStyle(
                        color: ZupThemeColors.primaryText.themed(context.brightness),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      widget.yieldPool.timeframedYieldFormatted(yieldTimeFrame),
                      style: const TextStyle(color: ZupColors.gray, fontSize: 15),
                    ),
                  ],
                ),
                if (index < timeframesExcludingCurrent.length - 1) ...[
                  ZupDivider(color: ZupThemeColors.borderOnBackgroundSurface.themed(context.brightness)),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
