import 'dart:math' as math;
import '../models/location_model.dart';
import '../models/response/location_list_response_model.dart';

/// Location Service
///
/// Provides location data using a static predefined list.
/// This works without a backend API and can be easily upgraded
/// to use an API service later by implementing the same interface.
///
/// To add more locations, simply add them to the _locations list below.
class LocationService {
  // Static predefined locations list
  // You can expand this list with more cities as needed
  final List<LocationModel> _locations = [
    // Major Cities - Maharashtra
    LocationModel(
      id: 'loc_1',
      name: 'Mumbai',
      city: 'Mumbai',
      state: 'Maharashtra',
      country: 'India',
      latitude: 19.0760,
      longitude: 72.8777,
    ),
    LocationModel(
      id: 'loc_7',
      name: 'Pune',
      city: 'Pune',
      state: 'Maharashtra',
      country: 'India',
      latitude: 18.5204,
      longitude: 73.8567,
    ),
    LocationModel(
      id: 'loc_11',
      name: 'Nagpur',
      city: 'Nagpur',
      state: 'Maharashtra',
      country: 'India',
      latitude: 21.1458,
      longitude: 79.0882,
    ),
    LocationModel(
      id: 'loc_12',
      name: 'Nashik',
      city: 'Nashik',
      state: 'Maharashtra',
      country: 'India',
      latitude: 19.9975,
      longitude: 73.7898,
    ),
    LocationModel(
      id: 'loc_13',
      name: 'Aurangabad',
      city: 'Aurangabad',
      state: 'Maharashtra',
      country: 'India',
      latitude: 19.8762,
      longitude: 75.3433,
    ),

    // Major Cities - Gujarat
    LocationModel(
      id: 'loc_8',
      name: 'Ahmedabad',
      city: 'Ahmedabad',
      state: 'Gujarat',
      country: 'India',
      latitude: 23.0225,
      longitude: 72.5714,
    ),
    LocationModel(
      id: 'loc_10',
      name: 'Surat',
      city: 'Surat',
      state: 'Gujarat',
      country: 'India',
      latitude: 21.1702,
      longitude: 72.8311,
    ),
    LocationModel(
      id: 'loc_14',
      name: 'Vadodara',
      city: 'Vadodara',
      state: 'Gujarat',
      country: 'India',
      latitude: 22.3072,
      longitude: 73.1812,
    ),
    LocationModel(
      id: 'loc_15',
      name: 'Rajkot',
      city: 'Rajkot',
      state: 'Gujarat',
      country: 'India',
      latitude: 22.3039,
      longitude: 70.8022,
    ),

    // Major Cities - Delhi NCR
    LocationModel(
      id: 'loc_2',
      name: 'Delhi',
      city: 'New Delhi',
      state: 'Delhi',
      country: 'India',
      latitude: 28.6139,
      longitude: 77.2090,
    ),
    LocationModel(
      id: 'loc_16',
      name: 'Gurgaon',
      city: 'Gurgaon',
      state: 'Haryana',
      country: 'India',
      latitude: 28.4089,
      longitude: 77.0378,
    ),
    LocationModel(
      id: 'loc_17',
      name: 'Noida',
      city: 'Noida',
      state: 'Uttar Pradesh',
      country: 'India',
      latitude: 28.5355,
      longitude: 77.3910,
    ),

    // Major Cities - Karnataka
    LocationModel(
      id: 'loc_3',
      name: 'Bangalore',
      city: 'Bangalore',
      state: 'Karnataka',
      country: 'India',
      latitude: 12.9716,
      longitude: 77.5946,
    ),
    LocationModel(
      id: 'loc_18',
      name: 'Mysore',
      city: 'Mysore',
      state: 'Karnataka',
      country: 'India',
      latitude: 12.2958,
      longitude: 76.6394,
    ),

    // Major Cities - Telangana
    LocationModel(
      id: 'loc_4',
      name: 'Hyderabad',
      city: 'Hyderabad',
      state: 'Telangana',
      country: 'India',
      latitude: 17.3850,
      longitude: 78.4867,
    ),

    // Major Cities - Tamil Nadu
    LocationModel(
      id: 'loc_5',
      name: 'Chennai',
      city: 'Chennai',
      state: 'Tamil Nadu',
      country: 'India',
      latitude: 13.0827,
      longitude: 80.2707,
    ),
    LocationModel(
      id: 'loc_19',
      name: 'Coimbatore',
      city: 'Coimbatore',
      state: 'Tamil Nadu',
      country: 'India',
      latitude: 11.0168,
      longitude: 76.9558,
    ),

    // Major Cities - West Bengal
    LocationModel(
      id: 'loc_6',
      name: 'Kolkata',
      city: 'Kolkata',
      state: 'West Bengal',
      country: 'India',
      latitude: 22.5726,
      longitude: 88.3639,
    ),

    // Major Cities - Rajasthan
    LocationModel(
      id: 'loc_9',
      name: 'Jaipur',
      city: 'Jaipur',
      state: 'Rajasthan',
      country: 'India',
      latitude: 26.9124,
      longitude: 75.7873,
    ),
    LocationModel(
      id: 'loc_20',
      name: 'Udaipur',
      city: 'Udaipur',
      state: 'Rajasthan',
      country: 'India',
      latitude: 24.5854,
      longitude: 73.7125,
    ),

    // Major Cities - Punjab
    LocationModel(
      id: 'loc_21',
      name: 'Chandigarh',
      city: 'Chandigarh',
      state: 'Chandigarh',
      country: 'India',
      latitude: 30.7333,
      longitude: 76.7794,
    ),
    LocationModel(
      id: 'loc_22',
      name: 'Amritsar',
      city: 'Amritsar',
      state: 'Punjab',
      country: 'India',
      latitude: 31.6340,
      longitude: 74.8723,
    ),

    // Major Cities - Uttar Pradesh
    LocationModel(
      id: 'loc_23',
      name: 'Lucknow',
      city: 'Lucknow',
      state: 'Uttar Pradesh',
      country: 'India',
      latitude: 26.8467,
      longitude: 80.9462,
    ),
    LocationModel(
      id: 'loc_24',
      name: 'Kanpur',
      city: 'Kanpur',
      state: 'Uttar Pradesh',
      country: 'India',
      latitude: 26.4499,
      longitude: 80.3319,
    ),

    // Major Cities - Madhya Pradesh
    LocationModel(
      id: 'loc_25',
      name: 'Indore',
      city: 'Indore',
      state: 'Madhya Pradesh',
      country: 'India',
      latitude: 22.7196,
      longitude: 75.8577,
    ),
    LocationModel(
      id: 'loc_26',
      name: 'Bhopal',
      city: 'Bhopal',
      state: 'Madhya Pradesh',
      country: 'India',
      latitude: 23.2599,
      longitude: 77.4126,
    ),
  ];

