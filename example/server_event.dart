import 'dart:typed_data';

abstract class ServerEvent {
  const ServerEvent();

  const factory ServerEvent.onStart(int port) = ServerOnStartEvent;
  const factory ServerEvent.onStop() = ServerOnStopEvent;
  const factory ServerEvent.onClientConnected(String clientId) =
      ServerOnClientConnectedEvent;
  const factory ServerEvent.onClientDisconnected(String clientId) =
      ServerOnClientDisconnectedEvent;
  const factory ServerEvent.onData(Uint8List data, String clientId) =
      ServerOnDataEvent;
  const factory ServerEvent.onSendData(Uint8List data) = ServerOnSendDataEvent;
  const factory ServerEvent.onError(
    String message,
    Object error,
    StackTrace errorStack,
  ) = ServerOnErrorEvent;
}

class ServerOnStartEvent extends ServerEvent {
  const ServerOnStartEvent(this.port);
  final int port;
}

class ServerOnStopEvent extends ServerEvent {
  const ServerOnStopEvent();
}

class ServerOnClientConnectedEvent extends ServerEvent {
  const ServerOnClientConnectedEvent(this.clientId);
  final String clientId;
}

class ServerOnClientDisconnectedEvent extends ServerEvent {
  const ServerOnClientDisconnectedEvent(this.clientId);
  final String clientId;
}

class ServerOnDataEvent extends ServerEvent {
  const ServerOnDataEvent(this.data, this.clientId);
  final Uint8List data;
  final String clientId;
}

class ServerOnSendDataEvent extends ServerEvent {
  const ServerOnSendDataEvent(this.data);
  final Uint8List data;
}

class ServerOnErrorEvent extends ServerEvent {
  const ServerOnErrorEvent(this.message, this.error, this.stackTrace);
  final String message;
  final Object error;
  final StackTrace stackTrace;
}
