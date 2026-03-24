import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../core/constants/app_constants.dart';
import '../../domain/models/user.dart';
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
  User? _currentUser;
  Future<void>? _connectFuture;

  SocketService(this._storageService);

  Future<void> connect() async {
    if (_socket?.connected ?? false) {
      return;
    }
    if (_connectFuture != null) {
      return _connectFuture!;
    }

    final token = await _storageService.getToken();
    if (token == null) {
      debugPrint('Socket.IO: No token found, cannot connect');
      return;
    }
    _currentUser = await _storageService.getUser();

    final completer = Completer<void>();
    _connectFuture = completer.future;

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
      _authenticate(token);
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    _socket?.onDisconnect((_) {
      debugPrint('Socket.IO: Disconnected');
      _connectFuture = null;
    });

    _socket?.onConnectError((err) {
      debugPrint('Socket.IO: Connect Error: $err');
      if (!completer.isCompleted) {
        completer.completeError(Exception('Socket.IO connect error: $err'));
      }
      _connectFuture = null;
    });

    _socket?.connect();
    try {
      await completer.future.timeout(AppConstants.defaultTimeout);
    } finally {
      if (_socket?.connected ?? false) {
        _connectFuture = null;
      }
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _currentUser = null;
  }

  void joinRoom(String roomId) {
    _emitWithUserProfile(AppConstants.eventJoinRoom, {'room_id': roomId});
    debugPrint('Socket.IO: Joining room $roomId');
  }

  void leaveRoom(String roomId) {
    emit(AppConstants.eventLeaveRoom, {'room_id': roomId});
    debugPrint('Socket.IO: Leaving room $roomId');
  }

  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  void off(String event, [Function(dynamic)? handler]) {
    _socket?.off(event, handler);
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  void sendChatMessage({required String roomId, required String message}) {
    _emitWithUserProfile(AppConstants.eventSendMessage, {
      'room_id': roomId,
      'message': message,
    });
  }

  bool get isConnected => _socket?.connected ?? false;

  void _authenticate(String token) {
    final user = _currentUser;
    emit(
      AppConstants.eventAuthenticate,
      {'user_id': user?.id, 'token': token}
        ..removeWhere((key, value) => value == null),
    );
  }

  void _emitWithUserProfile(String event, Map<String, dynamic> payload) {
    final user = _currentUser;
    final enrichedPayload = Map<String, dynamic>.from(payload)
      ..addAll(
        {
          'viewer_name': user?.name,
          'viewer_avatar': user?.avatarUrl,
          'sender_name': user?.name,
          'sender_avatar': user?.avatarUrl,
        }..removeWhere((key, value) => value == null),
      );
    emit(event, enrichedPayload);
  }
}
