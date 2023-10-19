import 'package:timeago/timeago.dart';

class zhTimeago implements LookupMessages {
  @override String prefixAgo() => '';
  @override String prefixFromNow() => '';
  @override String suffixAgo() => '';
  @override String suffixFromNow() => '';
  @override String lessThanOneMinute(int seconds) => '刚才';
  @override String aboutAMinute(int minutes) => '${minutes}分钟前';
  @override String minutes(int minutes) => '${minutes}分钟前';
  @override String aboutAnHour(int minutes) => '${minutes}分钟前';
  @override String hours(int hours) => '${hours}小时前';
  @override String aDay(int hours) => '${hours}小时前';
  @override String days(int days) => '${days}天前';
  @override String aboutAMonth(int days) => '${days}天前';
  @override String months(int months) => '${months}月前';
  @override String aboutAYear(int year) => '${year}年前';
  @override String years(int years) => '${years}年前';
  @override String wordSeparator() => ' ';
}