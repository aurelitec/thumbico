// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'dart:async';

import 'package:stream_transform/stream_transform.dart';

/// Runs one job at most once at a time; requests made while it runs collapse into one more run.
///
/// Built on stream_transform's `asyncMapSample`: a request during a run is held, a newer
/// request replaces the held one, and the held request runs when the current run ends. The
/// job reads its inputs when it starts, so the run after a burst sees the burst's final state.
/// The job must handle its own errors; one that throws is reported as uncaught.
class SampledRunner(Future<void> Function() job) {
  /// Every request, delivered to the job through the sampling operator.
  final _requests = StreamController<void>();

  /// What drives the operator; a stream does nothing until it is listened to.
  late final StreamSubscription<void> _subscription;

  this {
    _subscription = _requests.stream.asyncMapSample((_) => job()).listen((_) {});
  }

  /// Asks for a run: now if nothing is running, otherwise once after the current run.
  void request() => _requests.add(null);

  /// Stops taking requests. A run in flight finishes on its own; do not request after this.
  void dispose() {
    _subscription.cancel();
    _requests.close();
  }
}
