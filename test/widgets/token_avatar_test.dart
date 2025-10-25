import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:zup_app/core/dtos/multi_chain_token_dto.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_ui_kit/zup_network_image.dart';
import 'package:zup_ui_kit/zup_remote_avatar.dart';

import '../golden_config.dart';
import '../mocks.dart';

void main() {
  setUp(() {
    inject.registerFactory<ZupNetworkImage>(() => mockZupNetworkImage());
  });

  tearDown(() => inject.reset());

  Future<DeviceBuilder> goldenBuilder({MultiChainTokenDto? token, double size = 30}) => goldenDeviceBuilder(
    Center(
      child: ZupRemoteAvatar(avatarUrl: 'https://www.google.com.br', errorPlaceholder: 'Zup', size: size),
    ),
    device: GoldenDevice.square,
  );

  zGoldenTest(
    "When the logoUrl from the dto is empty, it should create an avatar with the initial letter of the token name",
    goldenFileName: "token_avatar_empty_logo_url",
    (tester) async {
      await tester.pumpDeviceBuilder(
        await goldenBuilder(
          token: MultiChainTokenDto.fixture().copyWith(logoUrl: '', name: "ZUP TOKEN"),
        ),
      );
    },
  );

  zGoldenTest(
    "When the logoUrl from the dto is not empty, it should use the url to get the image with $ZupNetworkImage",
    goldenFileName: "token_avatar_not_empty_logo_url",
    (tester) async {
      const url = "some_url";

      await tester.pumpDeviceBuilder(await goldenBuilder(token: MultiChainTokenDto.fixture().copyWith(logoUrl: url)));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest("When passing a size to the widget, it should be applied", goldenFileName: "token_avatar_size", (
    tester,
  ) async {
    await tester.pumpDeviceBuilder(
      await goldenBuilder(token: MultiChainTokenDto.fixture().copyWith(logoUrl: ''), size: 200),
    );
  });
}
