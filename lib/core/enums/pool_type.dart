import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';

enum PoolType {
  @JsonValue("V3")
  v3,
  @JsonValue("V4")
  v4,
  unknown;

  bool get isV3 => this == PoolType.v3;
  bool get isV4 => this == PoolType.v4;

  String get label => switch (this) {
    PoolType.v3 => "V3",
    PoolType.v4 => "V4",
    PoolType.unknown => "Unknown",
  };

  String description(BuildContext context) => switch (this) {
    PoolType.v3 => S.of(context).poolTypeV3Description,
    PoolType.v4 => S.of(context).poolTypeV4Description,
    PoolType.unknown => "",
  };
}
