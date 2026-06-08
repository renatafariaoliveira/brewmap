const searchErrorMessage =
    'Erro ao buscar cervejarias. Tente novamente.';

const favoriteErrorMessage =
    'Não foi possível atualizar os favoritos. Tente novamente.';

/// Returns a user-facing message; technical details are not exposed.
String userFacingErrorMessage(
  Object error, {
  required String fallback,
}) {
  return fallback;
}
