import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:zup_app/core/dtos/liquidity_pool_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/widgets/pool_tokens_button.dart';
import 'package:zup_core/test_utils.dart';
import 'package:zup_ui_kit/zup_network_image.dart';

import '../golden_config.dart';
import '../mocks.dart';

void main() {
  setUp(() {
    UrlLauncherPlatform.instance = UrlLauncherPlatformCustomMock();
    inject.registerFactory<ZupNetworkImage>(() => mockZupNetworkImage());
  });

  tearDown(() => inject.reset());

  Future<DeviceBuilder> goldenBuilder({LiquidityPoolDto? customPool}) async {
    return await goldenDeviceBuilder(
      Center(child: PoolTokensButton(liquidityPool: customPool ?? LiquidityPoolDto.fixture())),
      device: GoldenDevice.square,
    );
  }

  zGoldenTest(
    "When the dexscrenner URL is null at the pool network, the button should be disabled",
    goldenFileName: "pool_tokens_button_disabled",
    (tester) async {
      await tester.pumpDeviceBuilder(
        await goldenBuilder(customPool: LiquidityPoolDto.fixture().copyWith(chainId: AppNetworks.sepolia.chainId)),
      );
    },
  );

  zGoldenTest(
    "When the dexscrenner URL is not null at the pool network, the button should be in enabled state",
    goldenFileName: "pool_tokens_button_enabled",
    (tester) async {
      await tester.pumpDeviceBuilder(
        await goldenBuilder(customPool: LiquidityPoolDto.fixture().copyWith(chainId: AppNetworks.mainnet.chainId)),
      );
    },
  );

  zGoldenTest(
    """When the button is enabled, and the user hovers the button, it should show a tooltip with a message
    about launching on dex screener""",
    goldenFileName: "pool_tokens_button_tooltip",
    (tester) async {
      await tester.pumpDeviceBuilder(
        await goldenBuilder(customPool: LiquidityPoolDto.fixture().copyWith(chainId: AppNetworks.mainnet.chainId)),
      );

      await tester.hover(find.byType(PoolTokensButton));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the button is enabled, and is clicked, it should launch on dex screener at
    the current network and with the correct pool address""",
    (tester) async {
      const network = AppNetworks.unichain;
      final pool = LiquidityPoolDto.fixture().copyWith(chainId: network.chainId);

      await tester.pumpDeviceBuilder(await goldenBuilder(customPool: pool));

      await tester.tap(find.byType(PoolTokensButton));
      await tester.pumpAndSettle();

      expect(UrlLauncherPlatformCustomMock.lastLaunchedUrl, "${pool.network.dexscreenerUrl}/${pool.poolAddress}");
    },
  );

  zGoldenTest("""When the button is disabled, and is clicked, it should not launch anything""", (tester) async {
    const network = AppNetworks.sepolia;
    final pool = LiquidityPoolDto.fixture().copyWith(chainId: network.chainId);

    await tester.pumpDeviceBuilder(await goldenBuilder(customPool: pool));

    await tester.tap(find.byType(PoolTokensButton));
    await tester.pumpAndSettle();

    expect(UrlLauncherPlatformCustomMock.lastLaunchedUrl, null);
  });
}
