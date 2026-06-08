import 'package:brewmap/features/breweries/models/brewery_model.dart';
import 'package:brewmap/features/breweries/models/brewery_type_model.dart';

class BreweryListFilter {
  BreweryListFilter._();

  static List<Brewery> apply(
    List<Brewery> breweries, {
    BreweryType? type,
    required String query,
  }) {
    var list = breweries;
    if (type != null) {
      list = list.where((b) => b.type == type).toList();
    }
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      list = list
          .where(
            (b) =>
                b.name.toLowerCase().contains(q) ||
                (b.city ?? '').toLowerCase().contains(q) ||
                (b.state ?? '').toLowerCase().contains(q) ||
                (b.country ?? '').toLowerCase().contains(q),
          )
          .toList();
    }
    return list;
  }

  static List<Brewery> paginate(
    List<Brewery> breweries, {
    required int page,
    required int perPage,
  }) {
    if (page < 1 || perPage < 1 || breweries.isEmpty) return [];
    final start = (page - 1) * perPage;
    final end = (start + perPage).clamp(0, breweries.length);
    if (start >= breweries.length) return [];
    return breweries.sublist(start, end);
  }

  static int totalPages(int itemCount, int perPage) {
    if (itemCount <= 0 || perPage <= 0) return 0;
    return (itemCount / perPage).ceil();
  }

  /// Page numbers to show in the pagination bar (1-based).
  /// `null` entries represent an ellipsis (…).
  static List<int?> paginationPageSlots(
    int currentPage,
    int totalPages, {
    int windowSize = 5,
  }) {
    if (totalPages <= 0) return [];
    if (totalPages <= windowSize) {
      return List.generate(totalPages, (i) => i + 1);
    }

    var start = currentPage - windowSize ~/ 2;
    var end = start + windowSize - 1;

    if (start < 1) {
      end += 1 - start;
      start = 1;
    }
    if (end > totalPages) {
      start -= end - totalPages;
      end = totalPages;
    }

    final slots = <int?>[];
    if (start > 1) {
      slots.add(1);
      if (start > 2) slots.add(null);
    }
    for (var page = start; page <= end; page++) {
      slots.add(page);
    }
    if (end < totalPages) {
      if (end < totalPages - 1) slots.add(null);
      slots.add(totalPages);
    }
    return slots;
  }

  static Brewery? findById(List<Brewery> breweries, String? id) {
    if (id == null) return null;
    for (final brewery in breweries) {
      if (brewery.id == id) return brewery;
    }
    return null;
  }
}
