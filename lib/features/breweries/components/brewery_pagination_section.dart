import 'package:brewmap/features/breweries/controllers/brewery_cubit.dart';
import 'package:brewmap/features/breweries/components/pagination_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BreweryPaginationSection extends StatelessWidget {
  const BreweryPaginationSection({
    super.key,
    required this.cubit,
    required this.currentPage,
    required this.totalPages,
    required this.totalResults,
    required this.showing,
    required this.onPageChanged,
  });

  final BreweryCubit cubit;
  final int currentPage;
  final int totalPages;
  final int totalResults;
  final int showing;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BreweryCubit, BreweryState>(
      bloc: cubit,
      buildWhen: didSearchPresentationChange,
      builder: (context, state) {
        final canPaginate =
            state.status == BreweryStateStatus.loaded &&
            totalPages > 0 &&
            totalResults > 0;
        if (!canPaginate) {
          return const SizedBox.shrink();
        }
        return PaginationBar(
          currentPage: currentPage,
          totalPages: totalPages,
          totalResults: totalResults,
          showing: showing,
          onPageChanged: onPageChanged,
        );
      },
    );
  }
}
