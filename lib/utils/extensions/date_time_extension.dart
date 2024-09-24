import 'package:timeago/timeago.dart' as timeago;

extension DateTimeExtensions on DateTime {
  String timeAgo({bool allowFromNow = false}) {
    return timeago.format(this, allowFromNow: allowFromNow);
  }
}
