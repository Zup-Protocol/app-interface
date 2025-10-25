part of '../pool_info_modal.dart';

class _StatsPage extends StatefulWidget {
  const _StatsPage({required this.liquidityPool, required this.selectedTimeframe});

  final YieldDto liquidityPool;
  final PoolDataTimeframe selectedTimeframe;

  @override
  State<_StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<_StatsPage> with DeviceInfoMixin {
  late PoolDataTimeframe selectedTimeframe = widget.selectedTimeframe;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 370),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: TimeframeSelector(
              title: S.of(context).poolInfoModalStatsPageTimeframeTitle,
              selectedTimeframe: selectedTimeframe,
              onTimeframeSelected: (timeframe) => setState(() => selectedTimeframe = timeframe),
            ),
          ),
          const SizedBox(height: 10),
          FlexList(
            children: [
              _buildInfoField(
                title: S.of(context).tvl,
                value: widget.liquidityPool.totalValueLockedUSD.formatCompactCurrency(),
                tooltipMessage: S
                    .of(context)
                    .poolInfoModalStatsPageTvlDescription(
                      formattedTvl: widget.liquidityPool.totalValueLockedUSD.formatCompactCurrency(),
                    ),
              ),
              _buildInfoField(
                title: S
                    .of(context)
                    .poolInfoModalStatsPageSwapVolume(timeframeLabel: selectedTimeframe.compactDaysLabel(context)),
                value: widget.liquidityPool.volumeTimeframed(selectedTimeframe).formatCompactCurrency(),
                tooltipMessage: S
                    .of(context)
                    .poolInfoModalStatePageSwapVolumeDescription(
                      formattedVolume: widget.liquidityPool.volumeTimeframed(selectedTimeframe).formatCompactCurrency(),
                      timeframeLabel: selectedTimeframe.compactDaysLabel(context),
                    ),
              ),
              _buildInfoField(
                title: S
                    .of(context)
                    .poolInfoModalStatsPageFees(timeframeLabel: selectedTimeframe.compactDaysLabel(context)),
                value: widget.liquidityPool.feesTimeframed(selectedTimeframe).formatCompactCurrency(),
                tooltipMessage: S
                    .of(context)
                    .poolInfoModalStatsPageFeesDescription(
                      formattedFees: widget.liquidityPool.feesTimeframed(selectedTimeframe).formatCompactCurrency(),
                      timeframeLabel: selectedTimeframe.compactDaysLabel(context),
                    ),
              ),
              _buildInfoField(
                title: S
                    .of(context)
                    .poolInfoModalStatsPageNetInflow(timeframeLabel: selectedTimeframe.compactDaysLabel(context)),
                value: widget.liquidityPool
                    .netInflowTimeframed(selectedTimeframe)
                    .formatCompactCurrency()
                    .asSignedStringNumber,
                tooltipMessage: S
                    .of(context)
                    .poolInfoModalStatsPageNetInflowDescription(
                      timeframeLabel: selectedTimeframe.compactDaysLabel(context),
                      formattedNetInflow: widget.liquidityPool
                          .netInflowTimeframed(selectedTimeframe)
                          .formatCompactCurrency()
                          .asSignedStringNumber,
                    ),
                titleColor: widget.liquidityPool.netInflowTimeframed(selectedTimeframe).trendColor(context),
              ),
              _buildInfoField(
                title: S
                    .of(context)
                    .poolInfoModalStatsPageYearlyYield(timeframeLabel: selectedTimeframe.compactDaysLabel(context)),
                value: widget.liquidityPool.timeframedYieldFormatted(selectedTimeframe),
                titleColor: context.brightness.isDark ? ZupColors.brand5 : ZupColors.brand,
                tooltipMessage: S
                    .of(context)
                    .poolInfoModalStatsPageYearlyYieldDescription(
                      yearlyYieldFormatted: widget.liquidityPool.timeframedYieldFormatted(selectedTimeframe),
                      timeframeLabel: selectedTimeframe.compactDaysLabel(context),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField({
    required String title,
    required String value,
    required String tooltipMessage,
    Color? titleColor,
  }) => ZupTooltip.text(
    message: isMobileDevice ? tooltipMessage : "",
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          width: context.brightness.isDark ? 1 : 0.5,
          color: ZupThemeColors.borderOnBackground.themed(context.brightness),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: ZupColors.gray),
              ),
            ],
          ),
          const SizedBox(width: 5),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: titleColor ?? ZupThemeColors.primaryText.themed(context.brightness),
                ),
              ),
              const SizedBox(width: 5),
              ZupTooltip.text(
                key: Key("$title-tooltip"),
                message: tooltipMessage,
                constraints: const BoxConstraints(maxWidth: 250),
                child: Assets.icons.infoCircle.svg(
                  colorFilter: const ColorFilter.mode(ZupColors.gray, BlendMode.srcIn),
                  width: 12,
                  height: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
