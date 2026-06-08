import 'package:brewmap/core/utils/error_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('userFacingErrorMessage retorna fallback sem expor detalhes técnicos', () {
    expect(
      userFacingErrorMessage(
        Exception('internal boom'),
        fallback: searchErrorMessage,
      ),
      searchErrorMessage,
    );
  });
}
