/// Guarantees only one voice recording plays at a time across the
/// whole app — starting a new playback stops the previous one
/// (WhatsApp/Telegram behavior).
///
/// Usage: a player calls [acquire] before playing, passing a stop
/// callback. When another player acquires, the previous player's
/// callback fires so it can pause and update its UI.
class AudioPlaybackCoordinator {
  Object? _activeToken;
  void Function()? _stopActive;

  /// Makes [token] the active player, stopping the previous one.
  /// [onStopped] is invoked when another player takes over.
  void acquire(Object token, void Function() onStopped) {
    if (_activeToken == token) return;
    _stopActive?.call();
    _activeToken = token;
    _stopActive = onStopped;
  }

  /// Releases the active slot if [token] owns it.
  void release(Object token) {
    if (_activeToken == token) {
      _activeToken = null;
      _stopActive = null;
    }
  }
}