  /// Get Locations List
  ///
  /// Returns a list of locations, optionally filtered by search query.
  /// Search matches against name, city, or state (case-insensitive).
  ///
  /// Parameters:
  /// - searchQuery: Optional search string to filter locations
  ///
  /// Returns: LocationListResponseModel with filtered locations
  Future<LocationListResponseModel> getLocations({
    String? searchQuery,
  }) async {
    // Simulate network delay for realistic UX (optional - can be removed)
    await Future.delayed(const Duration(milliseconds: 200));

    print('LocationService: GET Locations');
    print('Search Query: $searchQuery');

    var filteredLocations = List<LocationModel>.from(_locations);

    // Apply search filter if query provided
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      filteredLocations = filteredLocations.where((location) {
        return location.name.toLowerCase().contains(query) ||
            location.city.toLowerCase().contains(query) ||
            location.state.toLowerCase().contains(query);
      }).toList();
    }

    // Sort by name for better UX
    filteredLocations.sort((a, b) => a.name.compareTo(b.name));

    final responseData = {
      'success': true,
      'statusCode': 200,
      'message': 'Locations retrieved successfully',
      'data': filteredLocations.map((l) => l.toJson()).toList(),
    };

    print('LocationService: Response - ${filteredLocations.length} locations');

    return LocationListResponseModel.fromJson(responseData);
  }

  /// Get Location by Coordinates (Reverse Geocoding)
  ///
  /// Finds the nearest location from the predefined list based on GPS coordinates.
  /// Uses Haversine formula to calculate distance.
  ///
  /// Note: This is approximate - it finds the closest predefined location,
  /// not the exact address. For accurate reverse geocoding, use a third-party API.
  ///
  /// Parameters:
  /// - latitude: GPS latitude coordinate
  /// - longitude: GPS longitude coordinate
  ///
  /// Returns: Nearest LocationModel or null if no locations available
  Future<LocationModel?> getLocationByCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    // Simulate network delay for realistic UX (optional - can be removed)
    await Future.delayed(const Duration(milliseconds: 150));

    print(
      'LocationService: Reverse geocoding for Lat: $latitude, Long: $longitude',
    );

    if (_locations.isEmpty) {
      print('LocationService: No locations available');
      return null;
    }

    // Find nearest location from predefined list
    double minDistance = double.infinity;
    LocationModel? nearestLocation;

    for (var location in _locations) {
      final distance = _calculateDistance(
        latitude,
        longitude,
        location.latitude,
        location.longitude,
      );
      if (distance < minDistance) {
        minDistance = distance;
        nearestLocation = location;
      }
    }

    if (nearestLocation != null) {
      print(
        'LocationService: Nearest location: ${nearestLocation.name} '
        '(${minDistance.toStringAsFixed(2)} km away)',
      );
    }

    return nearestLocation;
  }

  /// Calculate distance between two coordinates using Haversine formula
  ///
  /// Returns distance in kilometers
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // km

    final dLat = (lat2 - lat1) * (math.pi / 180);
    final dLon = (lon2 - lon1) * (math.pi / 180);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  /// Get all available locations (for debugging or admin purposes)
  List<LocationModel> getAllLocations() {
    return List<LocationModel>.from(_locations);
  }

  /// Get location count (for statistics)
  int getLocationCount() {
    return _locations.length;
  }
}

