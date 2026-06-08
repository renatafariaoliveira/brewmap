import 'package:brewmap/core/config/locator.dart';
import 'package:brewmap/features/breweries/controllers/brewery_cubit.dart';
import 'package:brewmap/features/breweries/components/brewery_favorite_card.dart';
import 'package:brewmap/features/breweries/components/favorites_empty_state.dart';
import 'package:brewmap/features/breweries/components/favorites_header.dart';
import 'package:brewmap/features/breweries/models/brewery_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = getIt<BreweryCubit>();

    return BlocBuilder<BreweryCubit, BreweryState>(
      bloc: cubit,
      buildWhen: (previous, current) =>
          previous.favoriteBreweries != current.favoriteBreweries,
      builder: (context, state) {
        final favorites = state.favoriteBreweries;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FavoritesHeader(count: favorites.length),
            Expanded(
              child: favorites.isEmpty
                  ? const FavoritesEmptyState()
                  : SingleChildScrollView(
                      child: _buildGrid(
                        favorites: favorites,
                        toggleFavorite: cubit.toggleFavorite,
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGrid({
    required List<Brewery> favorites,
    required Function(Brewery) toggleFavorite,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const minCardWidth = 210.0;
          const gap = 14.0;
          final cols = (constraints.maxWidth / (minCardWidth + gap))
              .floor()
              .clamp(1, 4);

          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: favorites.map((brewery) {
              final cardWidth =
                  (constraints.maxWidth - gap * (cols - 1)) / cols;
              return SizedBox(
                width: cardWidth,
                child: BreweryFavoriteCard(
                  brewery: brewery,
                  onRemove: () => toggleFavorite(brewery),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
