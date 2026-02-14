import 'action_result.dart';

class ActionResultFailure extends ActionResult {
  final String errorMessage;
  final int statusCode;

  ActionResultFailure({
    required this.errorMessage,
    required this.statusCode,
  });
}
