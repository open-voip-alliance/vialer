/// To add parameters to [call], they will have to be optional, either
/// positional or named. If you want required parameters, use
///
/// ```dart
/// void call({@required int something}) {}
/// ```
// ignore: one_member_abstracts
abstract class UseCase<T> {
  T call();
}

abstract class FutureUseCase<T> extends UseCase<Future<T>> {}
