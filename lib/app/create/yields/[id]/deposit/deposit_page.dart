import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/app/create/yields/%5Bid%5D/deposit/deposit_cubit.dart';
import 'package:zup_app/app/create/yields/%5Bid%5D/deposit/widgets/deposit_settings_dropdown_child.dart';
import 'package:zup_app/app/create/yields/%5Bid%5D/deposit/widgets/preview_deposit_modal/preview_deposit_modal.dart';
import 'package:zup_app/app/create/yields/%5Bid%5D/deposit/widgets/range_selector.dart';
import 'package:zup_app/app/create/yields/%5Bid%5D/deposit/widgets/token_amount_input_card/token_amount_input_card.dart';
import 'package:zup_app/core/cache.dart';
import 'package:zup_app/core/concentrated_liquidity_utils/cl_pool_constants.dart';
import 'package:zup_app/core/concentrated_liquidity_utils/cl_pool_conversors_mixin.dart';
import 'package:zup_app/core/concentrated_liquidity_utils/cl_pool_liquidity_calculations_mixin.dart';
import 'package:zup_app/core/concentrated_liquidity_utils/cl_sqrt_price_math_mixin.dart';
import 'package:zup_app/core/dtos/deposit_settings_dto.dart';
import 'package:zup_app/core/dtos/single_chain_token_dto.dart';
import 'package:zup_app/core/dtos/liquidity_pool_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/enums/pool_data_timeframe.dart';
import 'package:zup_app/core/extensions/num_extension.dart';
import 'package:zup_app/core/extensions/string_extension.dart';
import 'package:zup_app/core/extensions/widget_extension.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/mixins/keys_mixin.dart';
import 'package:zup_app/core/pool_service.dart';
import 'package:zup_app/core/repositories/yield_repository.dart';
import 'package:zup_app/core/slippage.dart';
import 'package:zup_app/core/zup_navigator.dart';
import 'package:zup_app/core/zup_route_params_names.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';
import 'package:zup_app/widgets/pool_info_modal/pool_info_modal.dart';
import 'package:zup_app/widgets/yield_card.dart';
import 'package:zup_app/widgets/zup_skeletonizer.dart';
import 'package:zup_core/zup_core.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

Route routeBuilder(BuildContext context, RouteSettings settings) {
  return PageRouteBuilder(
    settings: settings,
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, a1, a2) => BlocProvider(
      create: (context) => DepositCubit(
        inject<YieldRepository>(),
        inject<ZupSingletonCache>(),
        inject<Wallet>(),
        inject<Cache>(),
        inject<PoolService>(),
        inject<ZupNavigator>(),
      ),
      child: Container(color: ZupThemeColors.background.themed(context.brightness), child: const DepositPage()),
    ),
    transitionsBuilder: (_, a1, a2, child) => SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.2), end: const Offset(0, 0)).animate(a1),
      child: FadeTransition(opacity: a1, child: child),
    ),
  );
}

class DepositPage extends StatefulWidget {
  const DepositPage({super.key});

