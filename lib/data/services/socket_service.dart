import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../core/constants/app_constants.dart';
import 'storage_service.dart';

part 'socket_service.g.dart';

@Riverpod(keepAlive: true)
SocketService socketService(Ref ref) {
  final storageService = ref.watch(storageServiceProvider);
  return SocketService(storageService);
}

class SocketService {
  final StorageService _storageService;
  io.Socket? _socket;

  SocketService(this._storageService);

  Future<void> connect() async {
    if (_socket?.connected ?? false) return;

    final token = await _storageService.getToken();
    if (token == null) {
      debugPrint('Socket.IO: No token found, cannot connect');
      return;
    }

    _socket = io.io(
      AppConstants.connectApiBaseUrl,
      io.OptionBuilder()
          .setTransports(AppConstants.socketTransports)
          .setPath(AppConstants.socketPath)
          .setAuth({'token': token})
          .enableForceNew()
          .build(),
    );

    _socket?.onConnect((_) {
      debugPrint('Socket.IO: Connected');
    });

    _socket?.onDisconnect((_) {
      debugPrint('Socket.IO: Disconnected');
    });

    _socket?.onConnectError((err) {
      debugPrint('Socket.IO: Connect Error: $err');
    });

    _socket?.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  void joinRoom(String roomId) {
    _socket?.emit(AppConstants.eventJoinRoom, {'room_id': roomId});
    debugPrint('Socket.IO: Joining room $roomId');
  }

  void leaveRoom(String roomId) {
    _socket?.emit(AppConstants.eventLeaveRoom, {'room_id': roomId});
    debugPrint('Socket.IO: Leaving room $roomId');
  }

  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  void off(String event) {
    _socket?.off(event);
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  bool get isConnected => _socket?.connected ?? false;
}
