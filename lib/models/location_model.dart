import 'dart:convert';

LocationModel locationModelFromJson(String str) =>
    LocationModel.fromJson(json.decode(str));

String locationModelToJson(LocationModel data) => json.encode(data.toJson());

class LocationModel {
  final String id;
  final String name;
  final String city;
  final String state;
  final String country;
  final double latitude;
  final double longitude;

  LocationModel({
    required this.id,
    required this.name,
    required this.city,
    required this.state,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
    id: json["id"],
    name: json["name"],
    city: json["city"],
    state: json["state"],
    country: json["country"],
    latitude: (json["latitude"] as num).toDouble(),
    longitude: (json["longitude"] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "city": city,
    "state": state,
    "country": country,
    "latitude": latitude,
    "longitude": longitude,
  };
}