  @override
  State<DepositPage> createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage>
    with
        CLPoolConversorsMixin,
        CLPoolLiquidityCalculationsMixin,
        DeviceInfoMixin,
        CLPoolLiquidityCalculationsMixin,
        CLSqrtPriceMath,
        KeysMixin {
  final appScrollController = inject<ScrollController>(instanceName: InjectInstanceNames.appScrollController);

  final baseTokenAmountController = TextEditingController();
  final quoteTokenAmountController = TextEditingController();
  final wallet = inject<Wallet>();

  ZupNavigator get _navigator => inject<ZupNavigator>();
  DepositCubit get _cubit => context.read<DepositCubit>();

  AppNetworks get networkFromUrl =>
      AppNetworks.fromValue(_navigator.getQueryParam(DepositRouteParamsNames().network)!) ?? AppNetworks.mainnet;

  PoolDataTimeframe get yieldTimeFrameFromUrl =>
      PoolDataTimeframe.fromValue(_navigator.getQueryParam(DepositRouteParamsNames().timeframe)!) ??
      PoolDataTimeframe.day;

  SingleChainTokenDto get baseToken {
    return areTokensReversed ? _cubit.yieldPool!.token1 : _cubit.yieldPool!.token0;
  }

  SingleChainTokenDto get quoteToken {
    return areTokensReversed ? _cubit.yieldPool!.token0 : _cubit.yieldPool!.token1;
  }

  double desktopYieldCardTopPadding = 175;
  bool areTokensReversed = false;
  bool isMaxRangeInfinity = true;
  bool isMinRangeInfinity = true;
  bool isBaseTokenAmountUserInput = false;
  double? percentRange;
  double minPrice = 0;
  double maxPrice = 0;
  RangeController minRangeController = RangeController();
  RangeController maxRangeController = RangeController();
  StreamSubscription<BigInt?>? _poolSqrtPriceX96StreamSubscription;
  PoolDataTimeframe yieldPoolTimeFrame = PoolDataTimeframe.day;

  late Slippage selectedSlippage = _cubit.depositSettings.slippage;
  late Duration selectedDeadline = _cubit.depositSettings.deadline;

  bool get shouldYieldCardBeInColumn => MediaQuery.sizeOf(context).width < 750;

  bool get isRangeInvalid {
    if (isMaxRangeInfinity || isMinRangeInfinity) return false;

    return (minPrice) >= (maxPrice);
  }

  bool get isBaseTokenNeeded => !isOutOfRange.maxPrice;
  bool get isQuoteTokenNeeded => !isOutOfRange.minPrice;

  double get currentPrice {
    if (_cubit.latestPoolSqrtPriceX96 == null) return 0;

    final price = sqrtPriceX96ToPrice(
      sqrtPriceX96: _cubit.latestPoolSqrtPriceX96!,
      poolToken0Decimals: _cubit.yieldPool!.token0.decimals,
      poolToken1Decimals: _cubit.yieldPool!.token1.decimals,
    );

    return areTokensReversed ? price.token1PerToken0 : price.token0PerToken1;
  }

  ({bool minPrice, bool maxPrice, bool any}) get isOutOfRange {
    if (_cubit.latestPoolSqrtPriceX96 == null) return (minPrice: false, maxPrice: false, any: false);

    final isMinPriceOutOfRange = !isMinRangeInfinity && (minPrice) > currentPrice;
    final isMaxPriceOutOfRange = !isMaxRangeInfinity && (maxPrice) < currentPrice;

    return (
      minPrice: isMinPriceOutOfRange,
      maxPrice: isMaxPriceOutOfRange,
      any: isMinPriceOutOfRange || isMaxPriceOutOfRange,
    );
  }

  void setFullRange() {
    setState(() {
      percentRange = null;
      isMinRangeInfinity = true;
      isMaxRangeInfinity = true;
    });

    minPrice = 0;
    maxPrice = 0;

    calculateDepositTokensAmount();
  }

  void setPercentageRange(double percentage) {
    if (currentPrice == 0) return;

    setState(() {
      percentRange = percentage;
      isMinRangeInfinity = false;
      isMaxRangeInfinity = false;

      final percentageDecimals = percentage / 100;
      final percentageDifference = currentPrice * percentageDecimals;

      minPrice = currentPrice - percentageDifference;
      maxPrice = currentPrice + percentageDifference;

      minRangeController.setRange(minPrice);
      maxRangeController.setRange(maxPrice);

      calculateDepositTokensAmount();
    });
  }

  void switchTokens(bool isReversed) {
    setState(() => areTokensReversed = isReversed);

    final currentBaseTokenDepositAmount = baseTokenAmountController.text;
    final currentQuoteTokenDepositAmount = quoteTokenAmountController.text;

    baseTokenAmountController.text = currentQuoteTokenDepositAmount;
    quoteTokenAmountController.text = currentBaseTokenDepositAmount;
    isBaseTokenAmountUserInput = isReversed && !isBaseTokenAmountUserInput;

    if (percentRange != null) setPercentageRange(percentRange!);
    calculateDepositTokensAmount();
  }

  void calculateDepositTokensAmount() {
    if (_cubit.latestPoolSqrtPriceX96 == null) return;

    if (isOutOfRange.minPrice) return quoteTokenAmountController.clear();
    if (isOutOfRange.maxPrice) return baseTokenAmountController.clear();

    final maxTickPrice = tickToPrice(
      tick: CLPoolConstants.maxTick,
      poolToken0Decimals: _cubit.yieldPool!.token0.decimals,
      poolToken1Decimals: _cubit.yieldPool!.token1.decimals,
    );

    final minTickPrice = tickToPrice(
      tick: CLPoolConstants.minTick,
      poolToken0Decimals: _cubit.yieldPool!.token0.decimals,
      poolToken1Decimals: _cubit.yieldPool!.token1.decimals,
    );

    double getMinPrice() {
      if (minPrice != 0 && !isMinRangeInfinity) return minPrice;

      return areTokensReversed ? maxTickPrice.priceAsQuoteToken : minTickPrice.priceAsBaseToken;
    }

    double getMaxPrice() {
      if (maxPrice != 0 && !isMaxRangeInfinity) return maxPrice;

      return areTokensReversed ? minTickPrice.priceAsQuoteToken : maxTickPrice.priceAsBaseToken;
    }

    final newQuoteTokenAmount = Decimal.tryParse(
      calculateToken1AmountFromToken0(
        currentPrice: currentPrice,
        priceLower: getMinPrice(),
        priceUpper: getMaxPrice(),
        tokenXAmount: double.tryParse(baseTokenAmountController.text) ?? 0,
      ).toString(),
    )?.toStringAsFixed(quoteToken.decimals);

    final newBaseTokenAmount = Decimal.tryParse(
      calculateToken0AmountFromToken1(
        currentPrice: currentPrice,
        priceLower: getMinPrice(),
        priceUpper: getMaxPrice(),
        tokenYAmount: double.tryParse(quoteTokenAmountController.text) ?? 0,
      ).toString(),
    )?.toStringAsFixed(baseToken.decimals);

    if (isBaseTokenAmountUserInput) {
      if (newQuoteTokenAmount?.isEmptyOrZero ?? true) return quoteTokenAmountController.clear();
      quoteTokenAmountController.text = newQuoteTokenAmount!;

      return;
    }

    if (newBaseTokenAmount?.isEmptyOrZero ?? true) return baseTokenAmountController.clear();
    baseTokenAmountController.text = newBaseTokenAmount!;
  }

  Future<({String title, Widget? icon, Function()? onPressed})> depositButtonState() async {
    final userWalletBaseTokenAmount = await _cubit.getWalletTokenAmount(
      baseToken.address,
      network: _cubit.yieldPool!.network,
    );

    final userWalletQuoteTokenAmount = await _cubit.getWalletTokenAmount(
      quoteToken.address,
      network: _cubit.yieldPool!.network,
    );

    if (isRangeInvalid) return (title: S.of(context).depositPageInvalidRange, icon: null, onPressed: null);

    if (isBaseTokenNeeded && baseTokenAmountController.text.isEmptyOrZero) {
      return (
        title: S.of(context).depositPageInvalidTokenAmount(tokenSymbol: baseToken.symbol),
        icon: null,
        onPressed: null,
      );
    }

    if (isQuoteTokenNeeded && quoteTokenAmountController.text.isEmptyOrZero) {
      return (
        title: S.of(context).depositPageInvalidTokenAmount(tokenSymbol: quoteToken.symbol),
        icon: null,
        onPressed: null,
      );
    }

    if (userWalletBaseTokenAmount < (double.tryParse(baseTokenAmountController.text) ?? 0) && isBaseTokenNeeded) {
      return (
        title: S.of(context).depositPageInsufficientTokenBalance(tokenSymbol: baseToken.symbol),
        icon: null,
        onPressed: null,
      );
    }

    if (userWalletQuoteTokenAmount < (double.tryParse(quoteTokenAmountController.text) ?? 0) && isQuoteTokenNeeded) {
      return (
        title: S.of(context).depositPageInsufficientTokenBalance(tokenSymbol: quoteToken.symbol),
        icon: null,
        onPressed: null,
      );
    }

    return (
      title: "Preview Deposit",
      icon: Assets.icons.scrollFill.svg(),
      onPressed: () {
        PreviewDepositModal(
          key: const Key("preview-deposit-modal"),
          yieldTimeFrame: yieldPoolTimeFrame,
          deadline: selectedDeadline,
          maxSlippage: selectedSlippage,
          currentYield: _cubit.yieldPool!,
          isReversed: areTokensReversed,
          token0DepositAmountController: areTokensReversed ? quoteTokenAmountController : baseTokenAmountController,
          token1DepositAmountController: areTokensReversed ? baseTokenAmountController : quoteTokenAmountController,
          maxPrice: (isInfinity: isMaxRangeInfinity, price: maxPrice),
          minPrice: (isInfinity: isMinRangeInfinity, price: minPrice),
        ).show(context, currentPriceX96: _cubit.latestPoolSqrtPriceX96 ?? BigInt.zero);
      },
    );
  }

  @override
  void initState() {
    _cubit.setup();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      appScrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.decelerate);
    });

    _poolSqrtPriceX96StreamSubscription = _cubit.poolSqrtPriceX96Stream.listen((sqrtPriceX96) {
      if (sqrtPriceX96 != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() => calculateDepositTokensAmount());
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    minRangeController.dispose();
    maxRangeController.dispose();
    _poolSqrtPriceX96StreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: isMobileSize(context) ? const EdgeInsets.all(20) : const EdgeInsets.symmetric(horizontal: 40),
      child: BlocBuilder<DepositCubit, DepositState>(
        builder: (context, state) {
          return state.maybeWhen(
            orElse: () => _buildLoadingState(),
            error: () => _buildErrorState(),
            success: (yieldPool) => Padding(
              padding: EdgeInsets.only(top: isMobileSize(context) ? 20 : 60),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 550, minHeight: shouldYieldCardBeInColumn ? 1500 : 1100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              ZupTextButton(
                                key: const Key("back-button"),
                                onPressed: () {
                                  _navigator.canBack(context)
                                      ? _navigator.back(context)
                                      : _navigator.navigateToNewPosition();
                                },
                                icon: Assets.icons.arrowLeft.svg(),
                                label: _navigator.canBack(context)
                                    ? S.of(context).depositPageBackToYieldsButtonTitle
                                    : S.of(context).depositPageBackToNewPositionButtonTitle,
                              ),
                              const Spacer(),
                              ZupPillButton(
                                key: const Key("deposit-settings-button"),
                                backgroundColor:
                                    selectedSlippage.riskBackgroundColor(context.brightness) ??
                                    ZupThemeColors.tertiaryButtonBackground.themed(context.brightness),
                                foregroundColor:
                                    selectedSlippage.riskForegroundColor(context.brightness) ??
                                    ZupColors.brand.lighter(0.3),
                                title: selectedSlippage.value != DepositSettingsDto.defaultMaxSlippage
                                    ? S
                                          .of(context)
                                          .depositPagePercentSlippage(
                                            valuePercent: selectedSlippage.value.formatRoundingPercent,
                                          )
                                    : null,
                                onPressed: (buttonContext) => ZupPopover.show(
                                  adjustment: const Offset(0, 10),
                                  showBasedOnContext: buttonContext,
                                  child: DepositSettingsDropdownChild(
                                    context,
                                    selectedDeadline: selectedDeadline,
                                    selectedSlippage: selectedSlippage,
                                    onSettingsChanged: (slippage, deadline) {
                                      _cubit.saveDepositSettings(slippage, deadline);

                                      setState(() {
                                        selectedDeadline = deadline;
                                        selectedSlippage = slippage;
                                      });
                                    },
                                  ),
                                ),
                                icon: Assets.icons.gear.svg(
                                  colorFilter: ColorFilter.mode(
                                    ZupThemeColors.background.themed(context.brightness),
                                    BlendMode.srcIn,
                                  ),
                                  height: 20,
                                  width: 20,
                                ),
                              ),
                            ],
                          ),

                          if (shouldYieldCardBeInColumn) ...[
                            const SizedBox(height: 30),

                            Center(child: _buildYieldCard(yieldPool)),
                            const SizedBox(height: 30),
                          ],
                          const SizedBox(height: 10),
                          _buildSelectRangeSector(),
                          const SizedBox(height: 20),
                          _buildDepositSection(),
                        ],
                      ),
                    ),
                  ),
                  if (!shouldYieldCardBeInColumn) ...[
                    const SizedBox(width: 20),
                    Column(
                      children: [
                        SizedBox(height: desktopYieldCardTopPadding),
                        _buildYieldCard(yieldPool),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
    title,
    style: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: ZupThemeColors.primaryText.themed(context.brightness),
    ),
  );

  Widget _buildErrorState() => Center(
    child: SizedBox(
      width: 400,
      child: ZupInfoState(
        icon: const IgnorePointer(
          child: Text(":(", style: TextStyle(color: ZupColors.brand)),
        ),
        title: S.of(context).depositPageErrorStateTitle,
        description: S.of(context).depositPageErrorStateDescription,
        helpButtonTitle: S.of(context).letsGiveItAnotherShot,
        helpButtonIcon: Assets.icons.arrowClockwise.svg(),
        onHelpButtonTap: () => _cubit.fetchCurrentPoolInfo(),
      ),
    ),
  );

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ZupSkeletonizer(
            child: YieldCard(
              yieldPool: LiquidityPoolDto.fixture().copyWith(chainId: networkFromUrl.chainId),
              yieldTimeFrame: PoolDataTimeframe.day,
              showHotestYieldAnimation: false,
            ),
          ).animate(
            onPlay: (controller) => controller.repeat(reverse: true),
            effects: [
              const MoveEffect(
                duration: Duration(milliseconds: 900),
                curve: Curves.decelerate,
                begin: Offset(0, 0),
                end: Offset(0, -35),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            S.of(context).depositPageLoadingTitle,
            style: TextStyle(
              color: ZupThemeColors.primaryText.themed(context.brightness),
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYieldCard(LiquidityPoolDto yieldPool) => YieldCard(
    yieldPool: yieldPool,
    yieldTimeFrame: yieldTimeFrameFromUrl,
    expandWidth: shouldYieldCardBeInColumn,
    showHotestYieldAnimation: false,
    showTimeframe: !_navigator.canBack(context),
    mainButton: ZupPrimaryButton(
      title: "Pool Stats",
      fixedIcon: true,
      isTrailingIcon: false,
      onPressed: (_) => PoolInfoModal.show(
        context,
        showAsBottomSheet: isMobileSize(context),
        liquidityPool: yieldPool,
        selectedTimeframe: yieldTimeFrameFromUrl,
      ),
      backgroundColor: ZupThemeColors.tertiaryButtonBackground.themed(context.brightness),
      foregroundColor: ZupColors.brand,
      icon: Assets.icons.chartBar.svg(height: 13, width: 13),
      hoverElevation: 0,
    ),
  );

  Widget _buildSelectRangeSector() {
    Widget tokenSwitcher = CupertinoSlidingSegmentedControl(
      groupValue: areTokensReversed,
      children: {
        false: MouseRegion(
          key: const Key("reverse-tokens-not-reversed"),
          cursor: SystemMouseCursors.click,
          child: IgnorePointer(
            ignoring: true,
            child: Text(
              "${_cubit.yieldPool!.token0.symbol} / ${_cubit.yieldPool!.token1.symbol}",
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        true: MouseRegion(
          key: const Key("reverse-tokens-reversed"),
          cursor: SystemMouseCursors.click,
          child: IgnorePointer(
            ignoring: true,
            child: Text(
              "${_cubit.yieldPool!.token1.symbol} / ${_cubit.yieldPool!.token0.symbol}",
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      },
      onValueChanged: (isReversed) {
        switchTokens(isReversed ?? false);
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,

      children: [
        Builder(
          builder: (context) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final nextDesktopYieldCardTopPadding = (context.size!.height + 40);

              if (desktopYieldCardTopPadding != nextDesktopYieldCardTopPadding) {
                setState(() => desktopYieldCardTopPadding = nextDesktopYieldCardTopPadding);
              }
            });

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle(S.of(context).depositPageRangeSectionTitle),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runSpacing: 10,
                    children: [
                      StreamBuilder(
                        stream: _cubit.poolSqrtPriceX96Stream,
                        initialData: _cubit.latestPoolSqrtPriceX96,
                        builder: (context, poolSqrtPriceX96Snaphot) {
                          return Text(
                            "1 ${baseToken.symbol} ≈ ${() {
                              final currentPrice = sqrtPriceX96ToPrice(sqrtPriceX96: poolSqrtPriceX96Snaphot.data ?? BigInt.zero, poolToken0Decimals: _cubit.yieldPool!.token0.decimals, poolToken1Decimals: _cubit.yieldPool!.token1.decimals);

                              return areTokensReversed ? currentPrice.token1PerToken0 : currentPrice.token0PerToken1;
                            }.call().formatCurrency(useLessThan: true, maxDecimals: 4, isUSD: false)} ${quoteToken.symbol}",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: ZupThemeColors.primaryText.themed(context.brightness),
                            ),
                          ).redacted(enabled: poolSqrtPriceX96Snaphot.data == null);
                        },
                      ),
                      const SizedBox(height: 10),
                      tokenSwitcher,
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ZupMiniButton(
                      key: const Key("full-range-button"),
                      onPressed: (_) => setFullRange(),
                      isSelected: isMaxRangeInfinity && isMinRangeInfinity,
                      title: S.of(context).depositPageRangeSectionFullRange,
                      icon: Assets.icons.circleDotted.svg(),
                    ),
                    ZupMiniButton(
                      key: const Key("5-percent-range-button"),
                      onPressed: (_) => setPercentageRange(5),
                      isSelected: percentRange == 5,
                      title: "5%",
                      icon: Assets.icons.plusminus.svg(),
                      // alignLeft: true,
                    ),
                    ZupMiniButton(
                      key: const Key("20-percent-range-button"),
                      onPressed: (_) => setPercentageRange(20),
                      isSelected: percentRange == 20,
                      title: "20%",
                      icon: Assets.icons.plusminus.svg(),
                      // alignLeft: true,
                    ),
                    ZupMiniButton(
                      key: const Key("50-percent-range-button"),
                      onPressed: (_) => setPercentageRange(50),
                      isSelected: percentRange == 50,
                      title: "50%",
                      icon: Assets.icons.plusminus.svg(),
                      // alignLeft: true,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            );
          },
        ),
        StreamBuilder(
          stream: _cubit.poolSqrtPriceX96Stream,
          builder: (context, _) {
            return RangeSelector(
              key: const Key("min-price-selector"),
              onUserType: () => percentRange = null,
              onPriceChanged: (price) {
                setState(() {
                  if (price == 0) {
                    isMinRangeInfinity = true;

                    return calculateDepositTokensAmount();
                  }

                  isMinRangeInfinity = false;
                  minPrice = price;
                  calculateDepositTokensAmount();
                });
              },
              initialPrice: minPrice,
              poolToken0Decimals: _cubit.yieldPool!.token0.decimals,
              poolToken1Decimals: _cubit.yieldPool!.token1.decimals,
              isReversed: areTokensReversed,
              displayBaseTokenSymbol: baseToken.symbol,
              displayQuoteTokenSymbol: quoteToken.symbol,
              tickSpacing: _cubit.yieldPool!.tickSpacing,
              type: RangeSelectorType.minPrice,
              isInfinity: isMinRangeInfinity,
              rangeController: minRangeController,
              state: () {
                if (isOutOfRange.minPrice) {
                  return RangeSelectorState(
                    type: RangeSelectorStateType.warning,
                    message: S.of(context).depositPageMinRangeOutOfRangeWarningText,
                  );
                }

                return const RangeSelectorState(type: RangeSelectorStateType.regular);
              }.call(),
            );
          },
        ),
        const SizedBox(height: 6),
        StreamBuilder(
          stream: _cubit.poolSqrtPriceX96Stream,
          builder: (context, _) {
            return RangeSelector(
              key: const Key("max-price-selector"),
              displayBaseTokenSymbol: baseToken.symbol,
              displayQuoteTokenSymbol: quoteToken.symbol,
              onUserType: () => percentRange = null,
              onPriceChanged: (price) {
                setState(() {
                  if (price == 0) {
                    isMaxRangeInfinity = true;

                    return calculateDepositTokensAmount();
                  }

                  isMaxRangeInfinity = false;
                  maxPrice = price;

                  calculateDepositTokensAmount();
                });
              },
              type: RangeSelectorType.maxPrice,
              isInfinity: isMaxRangeInfinity,
              initialPrice: maxPrice,
              poolToken0Decimals: _cubit.yieldPool!.token0.decimals,
              poolToken1Decimals: _cubit.yieldPool!.token1.decimals,
              isReversed: areTokensReversed,
              tickSpacing: _cubit.yieldPool!.tickSpacing,
              rangeController: maxRangeController,
              state: () {
                if (isRangeInvalid) {
                  return RangeSelectorState(
                    type: RangeSelectorStateType.error,
                    message: S.of(context).depositPageInvalidRangeErrorText,
                  );
                }

                if (isOutOfRange.maxPrice) {
                  return RangeSelectorState(
                    type: RangeSelectorStateType.warning,
                    message: S.of(context).depositPageMaxRangeOutOfRangeWarningText,
                  );
                }

                return const RangeSelectorState(type: RangeSelectorStateType.regular);
              }.call(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDepositSection() => IgnorePointer(
    key: const Key("deposit-section"),
    ignoring: isRangeInvalid,
    child: AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isRangeInvalid ? 0.2 : 1,
      child: StreamBuilder(
        stream: _cubit.poolSqrtPriceX96Stream,
        initialData: _cubit.latestPoolSqrtPriceX96,
        builder: (context, sqrtPriceX96Snapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(S.of(context).depositPageDepositSectionTitle),
              const SizedBox(height: 12),
              TokenAmountInputCard(
                key: const Key("base-token-input-card"),
                token: baseToken,
                isNative: baseToken.address.lowercasedEquals(EthereumConstants.zeroAddress),
                onRefreshBalance: () => setState(() {}),
                disabledText: () {
                  if (!isBaseTokenNeeded) {
                    return S.of(context).depositPageDepositSectionTokenNotNeeded(tokenSymbol: baseToken.symbol);
                  }

                  if (!isBaseTokenAmountUserInput &&
                      !sqrtPriceX96Snapshot.hasData &&
                      quoteTokenAmountController.text.isNotEmpty) {
                    return S.of(context).loading;
                  }
                }.call(),
                onInput: (amount) {
                  setState(() {
                    isBaseTokenAmountUserInput = true;

                    calculateDepositTokensAmount();
                  });
                },
                controller: baseTokenAmountController,
                network: _cubit.yieldPool!.network,
              ),
              const SizedBox(height: 6),
              TokenAmountInputCard(
                key: const Key("quote-token-input-card"),
                token: quoteToken,
                isNative: quoteToken.address.lowercasedEquals(EthereumConstants.zeroAddress),
                onRefreshBalance: () => setState(() {}),
                disabledText: () {
                  if (!isQuoteTokenNeeded) {
                    return S.of(context).depositPageDepositSectionTokenNotNeeded(tokenSymbol: quoteToken.symbol);
                  }

                  if (isBaseTokenAmountUserInput &&
                      !sqrtPriceX96Snapshot.hasData &&
                      baseTokenAmountController.text.isNotEmpty) {
                    return S.of(context).loading;
                  }
                }.call(),
                onInput: (amount) {
                  setState(() {
                    isBaseTokenAmountUserInput = false;

                    calculateDepositTokensAmount();
                  });
                },
                controller: quoteTokenAmountController,
                network: _cubit.yieldPool!.network,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: StreamBuilder(
                      key: const Key("deposit-button"),
                      stream: wallet.signerStream,
                      initialData: wallet.signer,
                      builder: (context, signerSnapshot) {
                        if (!signerSnapshot.hasData) {
                          return ZupPrimaryButton(
                            width: double.maxFinite,
                            title: S.of(context).connectWallet,
                            icon: Assets.icons.walletBifold.svg(),
                            fixedIcon: true,
                            alignCenter: true,
                            hoverElevation: 0,
                            backgroundColor: ZupColors.brand.withValues(alpha: 0.1),
                            foregroundColor: ZupColors.brand,
                            onPressed: (buttonContext) => ConnectModal().show(context),
                          );
                        }

                        return FutureBuilder(
                          future: depositButtonState(),
                          builder: (context, stateSnapshot) {
                            return ZupPrimaryButton(
                              alignCenter: true,
                              title: stateSnapshot.data?.title ?? S.of(context).loading,
                              icon: stateSnapshot.data?.icon,
                              isLoading: stateSnapshot.connectionState == ConnectionState.waiting,
                              fixedIcon: true,
                              onPressed: stateSnapshot.data?.onPressed == null
                                  ? null
                                  : (buttonContext) => stateSnapshot.data?.onPressed!(),
                              width: double.maxFinite,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    ),
  );
}
