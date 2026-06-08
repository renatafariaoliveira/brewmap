import 'package:brewmap/features/breweries/models/brewery_type_model.dart';
import 'package:latlong2/latlong.dart';

class Brewery {
  final String id;
  final String name;
  final BreweryType type;
  final String? city;
  final String? state;
  final String? country;
  final String? street;
  final String? phone;
  final double? latitude;
  final double? longitude;
  final String? websiteUrl;
  final double? rating;

  Brewery({
    required this.id,
    required this.name,
    this.type = BreweryType.micro,
    this.city,
    this.state,
    this.country,
    this.street,
    this.phone,
    this.latitude,
    this.longitude,
    this.websiteUrl,
    this.rating,
  });

  factory Brewery.fromJson(Map<String, dynamic> json) {
    return Brewery(
      id: _requiredString(json['id'], 'id'),
      name: _requiredString(json['name'], 'name'),
      type: _parseType(json['brewery_type']),
      city: _optionalString(json['city']),
      state: _optionalString(json['state_province'] ?? json['state']),
      country: _optionalString(json['country']),
      street: _optionalString(json['street']),
      phone: _optionalString(json['phone']),
      latitude: _optionalDouble(json['latitude']),
      longitude: _optionalDouble(json['longitude']),
      websiteUrl: _optionalString(json['website_url']),
      rating: _optionalDouble(json['rating']),
    );
  }

  static String _requiredString(dynamic value, String field) {
    final text = _optionalString(value);
    if (text == null) {
      throw FormatException('Brewery.$field is required');
    }
    return text;
  }

  static String? _optionalString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static double? _optionalDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'brewery_type': type.name,
    'city': city,
    'state': state,
    'country': country,
    'street': street,
    'phone': phone,
    'latitude': latitude,
    'longitude': longitude,
    'website_url': websiteUrl,
    'rating': rating,
  };

  static BreweryType _parseType(dynamic raw) {
    final v = (raw ?? '').toString().toLowerCase().trim();
    switch (v) {
      case 'micro':
        return BreweryType.micro;
      case 'brewpub':
        return BreweryType.brewpub;
      case 'regional':
        return BreweryType.regional;
      case 'large':
        return BreweryType.large;
      default:
        return BreweryType.micro;
    }
  }

  LatLng? get location => (latitude != null && longitude != null)
      ? LatLng(latitude!, longitude!)
      : null;

  String get fullLocation {
    final parts = _locationParts(includeCountry: true);
    return parts.isEmpty ? 'Localização indisponível' : parts.join(', ');
  }

  /// City and state for compact UI labels; `null` when both are empty.
  String? get compactLocation {
    final parts = _locationParts(includeCountry: false);
    return parts.isEmpty ? null : parts.join(', ');
  }

  List<String> _locationParts({required bool includeCountry}) {
    return <String>[
      if ((city ?? '').trim().isNotEmpty) city!.trim(),
      if ((state ?? '').trim().isNotEmpty) state!.trim(),
      if (includeCountry && (country ?? '').trim().isNotEmpty)
        country!.trim(),
    ];
  }
}
