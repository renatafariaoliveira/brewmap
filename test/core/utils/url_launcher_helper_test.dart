import 'package:brewmap/core/utils/url_launcher_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatPhoneUS10', () {
    test('formata número com 10 dígitos', () {
      expect(formatPhoneUS10('1234567890'), '(123) 456-7890');
      expect(formatPhoneUS10('(123) 456-7890'), '(123) 456-7890');
      // O helper só formata quando, após remover não-dígitos, o resultado tem
      // exatamente 10 dígitos (sem considerar código do país).
      expect(formatPhoneUS10('+1 (123) 456-7890'), '+1 (123) 456-7890');
    });

    test('retorna raw quando não tem 10 dígitos', () {
      expect(formatPhoneUS10('123'), '123');
      expect(formatPhoneUS10(''), '');
      expect(formatPhoneUS10('12345678901'), '12345678901');
    });
  });

  group('displayWebsiteUrl', () {
    test('remove esquema http/https e barra final', () {
      expect(displayWebsiteUrl('https://example.com/'), 'example.com');
      expect(displayWebsiteUrl('http://example.com/'), 'example.com');
      expect(displayWebsiteUrl('https://example.com/path/'), 'example.com/path');
    });

    test('mantém URL sem esquema', () {
      expect(displayWebsiteUrl('example.com'), 'example.com');
      expect(displayWebsiteUrl('example.com/'), 'example.com');
    });
  });
}

