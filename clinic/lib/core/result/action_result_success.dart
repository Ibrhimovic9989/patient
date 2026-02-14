import 'action_result.dart';

class ActionResultSuccess<T> extends ActionResult {
  final T data;
  final int statusCode;

  ActionResultSuccess({
    required this.data,
    required this.statusCode,
  });
}
