sealed class ConnectivityState {}

/// Initial state while the first check is still running.
class ConnectivityChecking extends ConnectivityState {}

class ConnectivityOnline extends ConnectivityState {}

class ConnectivityOffline extends ConnectivityState {}
