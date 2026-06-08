Feature: Favoritar cervejarias

  Scenario: Usuário favorita um resultado de busca
    Given o app está aberto
    When eu busco por "porto"
    And eu seleciono a primeira cervejaria da lista
    And eu marco como favorito
    Then a cervejaria aparece na lista de favoritos

  Scenario: Favorito persiste após reiniciar o app
    Given existe uma cervejaria favoritada
    When eu reinicio o app
    Then a cervejaria continua na lista de favoritos

