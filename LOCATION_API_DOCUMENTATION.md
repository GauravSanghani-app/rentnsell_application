# Location API Documentation

## 1. GET Locations List API

### Endpoint
```
GET /api/locations
```

### Query Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| q | string | No | Search query to filter locations by name, city, or state |

### Headers
```
None (Public API)
```

### Request Example
```
GET /api/locations?q=mumbai
```

### Response Format
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Locations retrieved successfully",
  "data": [
    {
      "id": "loc_1",
      "name": "Mumbai",
      "city": "Mumbai",
      "state": "Maharashtra",
      "country": "India",
      "latitude": 19.0760,
      "longitude": 72.8777
    },
    {
      "id": "loc_2",
      "name": "Delhi",
      "city": "New Delhi",
      "state": "Delhi",
      "country": "India",
      "latitude": 28.6139,
      "longitude": 77.2090
    }
  ]
}
```

### Mock Response (All Locations)
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Locations retrieved successfully",
  "data": [
    {
      "id": "loc_1",
      "name": "Mumbai",
      "city": "Mumbai",
      "state": "Maharashtra",
      "country": "India",
      "latitude": 19.0760,
      "longitude": 72.8777
    },
    {
      "id": "loc_2",
      "name": "Delhi",
      "city": "New Delhi",
      "state": "Delhi",
      "country": "India",
      "latitude": 28.6139,
      "longitude": 77.2090
    },
    {
      "id": "loc_3",
      "name": "Bangalore",
      "city": "Bangalore",
      "state": "Karnataka",
      "country": "India",
      "latitude": 12.9716,
      "longitude": 77.5946
    },
    {
      "id": "loc_4",
      "name": "Hyderabad",
      "city": "Hyderabad",
      "state": "Telangana",
      "country": "India",
      "latitude": 17.3850,
      "longitude": 78.4867
    },
    {
      "id": "loc_5",
      "name": "Chennai",
      "city": "Chennai",
      "state": "Tamil Nadu",
      "country": "India",
      "latitude": 13.0827,
      "longitude": 80.2707
    },
    {
      "id": "loc_6",
      "name": "Kolkata",
      "city": "Kolkata",
      "state": "West Bengal",
      "country": "India",
      "latitude": 22.5726,
      "longitude": 88.3639
    },
    {
      "id": "loc_7",
      "name": "Pune",
      "city": "Pune",
      "state": "Maharashtra",
      "country": "India",
      "latitude": 18.5204,
      "longitude": 73.8567
    },
    {
      "id": "loc_8",
      "name": "Ahmedabad",
      "city": "Ahmedabad",
      "state": "Gujarat",
      "country": "India",
      "latitude": 23.0225,
      "longitude": 72.5714
    },
    {
      "id": "loc_9",
      "name": "Jaipur",
      "city": "Jaipur",
      "state": "Rajasthan",
      "country": "India",
      "latitude": 26.9124,
      "longitude": 75.7873
    },
    {
      "id": "loc_10",
      "name": "Surat",
      "city": "Surat",
      "state": "Gujarat",
      "country": "India",
      "latitude": 21.1702,
      "longitude": 72.8311
    }
  ]
}
```

### Mock Response (Search: "mumbai")
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Locations retrieved successfully",
  "data": [
    {
      "id": "loc_1",
      "name": "Mumbai",
      "city": "Mumbai",
      "state": "Maharashtra",
      "country": "India",
      "latitude": 19.0760,
      "longitude": 72.8777
    }
  ]
}
```

### Mock Response (Search: "maharashtra")
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Locations retrieved successfully",
  "data": [
    {
      "id": "loc_1",
      "name": "Mumbai",
      "city": "Mumbai",
      "state": "Maharashtra",
      "country": "India",
      "latitude": 19.0760,
      "longitude": 72.8777
    },
    {
      "id": "loc_7",
      "name": "Pune",
      "city": "Pune",
      "state": "Maharashtra",
      "country": "India",
      "latitude": 18.5204,
      "longitude": 73.8567
    }
  ]
}
```

---

## 2. GET Location by Coordinates (Reverse Geocoding) API

### Endpoint
```
GET /api/locations/reverse-geocode
```

