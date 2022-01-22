import 'package:common_query/src/util.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/src/singleton.dart';


void main() {
  group('use default formatter', () {
    test('should return a map contains specific key and formatted by default formatter', () {
      var map = CommonQuery.instance
          .collect()
          .where('id', isEqualTo: '12345')
          .where('create_at', isGreaterThan: 1641281281)
          .orderBy('create_at', descending: true)
          .limit(10)
          .skip(0)
          .get();
      var expectedMap = {
        "where": {
          "id": {
            "operation": [
              {
                "value_type": "string",
                "opt": "eq",
                "values": [
                  "12345"
                ]
              }
            ]
          },
          "create_at": {
            "operation": [
              {
                "value_type": "int",
                "opt": "Gt",
                "values": [
                  "1641281281"
                ]
              }
            ]
          }
        },
        "order_by": [
          {
            "field": "create_at",
            "sort": "desc"
          }
        ],
        "limit": 10,
        "skip": 0
      };
      expect(map, expectedMap);
    });

    test('should ignore null value if ignoreIfNull is true', () {
      var map = CommonQuery.instance
          .collect()
          .where('id', isEqualTo: '12345')
          .where('create_at', isEqualTo: null, ignoreIfNull: true)
          .get();
      var expectedMap = {
        "where": {
          "id": {
            "operation": [
              {
                "value_type": "string",
                "opt": "eq",
                "values": [
                  "12345"
                ]
              }
            ]
          }
        }
      };
      expect(map, expectedMap);
    });
  });

  group('custom formatter', () {
    test('formatted by custom formatter', () {
      //set custom formatter
      CommonQuery.instance.setFormatter((conditionMap) {
        return conditionMap.map((key, value) {
          MapEntry<String, dynamic>? entry;

          switch (key) {
            case 'where':
              final map = <String, dynamic>{};
              for (var element in value) {
                var condition = map[element[0]];
                var operationItem = {
                  'value_type': Util.getValueType(element[1], element[2]),
                  'opt': element[1],
                  'value': element[2] is List ? element[2] : element[2].toString()
                };
                if (condition != null && condition['operation'] != null) {
                  //该条件已存在，加入到operation列表
                  (condition['operation'] as List).add(operationItem);
                } else {
                  map[element[0]] = {
                    'operation': [operationItem]
                  };
                }
              }
              entry = MapEntry(key, map);
              break;
            case 'order_by':
              final list = <Map<String, String>>[];
              for (var element in value) {
                list.add({
                  'field': element[0],
                  'sort': element[1] == true ? 'desc' : 'asc'
                });
              }
              value = list;
              entry = MapEntry(key, list);
              break;
          }
          return entry ?? MapEntry(key, value);
        });
      });
      var map = CommonQuery.instance
          .collect()
          .where('id', isEqualTo: '12345')
          .where('create_at', isGreaterThan: 1641281281)
          .orderBy('create_at', descending: true)
          .limit(10)
          .skip(0)
          .get();
      var expectedMap = {
        "where": {
          "id": {
            "operation": [
              {
                "value_type": "string",
                "opt": "eq",
                "value": "12345"
              }
            ]
          },
          "create_at": {
            "operation": [
              {
                "value_type": "int",
                "opt": "Gt",
                "value": "1641281281"
              }
            ]
          }
        },
        "order_by": [
          {
            "field": "create_at",
            "sort": "desc"
          }
        ],
        "limit": 10,
        "skip": 0
      };
      expect(map, expectedMap);
    });
  });
}
