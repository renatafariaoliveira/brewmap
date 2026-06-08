import 'package:brewmap/core/config/brewmap_flags.dart';
import 'package:brewmap/core/theme/theme.dart';
import 'package:brewmap/core/utils/error_message.dart';
import 'package:brewmap/features/breweries/components/brew_query_badge.dart';
import 'package:brewmap/features/breweries/components/brewery_marker.dart';
import 'package:brewmap/features/breweries/components/brewery_results_badge.dart';
import 'package:brewmap/features/breweries/components/map_zoom_controls.dart';
import 'package:brewmap/features/breweries/controllers/brewery_cubit.dart';
import 'package:brewmap/features/breweries/models/brewery_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

class BreweryMapPanel extends StatelessWidget {
  const BreweryMapPanel({
    super.key,
    required this.mapController,
    required this.initialCenter,
    required this.initialZoom,
    required this.breweries,
    required this.selectedBreweryId,
    required this.query,
    required this.onBrewerySelect,
    required this.onMapTap,
    required this.searchStatus,
    required this.resultsCount,
    this.errorMessage,
    this.showSearchError = false,
  });

  final MapController mapController;
  final LatLng initialCenter;
  final double initialZoom;
  final List<Brewery> breweries;
  final String? selectedBreweryId;
  final String query;
  final ValueChanged<Brewery> onBrewerySelect;
  final VoidCallback onMapTap;
  final BreweryStateStatus searchStatus;
  final int resultsCount;
  final String? errorMessage;
  final bool showSearchError;

  @override
  Widget build(BuildContext context) {
    final colors = context.brewColors;
    final showError =
        showSearchError && searchStatus == BreweryStateStatus.error;

    return Stack(
      children: [
        if (kBrewmapBddTest)
          Positioned.fill(
            child: GestureDetector(
              onTap: onMapTap,
              child: ColoredBox(color: colors.mapBackground),
            ),
          )
        else
          RepaintBoundary(
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: initialCenter,
                initialZoom: initialZoom,
                backgroundColor: colors.mapBackground,
                onTap: (_, _) => onMapTap(),
              ),
              children: [
                TileLayer(
                  urlTemplate: colors.mapTileUrlTemplate,
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.brewmap.app',
                  retinaMode: true,
                  tileProvider: NetworkTileProvider(
                    cachingProvider:
                        BuiltInMapCachingProvider.getOrCreateInstance(
                      maxCacheSize: 200_000_000,
                    ),
                  ),
                ),
                MarkerLayer(
                  markers: buildMarkers(
                    breweries: breweries,
                    selectedId: selectedBreweryId,
                    onSelect: onBrewerySelect,
                  ),
                ),
              ],
            ),
          ),
        Positioned(
          bottom: 16,
          right: 16,
          child: BreweryResultsBadge(
            count: searchStatus == BreweryStateStatus.loaded ? resultsCount : 0,
          ),
        ),
        Positioned(top: 12, left: 12, child: BrewQueryBadge(query: query)),
        if (showError)
          Positioned(
            left: 12,
            right: 12,
            bottom: 56,
            child: Material(
              color: colors.surface,
              borderRadius: BorderRadius.circular(8),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Text(
                  errorMessage ?? searchErrorMessage,
                  style: GoogleFonts.dmSans(
                    color: colors.textSecondary,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        if (!kBrewmapBddTest)
          Positioned(
            top: 12,
            right: 12,
            child: MapZoomControls(
              onZoomIn: () => mapController.move(
                mapController.camera.center,
                mapController.camera.zoom + 1,
              ),
              onZoomOut: () => mapController.move(
                mapController.camera.center,
                mapController.camera.zoom - 1,
              ),
            ),
          ),
      ],
    );
  }
}
