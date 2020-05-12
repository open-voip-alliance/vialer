import 'package:meta/meta.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

/// An [Observer], but more useful, you don't need to create a class
/// everytime.
///
// Could be a MR for the Clean Architecture package?
@immutable
class Watcher<T> extends Observer<T> {
  final void Function() _onComplete;

  final void Function(dynamic error) _onError;

  final void Function(T event) _onNext;

  Watcher({
    void Function() onComplete,
    void Function(dynamic error) onError,
    void Function(T event) onNext,
  })  : _onComplete = onComplete ?? (() {}),
        _onError = onError ?? ((_) {}),
        _onNext = onNext ?? ((_) {});

  @override
  void onComplete() => _onComplete();

  @override
  void onError(e) => _onError(e);

  @override
  void onNext(T e) => _onNext(e);
}
