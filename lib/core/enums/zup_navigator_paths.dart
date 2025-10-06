import 'package:zup_app/core/zup_route_params_names.dart';
import 'package:zup_app/zup_app.dart';

enum ZupNavigatorPaths {
  initial,
  newPosition,
  yields,
  deposit;

  String get path => switch (this) {
    initial => routePaths.create.path,
    newPosition => routePaths.create.path,
    yields => routePaths.create.yields,
    deposit => routePaths.create.deposit,
  };

  T routeParamsNames<T extends ZupRouteParamsNames>() {
    final params = switch (this) {
      initial => InitialRouteParamsNames(),
      newPosition => NewPositionRouteParamsNames(),
      yields => YieldsRouteParamsNames(),
      deposit => DepositRouteParamsNames(),
    };

    return params as T;
  }
}
