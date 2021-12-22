import 'package:common_query/src/json_query.dart';
import 'package:common_query/src/query.dart';

class CommonQuery {
  static CommonQuery? _instance;

  static CommonQuery get instance => _instance ??= CommonQuery._();

  CommonQuery._();

  Formatter? _formatter;

  void setFormatter(Formatter formatter) {
    _formatter = formatter;
  }

  Query<Map<String, dynamic>> collect() {
    return JsonQuery(JsonQueryDelegate(null, formatter: _formatter));
  }
}
