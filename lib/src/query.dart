const optIn = 'in';
const optEq = 'eq';
const optNe = 'ne';
const optRegex = 'regex';
const optGt = 'Gt';
const optGte = 'gte';
const optLt = 'lt';
const optLte = 'lte';
const optNin = 'nin';

abstract class Query<T> {
  Map<String, dynamic> get();

  Map<String, dynamic> get parameters;

  // 一页的数量
  Query<T> limit(int limit);

  // 跳过多少条，用于分页
  Query<T> skip(int num);

  Query<T> orderBy(String field, {bool descending = false});

  Query<T> where(
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
  });

  Query<T> params(Map<String, dynamic> params);

  Query<T> fields(List<String> fields);
}
