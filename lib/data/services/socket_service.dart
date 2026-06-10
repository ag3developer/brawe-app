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
  // 🔁 Rooms we are currently joined to. On auto-reconnect we re-join them
  // so chat / gifts / viewer count keep flowing without the user noticing.
  final Set<String> _joinedRooms = <String>{};

  // 🔁 Callbacks executados APÓS cada (re)conexão bem sucedida — depois de
  // autenticar e re-joinar as salas. Telas usam isso para re-anexar listeners
  // de eventos (ex.: `connect:battle:started`) que foram perdidos com a
  // desconexão. SEM isso, uma queda momentânea de rede quebrava a entrega
  // de eventos críticos como início de batalha para o broadcaster.
  final Set<VoidCallback> _onReconnectCallbacks = <VoidCallback>{};

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
      // 🔁 Re-join all rooms that we believe we belong to. Required after
      // an auto-reconnect — otherwise the server stops forwarding chat,
      // gifts and viewer events for those rooms.
      for (final roomId in _joinedRooms.toList()) {
        _emitWithUserProfile(AppConstants.eventJoinRoom, {'room_id': roomId});
      }
      // 🔁 Notificar telas para re-anexarem listeners de eventos custom
      // (battle, gifts, etc). O socket interno é recriado em reconexões,
      // então qualquer `on(...)` chamado antes está apontando para um socket
      // morto. Cada callback deve re-registrar suas próprias subscriptions.
      for (final cb in _onReconnectCallbacks.toList()) {
        try {
          cb();
        } catch (e) {
          debugPrint('Socket.IO: reconnect callback failed: $e');
        }
      }
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    _socket?.onDisconnect((_) {
      debugPrint('Socket.IO: Disconnected');
      _connectFuture = null;
      // Auto-reconnect after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (!(_socket?.connected ?? false)) {
          debugPrint('Socket.IO: Attempting auto-reconnect...');
          _socket?.connect();
        }
      });
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
    _joinedRooms.clear();
    _onReconnectCallbacks.clear();
    _socket?.disconnect();
    _socket = null;
    _currentUser = null;
  }

  void joinRoom(String roomId) {
    _joinedRooms.add(roomId);
    _emitWithUserProfile(AppConstants.eventJoinRoom, {'room_id': roomId});
    debugPrint('Socket.IO: Joining room $roomId');
  }

  /// Registra um callback executado APÓS toda (re)conexão bem sucedida.
  /// Use para re-anexar listeners de eventos (`on(...)`) que são perdidos
  /// quando o socket interno é recriado em reconexões. Lembrar de chamar
  /// [removeReconnectCallback] no `dispose` da tela para evitar vazamentos.
  void addReconnectCallback(VoidCallback cb) {
    _onReconnectCallbacks.add(cb);
  }

  void removeReconnectCallback(VoidCallback cb) {
    _onReconnectCallbacks.remove(cb);
  }

  void leaveRoom(String roomId) {
    _joinedRooms.remove(roomId);
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
    final connected = _socket?.connected ?? false;
    if (!connected) {
      debugPrint(
        '⚠️ Socket.IO: sendChatMessage chamado SEM socket conectado '
        '(room=$roomId). Mensagem perdida — o caller deveria ter feito '
        'connect() antes (LiveRepository.sendComment faz isso via '
        '_ensureConnectedToRoom).',
      );
    }
    debugPrint(
      '📤 Socket.IO: emit live_chat_message room=$roomId '
      'user=${_currentUser?.name ?? "(anon)"} msg="${message.length > 40 ? "${message.substring(0, 40)}…" : message}"',
    );
    _emitWithUserProfile(AppConstants.eventSendMessage, {
      'room_id': roomId,
      'message': message,
    });
  }

  /// ❤️ Reaction batch (corações flutuantes).
  /// O caller agrega N toques em [count] (ex.: 200ms debounce) para evitar flood.
  void sendLiveReaction({required String roomId, int count = 1}) {
    _emitWithUserProfile(AppConstants.eventSendReaction, {
      'room_id': roomId,
      'count': count,
    });
  }

  // ────────────────────── Direct Messages ──────────────────────
  //
  // O envio/marcação como lida são feitos via REST (MessagesService).
  // O socket serve apenas para join/leave da sala e indicadores de digitação.

  void joinConversation(String conversationId) {
    emit(AppConstants.eventJoinConversation, {
      'conversation_id': conversationId,
    });
    debugPrint('Socket.IO: Joining conversation $conversationId');
  }

  void leaveConversation(String conversationId) {
    emit(AppConstants.eventLeaveConversation, {
      'conversation_id': conversationId,
    });
    debugPrint('Socket.IO: Leaving conversation $conversationId');
  }

  void sendTypingStart({required String conversationId}) {
    emit(AppConstants.eventTyping, {'conversation_id': conversationId});
  }

  void sendTypingStop({required String conversationId}) {
    emit(AppConstants.eventStopTyping, {'conversation_id': conversationId});
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
    // 🪪 Se `_currentUser` ainda não foi carregado (auth assíncrono pode não
    // ter completado quando o socket conectou), o servidor receberia o
    // evento sem `sender_name`/`sender_avatar` e mostraria "Anônimo" no
    // chat — mas o envio em si funciona. NÃO bloqueamos aqui: melhor enviar
    // como anônimo do que perder a mensagem do usuário.
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

  /// Atualiza o snapshot do usuário em cache, usado para enriquecer
  /// payloads de eventos (chat / gift / reaction). Deve ser chamado
  /// após login/refresh para evitar mensagens marcadas como "Anônimo".
  Future<void> refreshCurrentUser() async {
    _currentUser = await _storageService.getUser();
  }
}
