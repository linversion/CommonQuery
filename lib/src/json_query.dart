import 'package:common_query/src/equality.dart';
import 'package:common_query/src/query.dart';

class JsonQuery implements Query<Map<String, dynamic>> {
  final JsonQueryDelegate _delegate;

  JsonQuery(
    this._delegate,
  );

  @override
  Query<Map<String, dynamic>> fields(List<String> fields) {
    assert(parameters['fields'] == null, 'fields can only set one time');
    return JsonQuery(_delegate.fields(fields));
  }

  @override
  Query<Map<String, dynamic>> params(Map<String, dynamic> params) {
    assert(parameters['params'] == null, 'params can only set one time');
    return JsonQuery(_delegate.params(params));
  }

  @override
  Query<Map<String, dynamic>> where(
    Object field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    List<Object?>? whereIn,
    List<Object?>? whereNotIn,
    bool? isNull,
    bool ignoreIfNull = false,
  }) {
    _assertValidFieldType(field);
    const ListEquality<dynamic> equality = ListEquality<dynamic>();

    final List<List<dynamic>> conditions = List<List<dynamic>>.from(parameters['where']);

    // Conditions can be chained from other [Query] instances
    void addCondition(dynamic field, String operator, dynamic value) {
      List<dynamic> condition;
      if (ignoreIfNull && value == null) {
        return;
      }
      condition = <dynamic>[field, operator, value];
      assert(
        conditions.where((List<dynamic> item) => equality.equals(condition, item)).isEmpty,
        'Condition $condition already exists in this query.',
      );

      conditions.add(condition);
    }

    if (isEqualTo != null) addCondition(field, optEq, isEqualTo);
    if (isNotEqualTo != null) addCondition(field, optNe, isNotEqualTo);
    if (isLessThan != null) addCondition(field, optLt, isLessThan);
    if (isLessThanOrEqualTo != null) {
      addCondition(field, optLte, isLessThanOrEqualTo);
    }
    if (isGreaterThan != null) addCondition(field, optGt, isGreaterThan);
    if (isGreaterThanOrEqualTo != null) {
      addCondition(field, optGte, isGreaterThanOrEqualTo);
    }

    if (whereIn != null) addCondition(field, optIn, whereIn);
    if (whereNotIn != null) addCondition(field, optNin, whereNotIn);

    if (isNull != null) {
      if (isNull == true) {
        addCondition(field, optEq, null);
      } else {
        addCondition(field, optNe, null);
      }
    }

    dynamic hasInequality;
    bool hasIn = false;
    bool hasNotIn = false;
    bool hasNotEqualTo = false;

    // Once all conditions have been set, we must now check them to ensure the
    // query is valid.
    for (final dynamic condition in conditions) {
      dynamic field = condition[0]; // FieldPath or FieldPathType
      String operator = condition[1];
      dynamic value = condition[2];

      if (operator == optIn || isNotIn(operator)) {
        assert(
          value is List,
          "A non-empty [List] is required for '$operator' filters.",
        );
        assert(
          (value as List).length <= 10,
          "'$operator' filters support a maximum of 10 elements in the value [List].",
        );
        assert(
          (value as List).isNotEmpty,
          "'$operator' filters require a non-empty [List].",
        );
        assert(
          (value as List).where((value) => value == null).isEmpty,
          "'$operator' filters cannot contain 'null' in the [List].",
        );
      }

      if (operator == optNin) {
        assert(!hasNotEqualTo, "You cannot use '!=' filters more than once.");
        assert(!hasNotIn, "You cannot use '!=' filters with 'not-in' filters.");

        hasNotEqualTo = true;
      }

      if (_isInequality(operator)) {
        if (hasInequality == null) {
          hasInequality = field;
        } else {
          assert(
            hasInequality == field,
            'All where filters with an inequality (<, <=, >, or >=) must be '
            "on the same field. But you have inequality filters on '$hasInequality' and '$field'.",
          );
        }
      }
    }

    return JsonQuery(_delegate.where(conditions));
  }

  @override
  Query<Map<String, dynamic>> limit(int limit) {
    assert(limit > 0, 'limit must be a positive number greater than 0');
    return JsonQuery(_delegate.limit(limit));
  }

  @override
  Query<Map<String, dynamic>> skip(int num) {
    assert(num >= 0, 'pageNum must be a positive number');

    return JsonQuery(_delegate.skip(num));
  }

  @override
  Query<Map<String, dynamic>> orderBy(String field, {bool descending = false}) {
    _assertValidFieldType(field);
    final List<List<dynamic>> orders = List<List<dynamic>>.from(parameters['order_by']);
    assert(
      orders.where((List<dynamic> item) => field == item[0]).isEmpty,
      'OrderBy field "$field" already exists in this query',
    );

    orders.add([field, descending]);
    return JsonQuery(_delegate.orderBy(orders));
  }

  @override
  Map<String, dynamic> get parameters {
    return _delegate.parameters;
  }

  bool isNotIn(String operator) {
    return operator == optNin;
  }

  /// Returns whether the current operator is an inequality operator.
  bool _isInequality(String operator) {
    return operator == '<' ||
        operator == '<=' ||
        operator == '>' ||
        operator == '>=' ||
        operator == '!=';
  }

  void _assertValidFieldType(Object field) {
    assert(
      field is String,
      'Supported [field] types are [String]',
    );
  }

  @override
  Map<String, dynamic> get() => _delegate.get();
}

