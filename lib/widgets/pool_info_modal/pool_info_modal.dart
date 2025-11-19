import 'package:flex_list/flex_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/core/dtos/liquidity_pool_dto.dart';
import 'package:zup_app/core/dtos/single_chain_token_dto.dart';
import 'package:zup_app/core/enums/pool_data_timeframe.dart';
import 'package:zup_app/core/extensions/num_extension.dart';
import 'package:zup_app/core/extensions/time_ago_extension.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/zup_navigator.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';
import 'package:zup_app/widgets/pool_tokens_button.dart';
import 'package:zup_app/widgets/timeframe_selector.dart';
import 'package:zup_core/zup_core.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

part 'pages/about_page.dart';
part 'pages/stats_page.dart';

enum _PoolInfoPages { stats, about }

class PoolInfoModal extends StatefulWidget with DeviceInfoMixin {
  const PoolInfoModal({super.key, required this.liquidityPool, required this.selectedTimeframe});

  final LiquidityPoolDto liquidityPool;
  final PoolDataTimeframe selectedTimeframe;

  static show(
    BuildContext context, {
    required LiquidityPoolDto liquidityPool,
    required PoolDataTimeframe selectedTimeframe,
    required bool showAsBottomSheet,
  }) {
    if (showAsBottomSheet) {
      return ZupModal.show(
        context,
        dismissible: true,
        content: PoolInfoModal(liquidityPool: liquidityPool, selectedTimeframe: selectedTimeframe),
        title: S.of(context).poolInfoModalBottomSheetTitle,
        backgroundColor: null,
        description: null,
        padding: EdgeInsets.zero,
        showAsBottomSheet: true,
      );
    }

    return ZupSidePanel.show(
      context,
      child: PoolInfoModal(liquidityPool: liquidityPool, selectedTimeframe: selectedTimeframe),
    );
  }

  @override
  State<PoolInfoModal> createState() => _PoolInfoModalState();
}

class _PoolInfoModalState extends State<PoolInfoModal> with SingleTickerProviderStateMixin, DeviceInfoMixin {
  final navigator = inject<ZupNavigator>();

  _PoolInfoPages selectedTab = _PoolInfoPages.stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 540),
      child: ScrollbarTheme(
        data: Theme.of(context).scrollbarTheme.copyWith(crossAxisMargin: 8, mainAxisMargin: 20),
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          shrinkWrap: true,
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Container(
                padding: isMobileSize(context) ? const EdgeInsets.symmetric(horizontal: 20) : const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        PoolTokensButton(liquidityPool: widget.liquidityPool),
                        const SizedBox(width: 10),
                        ZupSwitchingIconButton(
                          key: const Key("pool-info-modal-copy-pool-address"),
                          restIconTooltipMessage: S.of(context).poolInfoModalCopyPoolAddress,
                          pressedIconTooltipMessage: S.of(context).poolInfoModalCopied,
                          restIcon: Assets.icons.documentOnDocument.svg(
                            height: 18,
                            width: 18,
                            colorFilter: const ColorFilter.mode(ZupColors.gray, BlendMode.srcIn),
                          ),
                          pressedIcon: Assets.icons.checkmarkCircleFill.svg(
                            height: 17,
                            width: 17,
                            colorFilter: ColorFilter.mode(
                              ZupThemeColors.success.themed(context.brightness),
                              BlendMode.srcIn,
                            ),
                          ),
                          onPressed: (buttonContext) {
                            return Clipboard.setData(ClipboardData(text: widget.liquidityPool.poolAddress));
                          },
                        ),

                        if (!isMobileSize(context)) ...[
                          const Spacer(),
                          ZupPrimaryButton(
                            key: const Key("pool-info-modal-add-liquidity"),
                            title: S.of(context).poolInfoModalAddLiquidity,
                            onPressed: (buttonContext) {
                              Navigator.pop(context);
                              navigator.navigateToDeposit(
                                yieldPool: widget.liquidityPool,
                                selectedTimeframe: widget.selectedTimeframe,
                                parseWrappedToNative:
                                    widget.liquidityPool.isToken0Native || widget.liquidityPool.isToken1Native,
                              );
                            },
                            fixedIcon: true,
                            isTrailingIcon: true,
                            icon: Assets.icons.arrowRight.svg(),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),
                    ZupTabBar(
                      initialSelectedTabIndex: 0,
                      tabs: [
                        ZupTabBarItem(
                          key: const Key("stats-tab"),
                          title: S.of(context).poolInfoModalPoolStatsTabTitle,
                          icon: Assets.icons.chartBar.svg(),
                          onSelected: () {
                            setState(() => selectedTab = _PoolInfoPages.stats);
                          },
                        ),
                        ZupTabBarItem(
                          key: const Key("about-tab"),
                          title: S.of(context).poolInfoModalAboutPoolTabTitle,
                          icon: Assets.icons.infoCircle.svg(),
                          onSelected: () {
                            setState(() => selectedTab = _PoolInfoPages.about);
                          },
                        ),
                      ],
                    ),

                    Expanded(
                      child: switch (selectedTab) {
                        _PoolInfoPages.stats => _StatsPage(
                          liquidityPool: widget.liquidityPool,
                          selectedTimeframe: widget.selectedTimeframe,
                        ),
                        _PoolInfoPages.about => _AboutPage(widget.liquidityPool),
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
