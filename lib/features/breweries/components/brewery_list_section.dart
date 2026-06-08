import 'package:brewmap/core/theme/theme.dart';
import 'package:brewmap/core/utils/error_message.dart';
import 'package:brewmap/features/breweries/controllers/brewery_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class BreweryListSection extends StatelessWidget {
  const BreweryListSection({
    super.key,
    required this.cubit,
    required this.child,
  });

  final BreweryCubit cubit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BreweryCubit, BreweryState>(
      bloc: cubit,
      buildWhen: didSearchPresentationChange,
      builder: (context, state) {
        final colors = context.brewColors;
        if (state.status == BreweryStateStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == BreweryStateStatus.error) {
          return Center(
            child: Text(
              state.errorMessage ?? searchErrorMessage,
              style: GoogleFonts.dmSans(color: colors.textSecondary),
              textAlign: TextAlign.center,
            ),
          );
        }
        if (state.status == BreweryStateStatus.initial) {
          return Center(
            child: Text(
              'Digite uma cidade para buscar',
              style: GoogleFonts.dmSans(color: colors.textSecondary),
              textAlign: TextAlign.center,
            ),
          );
        }
        return child;
      },
    );
  }
}

