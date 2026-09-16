// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:thumbico/common/sampled_runner.dart';

void main() {
  /// A job that stays in flight until its gate is completed, one gate per run.
  late List<Completer<void>> gates;
  Future<void> gatedJob() {
    final gate = Completer<void>();
    gates.add(gate);
    return gate.future;
  }

  setUp(() => gates = []);

  test('a request runs the job at once while nothing is running', () async {
    final runner = SampledRunner(gatedJob);
    addTearDown(runner.dispose);

    runner.request();
    await pumpEventQueue();

    expect(gates, hasLength(1));
  });

  test('requests made during a run collapse into exactly one more run', () async {
    final runner = SampledRunner(gatedJob);
    addTearDown(runner.dispose);
    runner.request();
    await pumpEventQueue();

    runner.request();
    runner.request();
    runner.request();
    await pumpEventQueue();
    expect(gates, hasLength(1), reason: 'nothing starts while a run is in flight');

    gates[0].complete();
    await pumpEventQueue();
    expect(gates, hasLength(2), reason: 'the three requests became one run');

    gates[1].complete();
    await pumpEventQueue();
    expect(gates, hasLength(2), reason: 'and nothing more');
  });

  test('the run that follows a burst sees the state as it is when it starts', () async {
    var size = 0;
    final seen = <int>[];
    final runner = SampledRunner(() {
      seen.add(size);
      return gatedJob();
    });
    addTearDown(runner.dispose);

    size = 1;
    runner.request();
    await pumpEventQueue();
    size = 2;
    runner.request();
    size = 3;
    runner.request();
    gates[0].complete();
    await pumpEventQueue();
    gates[1].complete();
    await pumpEventQueue();

    expect(seen, [1, 3]);
  });

  test('a request after the run ends starts a new run', () async {
    final runner = SampledRunner(gatedJob);
    addTearDown(runner.dispose);
    runner.request();
    await pumpEventQueue();
    gates[0].complete();
    await pumpEventQueue();

    runner.request();
    await pumpEventQueue();

    expect(gates, hasLength(2));
  });

  test('a run in flight finishes on its own after dispose, and no new one starts', () async {
    final runner = SampledRunner(gatedJob);
    runner.request();
    await pumpEventQueue();

    runner.dispose();
    gates[0].complete();
    await pumpEventQueue();

    expect(gates, hasLength(1));
  });
}
