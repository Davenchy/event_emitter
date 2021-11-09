import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:event_emitter/event_emitter.dart';

import 'server_event.dart';

class Server extends EventEmitter<ServerEvent> {
  final Set<String> _clients = {};
  bool _isActive = false;

  bool get isActive => _isActive;

  start() {
    if (isActive) return;
    _isActive = true;
    emit(ServerEvent.onStart(Random().nextInt(29000) + 1000));
  }

  void stop() {
    if (!isActive) return;
    _isActive = false;
    emit(ServerEvent.onStop());
  }

  bool addClient(String clientId) {
    if (_clients.contains(clientId)) return false;
    _clients.add(clientId);
    emit(ServerEvent.onClientConnected(clientId));
    return true;
  }

  bool removeClient(String clientId) {
    if (_clients.remove(clientId)) {
      emit(ServerEvent.onClientDisconnected(clientId));
      return true;
    }
    return false;
  }

  send(String message) {
    final bytes = Uint8List.fromList(message.codeUnits);
    Timer(
      Duration(seconds: Random().nextInt(5)),
      () {
        final index = Random().nextInt(_clients.length);
        emit(ServerEvent.onData(bytes, _clients.elementAt(index)));
      },
    );
    emit(ServerEvent.onSendData(bytes));
  }

  void emitError() {
    emit(
      ServerEvent.onError(
        'Something wrong happened!',
        Exception('Something wrong happened!'),
        StackTrace.current,
      ),
    );
  }

  Future<void> onDone() => onNextEmit<ServerOnStopEvent>();

  @override
  Future<void> destroy() async {
    if (isActive) stop();
    await super.destroy();
  }
}
