enum BreweryType { micro, brewpub, regional, large }

extension BreweryTypeLabel on BreweryType {
  String get label {
    switch (this) {
      case BreweryType.micro:
        return 'Micro';
      case BreweryType.brewpub:
        return 'Brewpub';
      case BreweryType.regional:
        return 'Regional';
      case BreweryType.large:
        return 'Large';
    }
  }
}
