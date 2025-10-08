import 'package:flutter/cupertino.dart';
import 'package:zup_app/core/enums/yield_timeframe.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';
import 'package:zup_core/extensions/build_context_extension.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

class TimeframeSelector extends StatefulWidget {
  const TimeframeSelector({super.key, required this.selectedTimeframe, required this.onTimeframeSelected});

  final YieldTimeFrame selectedTimeframe;
  final Function(YieldTimeFrame? newTimeframe) onTimeframeSelected;

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
            S.of(context).yieldsPageTimeframeSelectorTitle,
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
              CupertinoSlidingSegmentedControl<YieldTimeFrame>(
                proportionalWidth: true,
                onValueChanged: (timeframe) async {
                  widget.onTimeframeSelected(timeframe);
                },
                groupValue: widget.selectedTimeframe,
                children: Map.fromEntries(
                  YieldTimeFrame.values.map(
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
              const SizedBox(width: 10),
              ZupTooltip.text(
                key: const Key("timeframe-tooltip"),
                message: S.of(context).yieldsPageTimeframeExplanation,
                child: Assets.icons.infoCircle.svg(
                  colorFilter: const ColorFilter.mode(ZupColors.gray, BlendMode.srcIn),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
