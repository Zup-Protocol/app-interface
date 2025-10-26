import 'package:flutter/material.dart';
import 'package:zup_app/core/dtos/liquidity_pool_dto.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

class PoolTokensAvatar extends StatelessWidget {
  const PoolTokensAvatar({super.key, required this.liquidityPool, this.size = 27});

  final LiquidityPoolDto liquidityPool;
  final double size;

  ZupNetworkImage get zupNetworkImage => inject<ZupNetworkImage>();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 2,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ZupRemoteAvatar(
            avatarUrl: liquidityPool.token0.logoUrl,
            errorPlaceholder: liquidityPool.token0.name.isEmpty ? null : liquidityPool.token0.name[0],
            size: size,
            zupNetworkImage: zupNetworkImage,
          ),
          Positioned(
            left: 20,
            child: ZupRemoteAvatar(
              avatarUrl: liquidityPool.token1.logoUrl,
              errorPlaceholder: liquidityPool.token1.name.isEmpty ? null : liquidityPool.token1.name[0],
              zupNetworkImage: zupNetworkImage,
              size: size,
            ),
          ),
        ],
      ),
    );
  }
}
