import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  return DateFormat('MMM dd, yyyy').format(date);
}

String formatTime(DateTime time) {
  return DateFormat('hh:mm a').format(time);
}