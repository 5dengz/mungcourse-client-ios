# Routine API

## GET /v1/routines
날짜를 기준으로 루틴들 검색, YYYY-MM-DD 형식의 date 파라미터로 특정 날짜의 루틴들을 검색합니다.

### Parameters: 
date(*required, string($date, (query))

### Response:
200 OK
```json
{
  "timestamp": "2024-01-00 13:00:00",
  "statusCode": 200,
  "message": "요청에 성공했습니다.",
  "data": [
    {
      "name": "string",
      "alarmTime": "string",
      "isCompleted": true,
      "isAlarmActive": true,
      "date": "2025-05-27",
      "routineCheckId": 0,
      "routineId": 0
    }
  ],
  "success": true
}
```

## POST /v1/routines
특정 루틴 등록, 사용자가 루틴을 등록합니다.

### Parameters: 
No parameters

### Request body (*required):
```json
{
  "name": "string",
  "alarmTime": "06:00",
  "repeatDays": [
    "MON"
  ],
  "isAlarmActive": true
}
``` 

### Response:
200 OK
```json
{
  "timestamp": "2024-01-00 13:00:00",
  "statusCode": 200,
  "message": "요청에 성공했습니다.",
  "data": {
    "id": 0,
    "name": "string",
    "alarmTime": "string",
    "isAlarmActive": true,
    "repeatDays": [
      "MON"
    ]
  },
  "success": true
}
```

## GET /v1/routines/{routineId}
루틴의 등록된 정보 검색, 등록된 루틴의 정보를 검색합니다. 루틴 변경 페이지에 사용됩니다.

### Parameters: 
routineId(*required, integer($int64, (path))

### Response:
200 OK
```json
{
  "timestamp": "2024-01-00 13:00:00",
  "statusCode": 200,
  "message": "요청에 성공했습니다.",
  "data": {
    "id": 0,
    "name": "string",
    "alarmTime": "string",
    "isAlarmActive": true,
    "repeatDays": [
      "MON"
    ]
  },
  "success": true
}
```

## DELETE /v1/routines/{routineId}
등록된 루틴을 삭제, 해당되는 모든 루틴 기록을 삭제합니다.

### Parameters: 
routineId(*required, integer($int64, (path))

### Response:
200 OK
```json
{
  "timestamp": "2024-01-00 13:00:00",
  "statusCode": 200,
  "message": "요청에 성공했습니다.",
  "success": true
}
```

## PATCH /v1/routines/{routineId}
등록된 루틴의 정보를 변경합니다, 해당 루틴의 날짜 기준으로 이후 날짜만 변경합니다.

### Parameters: 
routineId(*required, integer($int64, (path))

### Request body (*required):
```json
{
  "name": "string",
  "alarmTime": "21:23",
  "repeatDays": [
    "MON"
  ],
  "isAlarmActive": true,
  "applyFromDate": "2024-01-01"
}
```

### Response:
200 OK
```json
{
  "timestamp": "2024-01-00 13:00:00",
  "statusCode": 200,
  "message": "요청에 성공했습니다.",
  "data": {
    "id": 0,
    "name": "string",
    "alarmTime": "string",
    "isAlarmActive": true,
    "repeatDays": [
      "MON"
    ]
  },
  "success": true
}
```

## PATCH /v1/routines/{routineCheckId}/toggle
루틴 체크 OR 체크 해제, 사용자가 완료한 루틴을 체크하거나 체크 해제합니다.

### Parameters: 
routineCheckId(*required, integer($int64, (path))

### Response:
200 OK
```json
{
  "timestamp": "2024-01-00 13:00:00",
  "statusCode": 200,
  "message": "요청에 성공했습니다.",
  "data": {
    "isCompleted": true,
    "routineCheckId": 0
  },
  "success": true
}
```