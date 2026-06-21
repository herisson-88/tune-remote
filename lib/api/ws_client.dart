import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'models.dart';
import 'tune_client.dart';

typedef ZoneUpdateCallback = void Function(List<Zone> zones);

class TuneWebSocket {
  final String _host;
  final TuneClient _rest;
  final ZoneUpdateCallback _onZones;

  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  Timer? _reconnect;
  Timer? _pollFallback;
  bool _connected = false;
  bool _disposed = false;
  int _attempts = 0;

  static const _pollThreshold = 5;
  static const _pollInterval = Duration(seconds: 2);
  static const _pingInterval = Duration(seconds: 30);

  TuneWebSocket(this._host, this._rest, this._onZones);

  bool get connected => _connected;

  void connect() {
    if (_disposed || _host.isEmpty) return;
    _closeChannel();

    final wsUrl = Uri.parse('ws://$_host/ws');
    try {
      _channel = WebSocketChannel.connect(wsUrl);
      _sub = _channel!.stream.listen(
        _onMessage,
        onDone: _onDisconnect,
        onError: (_) => _onDisconnect(),
      );
      _connected = true;
      _attempts = 0;
      _stopPolling();

      final subscribe = jsonEncode({
        'action': 'subscribe',
        'patterns': ['playback.*', 'zone.*'],
      });
      _channel!.sink.add(subscribe);

      _startPing();
    } catch (_) {
      _attempts++;
      _onDisconnect();
    }
  }

  void _onMessage(dynamic raw) {
    if (raw is! String) return;
    try {
      final msg = jsonDecode(raw) as Map<String, dynamic>;
      final type = msg['type'] as String? ?? '';

      if (type == 'zone.updated') {
        final data = msg['data'] as Map<String, dynamic>?;
        final list = data?['zones'] as List?;
        if (list != null) {
          _onZones(list
              .whereType<Map<String, dynamic>>()
              .map(Zone.fromJson)
              .toList());
        }
        return;
      }

      if (type.startsWith('playback.')) {
        _refreshZones();
      }
    } catch (_) {}
  }

  Future<void> _refreshZones() async {
    try {
      final zones = await _rest.zones();
      _onZones(zones);
    } catch (_) {}
  }

  void _onDisconnect() {
    _connected = false;
    _closeChannel();

    if (_disposed) return;

    if (_attempts >= _pollThreshold && _pollFallback == null) {
      _startPolling();
      _scheduleReconnect(const Duration(seconds: 30));
    } else {
      _attempts++;
      final delay = Duration(seconds: (_attempts * 2).clamp(1, 15));
      _scheduleReconnect(delay);
    }
  }

  void _startPolling() {
    _pollFallback?.cancel();
    _pollFallback = Timer.periodic(_pollInterval, (_) => _refreshZones());
    _refreshZones();
  }

  void _stopPolling() {
    _pollFallback?.cancel();
    _pollFallback = null;
  }

  Timer? _pingTimer;
  void _startPing() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(_pingInterval, (_) {
      try {
        _channel?.sink.add('ping');
      } catch (_) {}
    });
  }

  void _scheduleReconnect(Duration delay) {
    _reconnect?.cancel();
    _reconnect = Timer(delay, () {
      if (!_disposed) connect();
    });
  }

  void _closeChannel() {
    _pingTimer?.cancel();
    _sub?.cancel();
    _sub = null;
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
  }

  void dispose() {
    _disposed = true;
    _reconnect?.cancel();
    _stopPolling();
    _closeChannel();
  }
}
