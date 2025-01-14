# API Endpoints Documentation

## 1. Weather Forecast

### URL
`GET /weather/forecast`

### Description
Fetches current weather and a daily forecast for a specific location.

### Query Parameters
| Parameter | Type  | Required | Description                      |
|-----------|-------|----------|----------------------------------|
| `lat`     | Float | Yes      | Latitude (-90 to 90).            |
| `lon`     | Float | Yes      | Longitude (-180 to 180).         |

### Example Request
`GET http://localhost:3000/weather/forecast?lat=36.7014631&lon=-118.655297`

### Success Response
```json
{
  "success": true,
  "data": {
    "current_weather": {
      "temperature": 15.2,
      "wind_speed": 5.4,
      "condition": "Partly Cloudy"
    },
    "daily_forecast": [
      {
        "date": "2025-01-13",
        "max_temperature": 20,
        "min_temperature": 10,
        "condition": "Clear"
      },
      {
        "date": "2025-01-14",
        "max_temperature": 18,
        "min_temperature": 9,
        "condition": "Rain"
      }
    ]
  },
  "message": "Weather forecast fetched successfully"
}
```
### Error Response
```json
{
  "success": false,
  "errors": ["Latitude is required", "Longitude is required"]
}
```


## 2. Address Lookup
`GET /geocoder/address_lookup`

### Description
Provides address suggestions based on a partial address query.

### Query Parameters
| Parameter | Type   | Required | Description                      |
|-----------|--------|----------|----------------------------------|
| `query`   | String | Yes      | Partial or full address input.   |

### Example Request
`GET http://localhost:3000/geocoder/address_lookup?query=mon`

### Success Response
```json
{
  "success": true,
  "data": [
    {
      "full_address": "California, USA",
      "lat": 36.7783,
      "lon": -119.4179
    },
    {
      "full_address": "Calabasas, California, USA",
      "lat": 34.1578,
      "lon": -118.6384
    }
  ],
  "message": "Autocomplete results fetched successfully"
}
```

### Error Response
```json
{
  "success": false,
  "errors": ["Query cannot be blank"]
}
```