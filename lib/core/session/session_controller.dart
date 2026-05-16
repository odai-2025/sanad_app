import 'dart:async';
import 'package:flutter/widgets.dart';

class SessionController extends ChangeNotifier with WidgetsBindingObserver {
  final Duration timeout;
  final Future<void> Function() onTimeout;

  Timer? _idleTimer;
  DateTime? _pausedAt;
  bool _isExpired = false;

  SessionController({
    required this.timeout,
    required this.onTimeout,
  });

  bool get isExpired => _isExpired;

  void start() {
    WidgetsBinding.instance.addObserver(this);
    _resetTimer();
  }

  void stop() {
    _idleTimer?.cancel();
    _idleTimer = null;
    _pausedAt = null;
    WidgetsBinding.instance.removeObserver(this);
  }

  void registerInteraction() {
    if (_isExpired) return;
    _resetTimer();
  }

  void _resetTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(timeout, _handleTimeout);
  }

  Future<void> _handleTimeout() async {
    if (_isExpired) return;
    _isExpired = true;
    notifyListeners();
    await onTimeout();
  }

  void clearExpiration() {
    _isExpired = false;
    _pausedAt = null;
    _resetTimer();
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isExpired) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _pausedAt = DateTime.now();
      _idleTimer?.cancel();
    }

    if (state == AppLifecycleState.resumed) {
      if (_pausedAt != null) {
        final diff = DateTime.now().difference(_pausedAt!);
        _pausedAt = null;

        if (diff >= timeout) {
          _handleTimeout();
          return;
        }
      }

      _resetTimer();
    }
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}