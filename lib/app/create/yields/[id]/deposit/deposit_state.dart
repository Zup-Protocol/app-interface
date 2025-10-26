part of 'deposit_cubit.dart';

@freezed
class DepositState with _$DepositState {
  const factory DepositState.initial() = _Initial;
  const factory DepositState.loading() = _Loading;
  const factory DepositState.success(LiquidityPoolDto yieldPool) = _Success;
  const factory DepositState.error() = _Error;
}
