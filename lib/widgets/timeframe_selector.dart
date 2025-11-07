import 'package:flutter/cupertino.dart';
import 'package:zup_app/core/enums/pool_data_timeframe.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_core/extensions/build_context_extension.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

class TimeframeSelector extends StatefulWidget {
  const TimeframeSelector({
    super.key,
    required this.selectedTimeframe,
    required this.onTimeframeSelected,
    required this.title,
    this.tooltipMessage,
  });

  final String title;
  final String? tooltipMessage;
  final PoolDataTimeframe selectedTimeframe;
  final Function(PoolDataTimeframe newTimeframe) onTimeframeSelected;

  @override
  State<TimeframeSelector> createState() => _TimeframeSelectorState();
}

class _TimeframeSelectorState extends State<TimeframeSelector> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Wrap(
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              color: ZupThemeColors.primaryText.themed(context.brightness),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoSlidingSegmentedControl<PoolDataTimeframe>(
                proportionalWidth: true,
                onValueChanged: (timeframe) async {
                  widget.onTimeframeSelected(timeframe ?? PoolDataTimeframe.day);
                },
                groupValue: widget.selectedTimeframe,
                children: Map.fromEntries(
                  PoolDataTimeframe.values.map(
                    (timeframe) => MapEntry(
                      timeframe,
                      IgnorePointer(
                            key: Key("${timeframe.name}-timeframe-button"),
                            child: Text(
                              timeframe.compactDaysLabel(context),
                              style: TextStyle(
                                color: ZupThemeColors.primaryText.themed(context.brightness),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                          .animatedHover(animationValue: 0.2, type: ZupAnimatedHoverType.opacity)
                          .animatedHover(animationValue: 0.95, type: ZupAnimatedHoverType.scale),
                    ),
                  ),
                ),
              ),
              if (widget.tooltipMessage != null) ...[
                const SizedBox(width: 10),
                ZupTooltip.text(
                  key: const Key("timeframe-tooltip"),
                  message: widget.tooltipMessage!,
                  child: Assets.icons.infoCircle.svg(
                    colorFilter: const ColorFilter.mode(ZupColors.gray, BlendMode.srcIn),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
