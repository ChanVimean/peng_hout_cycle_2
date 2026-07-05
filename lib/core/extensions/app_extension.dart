import 'package:peng_houth_cycle/core/errors/app_exception.dart';

class TimeoutAppException extends AppException {
  const TimeoutAppException() : super('Server is waking up, try again', 408);
}
