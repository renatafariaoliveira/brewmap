Feature: Busca de cervejarias

  Scenario: Falha na API mostra estado de erro
    Given o app está aberto
    And a API retorna erro
    When eu busco por "ipa"
    Then eu vejo uma mensagem de erro
    And nenhum resultado é exibido

