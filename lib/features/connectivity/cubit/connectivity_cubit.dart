import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_notes/features/connectivity/cubit/connectivity_state.dart';

/// Watches network changes and emits whether the device is *really* online.
class ConnectivityCubit extends Cubit<ConnectivityState> {
  ConnectivityCubit() : super(ConnectivityChecking());

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  /// Starts listening to connectivity changes and runs an initial check.
  void watchConnectivity() {
    _connectivitySub?.cancel();
    _connectivitySub = Connectivity().onConnectivityChanged.listen(
      (_) => _recheck(),
    );
    unawaited(_recheck());
  }

  Future<void> _recheck() async {
    final results = await Connectivity().checkConnectivity();
    final hasNetwork = results.any((r) => r != ConnectivityResult.none);
    if (!hasNetwork) {
      _safeEmit(ConnectivityOffline());
      return;
    }
    final online = await _hasRealInternet();
    _safeEmit(online ? ConnectivityOnline() : ConnectivityOffline());
  }

  /// connectivity_plus only reports the network interface (wifi/mobile),
  /// not actual internet access — a DNS lookup proves it for real.
  Future<bool> _hasRealInternet() async {
    try {
      final result = await InternetAddress.lookup(
        'example.com',
      ).timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on Object {
      return false;
    }
  }

  void _safeEmit(ConnectivityState state) {
    if (!isClosed) emit(state);
  }

  @override
  Future<void> close() {
    _connectivitySub?.cancel();
    return super.close();
  }
}
