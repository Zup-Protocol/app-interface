import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';
import 'package:zup_app/core/dtos/deposit_page_arguments_dto.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/enums/yield_timeframe.dart';
import 'package:zup_app/core/enums/zup_navigator_paths.dart';
import 'package:zup_app/core/zup_route_params_names.dart';

class ZupNavigator {
  Listenable get listenable => Routefly.listenable;

  String get currentRoute => Routefly.currentUri.path;

  String? getQueryParam(String paramName) => Routefly.query.params[paramName];

  String? getQuery(String queryName) => Routefly.query[queryName].toString();

  String? get getIdFromPath => Routefly.query["id"].toString();

  Map<String, dynamic> get currentPageArguments => Routefly.query.arguments ?? {};

  void back(BuildContext context) async => Routefly.pop(context);

  bool canBack(BuildContext context) => Navigator.of(context).canPop();

  Future<void> navigateToNewPosition() async => await Routefly.navigate(ZupNavigatorPaths.newPosition.path);

  Future<void> navigateToYields({
    required String? token0,
    required String? token1,
    required String? group0,
    required String? group1,
    required AppNetworks network,
  }) async {
    const yieldsPath = ZupNavigatorPaths.yields;
    final yieldsPathParamNames = yieldsPath.routeParamsNames<YieldsRouteParamsNames>();

    final token0UrlParam = token0 != null ? _buildUrlParam(yieldsPathParamNames.token0, token0) : "";
    final token1UrlParam = token1 != null ? _buildUrlParam(yieldsPathParamNames.token1, token1) : "";
    final group0UrlParam = group0 != null ? _buildUrlParam(yieldsPathParamNames.group0, group0) : "";
    final group1UrlParam = group1 != null ? _buildUrlParam(yieldsPathParamNames.group1, group1) : "";
    final networkUrlParam = _buildUrlParam(yieldsPathParamNames.network, network.name);

    return await Routefly.pushNavigate(
      "${yieldsPath.path}?$token0UrlParam&$token1UrlParam&$group0UrlParam&$group1UrlParam&$networkUrlParam",
    );
  }

  Future<void> navigateToInitial() async => await Routefly.navigate(ZupNavigatorPaths.initial.path);

  Future<void> navigateToDeposit({
    required YieldDto yieldPool,
    required YieldTimeFrame selectedTimeframe,
    required bool parseWrappedToNative,
  }) async {
    final depositPathParamNames = ZupNavigatorPaths.deposit.routeParamsNames<DepositRouteParamsNames>();

    final poolNetworkUrlParam = _buildUrlParam(depositPathParamNames.network, yieldPool.network.name);
    final timeframeUrlParam = _buildUrlParam(depositPathParamNames.timeframe, selectedTimeframe.name);
    final parseWrappedToNativeParam = _buildUrlParam(
      depositPathParamNames.parseWrappedToNative,
      parseWrappedToNative.toString(),
    );

    final rawPath = ZupNavigatorPaths.deposit.path.changes({"id": yieldPool.poolAddress});

    await Routefly.pushNavigate(
      "$rawPath?$poolNetworkUrlParam&$timeframeUrlParam&$parseWrappedToNativeParam",
      arguments: DepositPageArgumentsDto(yieldPool: yieldPool).toJson(),
    );
  }

  String _buildUrlParam(String paramName, String paramValue) {
    return "$paramName=$paramValue";
  }
}
