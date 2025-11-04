import 'package:freezed_annotation/freezed_annotation.dart';

part 'protocol_id.g.dart';

@JsonEnum(alwaysCreate: true)
enum ProtocolId {
  @JsonValue("pancakeswap-infinity-cl")
  pancakeSwapInfinityCL,
  @JsonValue("aerodrome-v3")
  aerodromeSlipstream,
  @JsonValue("velodrome-v3")
  velodromeSlipstream,
  @JsonValue("gliquid-v3")
  gliquidV3,
  @JsonValue("kittenswap-v3")
  kittenswapV3,
  @JsonValue("hx-finance-algebra")
  hxFinanceAlgebra,
  unknown;

  bool get isPancakeSwapInfinityCL => this == ProtocolId.pancakeSwapInfinityCL;
  bool get isAerodromeOrVelodromeSlipstream =>
      (this == ProtocolId.aerodromeSlipstream || this == ProtocolId.velodromeSlipstream);
  bool get isGLiquidV3 => this == ProtocolId.gliquidV3;
  bool get isKittenswapV3 => this == ProtocolId.kittenswapV3;
  bool get isHxFinanceAlgebra => this == ProtocolId.hxFinanceAlgebra;

  bool get isAlgebra1_2 => isGLiquidV3 || isKittenswapV3 || isHxFinanceAlgebra;

  String get toRawJsonValue => _$ProtocolIdEnumMap[this]!;
}
