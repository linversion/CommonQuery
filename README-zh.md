CommonQuery可以让你以链式调用的形式构建你的http请求体，当你的请求体有包含以下这些通用字段时:
`where`/`orderBy`/`limit`/`pageNum`

## Features

通常我们都得自己手动创建一个map，把参数放进去然后传给Dio，这样会造成很多样板代码，效率低下，使用CommonQuery的话你可以只关注于传值而不是构造这个map。

```dart
// 创建一个post请求
var response = dio.post('your path',
    data: CommonQuery.instance
    .collect()
    .where('id', isEqualTo: '12345')
    .where('create_at', isGreaterThan: 1641281281)
    .orderBy('create_at', descending: true)
    .limit(10)
    .skip(0)
    .get()
);

//下面的json就是你的data最后的样子
{
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
}
```

如果你需要的map格式不是这样的，那你可以在使用之前调用setFormatter这个方法，转换成你需要的格式。
```
CommonQuery.instance.setFormatter((conditionMap) {
    //在这里做一个映射转换
});

//conditionMap
{
    "where": [
        [
            "id",
            "eq",
            "12345"
        ],
        [
            "create_at",
            "Gt",
            1641281281
        ]
    ],
    "order_by": [
        [
            "create_at",
            true
        ]
    ],
    "limit": 10,
    "skip": 0
}
```
