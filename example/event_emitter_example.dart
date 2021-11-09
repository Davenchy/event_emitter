import 'dart:async';
import 'dart:developer';

import 'server.dart';
import 'server_event.dart';

void main() {
  final server = Server();

  server.handle<ServerOnStartEvent>((event) {
    print('Server started');
  });

  server.handle<ServerOnStopEvent>((event) {
    print('Server stopped');
  });

  server.handle<ServerOnClientConnectedEvent>((event) {
    print('client with name "${event.clientId}" was connected');
  });

  server.handle<ServerOnClientDisconnectedEvent>((event) {
    print('client with name "${event.clientId}" was disconnected');
  });

  server.handle<ServerOnErrorEvent>((event) {
    log(event.message, error: event.error, stackTrace: event.stackTrace);
  });

  server.handle<ServerOnDataEvent>((event) {
    print('data received from client "${event.clientId}"');
    print('data: ${String.fromCharCodes(event.data)}');
  });

  server.handle<ServerOnSendDataEvent>((event) {
    print('send data: ${String.fromCharCodes(event.data)}');
  });

  server.start();

  server.addClient('My Client');

  server.send("Hello World");

  // wait to receive data from client then stop / destroy server
  Timer(const Duration(seconds: 7), () {
    server.destroy();
  });
}
