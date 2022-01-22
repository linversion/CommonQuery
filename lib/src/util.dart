import 'query.dart';

class Util {
  static String getValueType(String opt, dynamic values) {
    if (opt == optIn || opt == optNin) {
      var item = (values as List).first;
      return item.runtimeType.toString().toLowerCase();
    } else {
      return values.runtimeType.toString().toLowerCase();
    }
  }
}