### Query Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| latitude | number | Yes | Latitude coordinate |
| longitude | number | Yes | Longitude coordinate |

### Headers
```
None (Public API)
```

### Request Example
```
GET /api/locations/reverse-geocode?latitude=19.0760&longitude=72.8777
```

### Response Format
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Location retrieved successfully",
  "data": {
    "id": "loc_1",
    "name": "Mumbai",
    "city": "Mumbai",
    "state": "Maharashtra",
    "country": "India",
    "latitude": 19.0760,
    "longitude": 72.8777,
    "distance": 0.0
  }
}
```

### Mock Response Examples

#### Example 1: Mumbai Coordinates
**Request:**
```
GET /api/locations/reverse-geocode?latitude=19.0760&longitude=72.8777
```

**Response:**
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Location retrieved successfully",
  "data": {
    "id": "loc_1",
    "name": "Mumbai",
    "city": "Mumbai",
    "state": "Maharashtra",
    "country": "India",
    "latitude": 19.0760,
    "longitude": 72.8777,
    "distance": 0.0
  }
}
```

#### Example 2: Delhi Coordinates
**Request:**
```
GET /api/locations/reverse-geocode?latitude=28.6139&longitude=77.2090
```

**Response:**
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Location retrieved successfully",
  "data": {
    "id": "loc_2",
    "name": "Delhi",
    "city": "New Delhi",
    "state": "Delhi",
    "country": "India",
    "latitude": 28.6139,
    "longitude": 77.2090,
    "distance": 0.0
  }
}
```

#### Example 3: Coordinates Near Bangalore
**Request:**
```
GET /api/locations/reverse-geocode?latitude=12.9716&longitude=77.5946
```

**Response:**
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Location retrieved successfully",
  "data": {
    "id": "loc_3",
    "name": "Bangalore",
    "city": "Bangalore",
    "state": "Karnataka",
    "country": "India",
    "latitude": 12.9716,
    "longitude": 77.5946,
    "distance": 0.0
  }
}
```

---

## Response Model Structure

### LocationModel
```json
{
  "id": "string",           // Unique location identifier
  "name": "string",         // Location name (e.g., "Mumbai")
  "city": "string",         // City name (e.g., "Mumbai")
  "state": "string",        // State name (e.g., "Maharashtra")
  "country": "string",      // Country name (e.g., "India")
  "latitude": 19.0760,      // Latitude coordinate (decimal)
  "longitude": 72.8777      // Longitude coordinate (decimal)
}
```

### Error Response Format
```json
{
  "success": false,
  "statusCode": 400,
  "message": "Invalid coordinates provided",
  "data": null
}
```

---

## Available Mock Locations

| ID | Name | City | State | Latitude | Longitude |
|----|------|------|-------|----------|-----------|
| loc_1 | Mumbai | Mumbai | Maharashtra | 19.0760 | 72.8777 |
| loc_2 | Delhi | New Delhi | Delhi | 28.6139 | 77.2090 |
| loc_3 | Bangalore | Bangalore | Karnataka | 12.9716 | 77.5946 |
| loc_4 | Hyderabad | Hyderabad | Telangana | 17.3850 | 78.4867 |
| loc_5 | Chennai | Chennai | Tamil Nadu | 13.0827 | 80.2707 |
| loc_6 | Kolkata | Kolkata | West Bengal | 22.5726 | 88.3639 |
| loc_7 | Pune | Pune | Maharashtra | 18.5204 | 73.8567 |
| loc_8 | Ahmedabad | Ahmedabad | Gujarat | 23.0225 | 72.5714 |
| loc_9 | Jaipur | Jaipur | Rajasthan | 26.9124 | 75.7873 |
| loc_10 | Surat | Surat | Gujarat | 21.1702 | 72.8311 |

---

## Implementation Notes

1. **Search Functionality**: The search parameter `q` filters locations by matching against `name`, `city`, or `state` fields (case-insensitive).

2. **Reverse Geocoding**: The API finds the nearest location from the mock data based on the provided coordinates using the Haversine formula to calculate distance.

3. **Default Location**: If no location is found or coordinates are invalid, the API returns Mumbai (loc_1) as the default location.

4. **Response Time**: Mock API simulates network delay with 300-500ms delay.


