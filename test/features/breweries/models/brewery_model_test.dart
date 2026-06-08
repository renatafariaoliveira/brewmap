import 'package:brewmap/features/breweries/models/brewery_model.dart';
import 'package:brewmap/features/breweries/models/brewery_type_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Brewery.fromJson', () {
    test('parseia payload completo da API', () {
      final brewery = Brewery.fromJson({
        'id': 'brew-1',
        'name': 'Porto Brew',
        'brewery_type': 'micro',
        'city': 'Porto',
        'state_province': 'Porto',
        'country': 'Portugal',
        'street': 'Rua A',
        'phone': '1234567890',
        'latitude': '41.1579',
        'longitude': -8.6291,
        'website_url': 'https://example.com',
        'rating': 4.5,
      });

      expect(brewery.id, 'brew-1');
      expect(brewery.name, 'Porto Brew');
      expect(brewery.type, BreweryType.micro);
      expect(brewery.city, 'Porto');
      expect(brewery.state, 'Porto');
      expect(brewery.latitude, closeTo(41.1579, 0.0001));
      expect(brewery.longitude, closeTo(-8.6291, 0.0001));
      expect(brewery.websiteUrl, 'https://example.com');
      expect(brewery.rating, 4.5);
    });

    test('aceita campos opcionais ausentes ou vazios', () {
      final brewery = Brewery.fromJson({
        'id': 42,
        'name': 'Minimal',
        'brewery_type': 'unknown-type',
      });

      expect(brewery.id, '42');
      expect(brewery.name, 'Minimal');
      expect(brewery.type, BreweryType.micro);
      expect(brewery.city, isNull);
      expect(brewery.latitude, isNull);
    });

    test('compactLocation omite partes vazias', () {
      expect(
        Brewery(id: '1', name: 'A', city: 'Porto').compactLocation,
        'Porto',
      );
      expect(
        Brewery(id: '1', name: 'A', state: 'CA').compactLocation,
        'CA',
      );
      expect(
        Brewery(id: '1', name: 'A', city: 'Porto', state: 'Porto').compactLocation,
        'Porto, Porto',
      );
      expect(Brewery(id: '1', name: 'A').compactLocation, isNull);
    });

    test('lança FormatException quando campo obrigatório está ausente', () {
      expect(
        () => Brewery.fromJson({'name': 'Sem id'}),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => Brewery.fromJson({'id': '1'}),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
