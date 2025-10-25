import 'package:flutter_test/flutter_test.dart';
import 'package:web3kit/core/ethereum_constants.dart';
import 'package:zup_app/core/concentrated_liquidity_utils/cl_pool_constants.dart';
import 'package:zup_app/core/dtos/hook_dto.dart';
import 'package:zup_app/core/dtos/pool_stats_dto.dart';
import 'package:zup_app/core/dtos/protocol_dto.dart';
import 'package:zup_app/core/dtos/single_chain_token_dto.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/enums/pool_data_timeframe.dart';
import 'package:zup_app/core/extensions/num_extension.dart';

void main() {
  test("When calling `isToken0Native` and the token0 address in the yield network is zero, it should return true", () {
    const network = AppNetworks.sepolia;
    expect(
      YieldDto.fixture()
          .copyWith(
            chainId: network.chainId,
            token0: SingleChainTokenDto.fixture().copyWith(address: EthereumConstants.zeroAddress),
          )
          .isToken0Native,
      true,
    );
  });

  test("When calling `isToken1Native` and the token1 address in the yield network is zero, it should return true", () {
    const network = AppNetworks.sepolia;
    expect(
      YieldDto.fixture()
          .copyWith(
            chainId: network.chainId,
            token1: SingleChainTokenDto.fixture().copyWith(address: EthereumConstants.zeroAddress),
          )
          .isToken1Native,
      true,
    );
  });

  test("When calling `isToken0Native` and the token0 address in the yield network is not, it should return false", () {
    const network = AppNetworks.sepolia;
    expect(
      YieldDto.fixture()
          .copyWith(
            chainId: network.chainId,
            token0: SingleChainTokenDto.fixture().copyWith(address: "0x1"),
          )
          .isToken0Native,
      false,
    );
  });

  test("When calling `isToken1Native` and the token1 address in the yield network is not, it should return false", () {
    const network = AppNetworks.sepolia;
    expect(
      YieldDto.fixture()
          .copyWith(
            chainId: network.chainId,
            token1: SingleChainTokenDto.fixture().copyWith(address: "0x1"),
          )
          .isToken1Native,
      false,
    );
  });

  test("When calling 'yieldTimeframed' passing a 24h timeframe, it should get the 24h yield", () {
    const yield24h = 261782;
    final currentYield = YieldDto.fixture().copyWith(
      total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: yield24h),
    );

    expect(currentYield.yieldTimeframed(PoolDataTimeframe.day), yield24h);
  });

  test("When calling 'yieldTimeframed' passing a 7d timeframe, it should get the 90d yield", () {
    const yield7d = 819028190;
    final currentYield = YieldDto.fixture().copyWith(
      total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: yield7d),
    );

    expect(currentYield.yieldTimeframed(PoolDataTimeframe.week), yield7d);
  });

  test("When calling 'yieldTimeframed' passing a 30d timeframe, it should get the 90d yield", () {
    const yield30d = 8.9787678;
    final currentYield = YieldDto.fixture().copyWith(
      total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: yield30d),
    );

    expect(currentYield.yieldTimeframed(PoolDataTimeframe.month), yield30d);
  });

  test("When calling 'yieldTimeframed' passing a 90d timeframe, it should get the 90d yield", () {
    const yield90d = 12718728.222;
    final currentYield = YieldDto.fixture().copyWith(
      total90dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: yield90d),
    );

    expect(currentYield.yieldTimeframed(PoolDataTimeframe.threeMonth), yield90d);
  });

  test("When building the yield dto with default variables, the deployerAddress should be zero address by default", () {
    expect(
      YieldDto(
        token0: SingleChainTokenDto.fixture(),
        token1: SingleChainTokenDto.fixture(),
        poolAddress: "0x1",
        chainId: AppNetworks.sepolia.chainId,
        positionManagerAddress: "0x2",
        tickSpacing: 1,
        protocol: ProtocolDto.fixture(),
        initialFeeTier: 0,
        currentFeeTier: 0,
      ).deployerAddress,
      EthereumConstants.zeroAddress,
    );
  });

  test("When building the yield dto with default variables, the hooks should be null", () {
    expect(
      YieldDto(
        token0: SingleChainTokenDto.fixture(),
        token1: SingleChainTokenDto.fixture(),
        poolAddress: "0x1",
        chainId: AppNetworks.sepolia.chainId,
        positionManagerAddress: "0x2",
        tickSpacing: 1,
        protocol: ProtocolDto.fixture(),
        initialFeeTier: 0,
        currentFeeTier: 0,
      ).hook,
      null,
    );
  });

  test(
    """When using 'timeframedYieldFormatted' passing day timeframe,
    and the 24h yield is not zero it should return me the formatted
    24h yield with percent sign""",
    () {
      final yieldDto = YieldDto.fixture().copyWith(
        total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 2.3213),
      );
      expect(yieldDto.timeframedYieldFormatted(PoolDataTimeframe.day), "2.3%");
    },
  );

  test(
    """When using 'timeframedYieldFormatted' passing week timeframe,
    and the 7d yield is not zero it should return me the formatted
    7d yield with percent sign""",
    () {
      final yieldDto = YieldDto.fixture().copyWith(
        total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 121.335),
      );
      expect(yieldDto.timeframedYieldFormatted(PoolDataTimeframe.week), "121.3%");
    },
  );

  test(
    """When using 'timeframedYieldFormatted' passing month timeframe,
    and the 30d yield is not zero it should return me the formatted
    30d yield with percent sign""",
    () {
      final yieldDto = YieldDto.fixture().copyWith(
        total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 11.335),
      );
      expect(yieldDto.timeframedYieldFormatted(PoolDataTimeframe.month), "11.3%");
    },
  );

  test(
    """When using 'timeframedYieldFormatted' passing a three month timeframe,
    and the 90d yield is not zero it should return me the formatted
    90d yield with percent sign""",
    () {
      final yieldDto = YieldDto.fixture().copyWith(
        total90dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 99.87),
      );
      expect(yieldDto.timeframedYieldFormatted(PoolDataTimeframe.threeMonth), "99.9%");
    },
  );

  test(
    """When using 'timeframedYieldFormatted' passing day timeframe,
    and the 24h yield is zero it should return me just a hyphen""",
    () {
      final yieldDto = YieldDto.fixture().copyWith(total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 0));
      expect(yieldDto.timeframedYieldFormatted(PoolDataTimeframe.day), "-");
    },
  );

  test(
    """When using 'timeframedYieldFormatted' passing week timeframe,
    and the 7d yield is zero it should return me just a hyphen""",
    () {
      final yieldDto = YieldDto.fixture().copyWith(total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 0));
      expect(yieldDto.timeframedYieldFormatted(PoolDataTimeframe.week), "-");
    },
  );

  test(
    """When using 'timeframedYieldFormatted' passing month timeframe,
    and the 30d yield is zero it should return me just a hyphen""",
    () {
      final yieldDto = YieldDto.fixture().copyWith(total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 0));
      expect(yieldDto.timeframedYieldFormatted(PoolDataTimeframe.month), "-");
    },
  );

  test(
    """When using 'timeframedYieldFormatted' passing three months
    timeframe, and the 90d yield is zero it should return me just a hyphen""",
    () {
      final yieldDto = YieldDto.fixture().copyWith(total90dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 0));
      expect(yieldDto.timeframedYieldFormatted(PoolDataTimeframe.threeMonth), "-");
    },
  );

  test(
    """When using 'currentFeeTierFormatted' it should return the current
  fee tier divided by the fee tier factor (10000) as percentage""",
    () {
      const currentFeeTier = 10000;
      final yieldDto = YieldDto.fixture().copyWith(currentFeeTier: currentFeeTier);

      expect(yieldDto.currentFeeTierFormatted, "${currentFeeTier / CLPoolConstants.feeTierFactor}%");
    },
  );

  test("When using 'isDynamicFee' and the hook is null, it should return false", () {
    final yieldDto = YieldDto.fixture().copyWith(hook: null);

    expect(yieldDto.isDynamicFee, false);
  });

  test("When using 'isDynamicFee' and the hook has the property is dynamic fee false, it should return false", () {
    final yieldDto = YieldDto.fixture().copyWith(hook: HookDto.fixture().copyWith(isDynamicFee: false));

    expect(yieldDto.isDynamicFee, false);
  });

  test("When using 'isDynamicFee' and the hook has the property is dynamic fee true, it should return true", () {
    final yieldDto = YieldDto.fixture().copyWith(hook: HookDto.fixture().copyWith(isDynamicFee: true));

    expect(yieldDto.isDynamicFee, true);
  });

  test(
    """When using 'createdAtMillisecondsTimestamp' it should multiply the createdAtTimestamp
   of the pool by 1000 to convert it from seconds to milliseconds""",
    () {
      const createdAtTimestamp = 1666000000;
      final yieldDto = YieldDto.fixture().copyWith(createdAtTimestamp: createdAtTimestamp);

      expect(yieldDto.createdAtMillisecondsTimestamp, createdAtTimestamp * 1000);
    },
  );

  test(
    """When using 'timeframedYieldFormatted' passing the day timeframe,
  but the total24hStats yield is zero,it should return just a hyphen""",
    () {
      final yieldDto = YieldDto.fixture().copyWith(total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 0));
      expect(yieldDto.timeframedYieldFormatted(PoolDataTimeframe.day), "-");
    },
  );

  test(
    """When using 'timeframedYieldFormatted' passing the week timeframe,
  but the total7dStats yield is zero, it should return just a hyphen""",
    () {
      final yieldDto = YieldDto.fixture().copyWith(total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 0));
      expect(yieldDto.timeframedYieldFormatted(PoolDataTimeframe.week), "-");
    },
  );

  test(
    """When using 'timeframedYieldFormatted' passing the month timeframe,
  but the total30dStats yield is zero, it should return just a hyphen""",
    () {
      final yieldDto = YieldDto.fixture().copyWith(total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 0));
      expect(yieldDto.timeframedYieldFormatted(PoolDataTimeframe.month), "-");
    },
  );

  test(
    """When using 'timeframedYieldFormatted' passing the three months timeframe,
  but the total90dStats yield is zero, it should return just a hyphen""",
    () {
      final yieldDto = YieldDto.fixture().copyWith(total90dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: 0));
      expect(yieldDto.timeframedYieldFormatted(PoolDataTimeframe.threeMonth), "-");
    },
  );

  test(
    """When using 'timeframedYieldFormatted' passing the day timeframe,
   but the total24hStats is null, it should return just a hyphen""",
    () {
      final yieldDto = YieldDto.fixture().copyWith(total24hStats: null);
      expect(yieldDto.timeframedYieldFormatted(PoolDataTimeframe.day), "-");
    },
  );

  test(
    """When using 'timeframedYieldFormatted' passing the week timeframe,
   but the total7dStats is null, it should return just a hyphen""",
    () {
      final yieldDto = YieldDto.fixture().copyWith(total7dStats: null);
      expect(yieldDto.timeframedYieldFormatted(PoolDataTimeframe.week), "-");
    },
  );

  test(
    """When using 'timeframedYieldFormatted' passing the month timeframe,
   but the total30dStats is null, it should return just a hyphen""",
    () {
      final yieldDto = YieldDto.fixture().copyWith(total30dStats: null);
      expect(yieldDto.timeframedYieldFormatted(PoolDataTimeframe.month), "-");
    },
  );

  test(
    """When using 'timeframedYieldFormatted' passing the three months timeframe,
   but the total90dStats is null, it should return just a hyphen""",
    () {
      final yieldDto = YieldDto.fixture().copyWith(total90dStats: null);
      expect(yieldDto.timeframedYieldFormatted(PoolDataTimeframe.threeMonth), "-");
    },
  );

  test(
    """When using 'timeframedYieldFormatted' passing the day timeframe, and it's not zero,
  it should return the formatted yield as a percentage""",
    () {
      const yearlyYield = 999;

      final yieldDto = YieldDto.fixture().copyWith(
        total24hStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: yearlyYield),
      );
      expect(yieldDto.timeframedYieldFormatted(PoolDataTimeframe.day), yearlyYield.formatRoundingPercent);
    },
  );

  test(
    """When using 'timeframedYieldFormatted' passing the week timeframe, and it's not zero,
  it should return the formatted yield as a percentage""",
    () {
      const yearlyYield = 1212.12;

      final yieldDto = YieldDto.fixture().copyWith(
        total7dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: yearlyYield),
      );
      expect(yieldDto.timeframedYieldFormatted(PoolDataTimeframe.week), yearlyYield.formatRoundingPercent);
    },
  );

  test(
    """When using 'timeframedYieldFormatted' passing the month timeframe, and it's not zero,
  it should return the formatted yield as a percentage""",
    () {
      const yearlyYield = 128.11;

      final yieldDto = YieldDto.fixture().copyWith(
        total30dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: yearlyYield),
      );
      expect(yieldDto.timeframedYieldFormatted(PoolDataTimeframe.month), yearlyYield.formatRoundingPercent);
    },
  );

  test(
    """When using 'timeframedYieldFormatted' passing the three months timeframe, and it's not zero,
  it should return the formatted yield as a percentage""",
    () {
      const yearlyYield = 2157821.212;

      final yieldDto = YieldDto.fixture().copyWith(
        total90dStats: PoolTotalStatsDTO.fixture().copyWith(yearlyYield: yearlyYield),
      );
      expect(yieldDto.timeframedYieldFormatted(PoolDataTimeframe.threeMonth), yearlyYield.formatRoundingPercent);
    },
  );

  group("volumeTimeframed", () {
    test("When calling 'volumeTimeframed' passing a 24h timeframe, it should return the 24h total volume", () {
      const volume24h = 1000.5;
      final yieldDto = YieldDto.fixture().copyWith(
        total24hStats: PoolTotalStatsDTO.fixture().copyWith(totalVolume: volume24h),
      );

      expect(yieldDto.volumeTimeframed(PoolDataTimeframe.day), volume24h);
    });

    test("When calling 'volumeTimeframed' passing a 7d timeframe, it should return the 7d total volume", () {
      const volume7d = 55000.12;
      final yieldDto = YieldDto.fixture().copyWith(
        total7dStats: PoolTotalStatsDTO.fixture().copyWith(totalVolume: volume7d),
      );

      expect(yieldDto.volumeTimeframed(PoolDataTimeframe.week), volume7d);
    });

    test("When calling 'volumeTimeframed' passing a 30d timeframe, it should return the 30d total volume", () {
      const volume30d = 812312.999;
      final yieldDto = YieldDto.fixture().copyWith(
        total30dStats: PoolTotalStatsDTO.fixture().copyWith(totalVolume: volume30d),
      );

      expect(yieldDto.volumeTimeframed(PoolDataTimeframe.month), volume30d);
    });

    test("When calling 'volumeTimeframed' passing a 90d timeframe, it should return the 90d total volume", () {
      const volume90d = 987654.321;
      final yieldDto = YieldDto.fixture().copyWith(
        total90dStats: PoolTotalStatsDTO.fixture().copyWith(totalVolume: volume90d),
      );

      expect(yieldDto.volumeTimeframed(PoolDataTimeframe.threeMonth), volume90d);
    });

    test("When calling 'volumeTimeframed' but the timeframe stats are null, it should return 0", () {
      final yieldDto = YieldDto.fixture().copyWith(
        total24hStats: null,
        total7dStats: null,
        total30dStats: null,
        total90dStats: null,
      );

      expect(yieldDto.volumeTimeframed(PoolDataTimeframe.day), 0);
      expect(yieldDto.volumeTimeframed(PoolDataTimeframe.week), 0);
      expect(yieldDto.volumeTimeframed(PoolDataTimeframe.month), 0);
      expect(yieldDto.volumeTimeframed(PoolDataTimeframe.threeMonth), 0);
    });
  });

  group("feesTimeframed", () {
    test("When calling 'feesTimeframed' passing a 24h timeframe, it should return the 24h total fees", () {
      const fees24h = 123.45;
      final yieldDto = YieldDto.fixture().copyWith(
        total24hStats: PoolTotalStatsDTO.fixture().copyWith(totalFees: fees24h),
      );

      expect(yieldDto.feesTimeframed(PoolDataTimeframe.day), fees24h);
    });

    test("When calling 'feesTimeframed' passing a 7d timeframe, it should return the 7d total fees", () {
      const fees7d = 1000.99;
      final yieldDto = YieldDto.fixture().copyWith(
        total7dStats: PoolTotalStatsDTO.fixture().copyWith(totalFees: fees7d),
      );

      expect(yieldDto.feesTimeframed(PoolDataTimeframe.week), fees7d);
    });

    test("When calling 'feesTimeframed' passing a 30d timeframe, it should return the 30d total fees", () {
      const fees30d = 12345.67;
      final yieldDto = YieldDto.fixture().copyWith(
        total30dStats: PoolTotalStatsDTO.fixture().copyWith(totalFees: fees30d),
      );

      expect(yieldDto.feesTimeframed(PoolDataTimeframe.month), fees30d);
    });

    test("When calling 'feesTimeframed' passing a 90d timeframe, it should return the 90d total fees", () {
      const fees90d = 999999.99;
      final yieldDto = YieldDto.fixture().copyWith(
        total90dStats: PoolTotalStatsDTO.fixture().copyWith(totalFees: fees90d),
      );

      expect(yieldDto.feesTimeframed(PoolDataTimeframe.threeMonth), fees90d);
    });

    test("When calling 'feesTimeframed' but the timeframe stats are null, it should return 0", () {
      final yieldDto = YieldDto.fixture().copyWith(
        total24hStats: null,
        total7dStats: null,
        total30dStats: null,
        total90dStats: null,
      );

      expect(yieldDto.feesTimeframed(PoolDataTimeframe.day), 0);
      expect(yieldDto.feesTimeframed(PoolDataTimeframe.week), 0);
      expect(yieldDto.feesTimeframed(PoolDataTimeframe.month), 0);
      expect(yieldDto.feesTimeframed(PoolDataTimeframe.threeMonth), 0);
    });
  });
  group("netInflowTimeframed", () {
    test("When calling 'netInflowTimeframed' passing a 24h timeframe, it should return the 24h total net inflow", () {
      const netInflow24h = 500.25;
      final yieldDto = YieldDto.fixture().copyWith(
        total24hStats: PoolTotalStatsDTO.fixture().copyWith(totalNetInflow: netInflow24h),
      );

      expect(yieldDto.netInflowTimeframed(PoolDataTimeframe.day), netInflow24h);
    });

    test("When calling 'netInflowTimeframed' passing a 7d timeframe, it should return the 7d total net inflow", () {
      const netInflow7d = 12345.67;
      final yieldDto = YieldDto.fixture().copyWith(
        total7dStats: PoolTotalStatsDTO.fixture().copyWith(totalNetInflow: netInflow7d),
      );

      expect(yieldDto.netInflowTimeframed(PoolDataTimeframe.week), netInflow7d);
    });

    test("When calling 'netInflowTimeframed' passing a 30d timeframe, it should return the 30d total net inflow", () {
      const netInflow30d = 999999.99;
      final yieldDto = YieldDto.fixture().copyWith(
        total30dStats: PoolTotalStatsDTO.fixture().copyWith(totalNetInflow: netInflow30d),
      );

      expect(yieldDto.netInflowTimeframed(PoolDataTimeframe.month), netInflow30d);
    });

    test("When calling 'netInflowTimeframed' passing a 90d timeframe, it should return the 90d total net inflow", () {
      const netInflow90d = 8888888.888;
      final yieldDto = YieldDto.fixture().copyWith(
        total90dStats: PoolTotalStatsDTO.fixture().copyWith(totalNetInflow: netInflow90d),
      );

      expect(yieldDto.netInflowTimeframed(PoolDataTimeframe.threeMonth), netInflow90d);
    });

    test("When calling 'netInflowTimeframed' but the timeframe stats are null, it should return 0", () {
      final yieldDto = YieldDto.fixture().copyWith(
        total24hStats: null,
        total7dStats: null,
        total30dStats: null,
        total90dStats: null,
      );

      expect(yieldDto.netInflowTimeframed(PoolDataTimeframe.day), 0);
      expect(yieldDto.netInflowTimeframed(PoolDataTimeframe.week), 0);
      expect(yieldDto.netInflowTimeframed(PoolDataTimeframe.month), 0);
      expect(yieldDto.netInflowTimeframed(PoolDataTimeframe.threeMonth), 0);
    });
  });
}