Map<String, dynamic> _initialParameters = Map<String, dynamic>.unmodifiable({
  'where': List<List<dynamic>>.unmodifiable([]),
  'order_by': List<List<dynamic>>.unmodifiable([])
});

typedef Formatter = Map<String, dynamic> Function(Map<String, dynamic>);

class JsonQueryDelegate {
  /// Stores the instances query modifier filters.
  final Map<String, dynamic> parameters;
  Formatter? formatter;

  JsonQueryDelegate _copyWithParameters(Map<String, dynamic> parameters) {
    return JsonQueryDelegate(Map<String, dynamic>.unmodifiable(
        Map<String, dynamic>.from(this.parameters)..addAll(parameters)));
  }

  JsonQueryDelegate(Map<String, dynamic>? params, {this.formatter})
      : parameters = params ?? _initialParameters;

  JsonQueryDelegate limit(int limit) {
    return _copyWithParameters(<String, dynamic>{'limit': limit});
  }

  JsonQueryDelegate skip(int num) {
    return _copyWithParameters(<String, dynamic>{'skip': num});
  }

  JsonQueryDelegate orderBy(List<List<dynamic>> orders) {
    return _copyWithParameters(<String, dynamic>{'order_by': orders});
  }

  JsonQueryDelegate where(List<List<dynamic>> conditions) {
    return _copyWithParameters(<String, dynamic>{'where': conditions});
  }

  JsonQueryDelegate fields(List<String> fields) {
    return _copyWithParameters(<String, dynamic>{'fields': fields});
  }

  JsonQueryDelegate params(Map<String, dynamic> params) {
    return _copyWithParameters(<String, dynamic>{'params': params});
  }

  Map<String, dynamic> get() {
    if (formatter != null) {
      return formatter!(parameters);
    }

    return parameters.map((key, value) {
      MapEntry<String, dynamic>? entry;

      switch (key) {
        case 'where':
          final map = <String, dynamic>{};
          for (var element in value) {
            map[element[0]] = {
              'operation': [
                {
                  'value_type': getValueType(element[1], element[2]),
                  'opt': element[1],
                  'values': element[2] is List ? element[2] : [element[2].toString()]
                }
              ]
            };
          }
          entry = MapEntry(key, map);
          break;
        case 'order_by':
          final list = <Map<String, String>>[];
          for (var element in value) {
            list.add({'field': element[0], 'sort': element[1] == true ? 'desc' : 'asc'});
          }
          value = list;
          entry = MapEntry(key, list);
          break;
      }
      return entry ?? MapEntry(key, value);
    });
  }

  String getValueType(String opt, dynamic values) {
    if (opt == optIn || opt == optNin) {
      var item = (values as List).first;
      return item.runtimeType.toString().toLowerCase();
    } else {
      return values.runtimeType.toString().toLowerCase();
    }
  }
}
