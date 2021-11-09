import 'dart:async';

typedef EventHandler<E> = void Function(E event);
typedef HandlerCanceler = Future<void> Function();

class TypedEventEmitter<T> {
  final StreamController<T> _controller = StreamController.broadcast();
  final Set<StreamSubscription> _subscriptions = {};
  final Set<Completer> _completers = {};

  /// events stream
  Stream<T> get stream => _controller.stream;

  /// emit `event`
  void emit<E extends T>(E event) => _controller.add(event);

  /// filter events stream for specific sub event type `E`
  ///
  /// returns filtered stream of type `E` instead of `T`
  Stream<E> filteredStream<E extends T>() =>
      stream.where((event) => event is E).cast<E>();

  /// handle events of type `E` with `handler`
  ///
  /// returns a `HandlerCanceler` that can be used to cancel the handler and clear it from the memory
  /// also any handler will be canceled and cleared if the emitter is destroyed by calling `dispose`
  /// or if `clearHandlers` is called
  HandlerCanceler handle<E extends T>(EventHandler<E> handler) {
    final _sub = filteredStream<E>().listen(handler);
    _subscriptions.add(_sub);

    bool isCanceled = false;
    return () async {
      if (isCanceled) return;
      _subscriptions.remove(_sub);
      isCanceled = true;
      await _sub.cancel();
    };
  }

  /// clear all handlers of any event type and clear theme from memory
  Future<void> clearHandlers() async {
    if (_subscriptions.isEmpty) return;
    for (var sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();
  }

  /// complete all `onNextEmit` completers and clear them from memory
  void completeCompleters() {
    if (_completers.isEmpty) return;
    for (var completer in _completers) {
      completer.complete(false);
    }
    _completers.clear();
  }

  /// return `Future` that completes on the next event emitted of type `E`
  ///
  /// auto clear from memory on complete
  /// you can use `completeCompleters` to complete and clear all `onNextEmit` completers from memory
  Future<void> onNextEmit<E extends T>() {
    final completer = Completer();
    handle<E>((event) => completer.complete());
    _completers.add(completer);
    return completer.future.then((_) {
      if (_ == null) _completers.remove(completer);
    });
  }

  /// destroy the current __EventEmitter__ or the __Object__ inherits from it
  ///
  /// complete completers and clear it also clears handlers from memory
  /// closes events stream
  Future<void> destroy() async {
    await _controller.close();
    await clearHandlers();
    completeCompleters();
  }
}
