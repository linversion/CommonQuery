CommonQuery is a plugin that help you build the http request body which has these field:
`where`/`orderBy`/`limit`/`pageNum`/`skip`/`fields`/`params`

[中文](https://github.com/linversion/CommonQuery/blob/main/README-zh.md)
## Features

Usually we will build a map with these params and pass it to Dio which is boring and causing too much similar code. Use CommonQuery you only need to focus on your param's value.

```dart
// create a post request
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

//this is your data's json format
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

If you want to map the data to another stucture, just call the CommonQuery's setFormatter function once before you use CommonQuery.
```
CommonQuery.instance.setFormatter((conditionMap) {
    //just map the conditionMap to another map
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
