import 'package:brewmap/core/config/locator.dart';
import 'package:brewmap/core/theme/theme.dart';
import 'package:brewmap/core/utils/url_launcher_helper.dart';
import 'package:brewmap/features/breweries/controllers/brewery_cubit.dart';
import 'package:brewmap/features/breweries/components/type_badge_widget.dart';
import 'package:brewmap/features/breweries/models/brewery_model.dart';
import 'package:brewmap/features/breweries/models/brewery_type_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

class BreweryDetailPanel extends StatefulWidget {
  final Brewery brewery;
  final VoidCallback onBack;

  const BreweryDetailPanel({
    super.key,
    required this.brewery,
    required this.onBack,
  });

  @override
  State<BreweryDetailPanel> createState() => _BreweryDetailPanelState();
}

class _BreweryDetailPanelState extends State<BreweryDetailPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(-0.04, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void didUpdateWidget(BreweryDetailPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.brewery.id != widget.brewery.id) {
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _formattedPhone => formatPhoneUS10(widget.brewery.phone ?? '');

  String get _displayWebsite =>
      displayWebsiteUrl(widget.brewery.websiteUrl ?? '');

  @override
  Widget build(BuildContext context) {
    final colors = context.brewColors;
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: SafeArea(
          top: false,
          left: false,
          right: false,
          bottom: true,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ColoredBox(
                color: colors.surface,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _BackLink(onTap: widget.onBack),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.brewery.name,
                                style: kHeadingTextStyle.copyWith(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: colors.textPrimary,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  TypeBadge(
                                    type: widget.brewery.type,
                                    variant: TypeBadgeVariant.accent,
                                  ),
                                  if ((widget.brewery.city ?? '').isNotEmpty)
                                    ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        '${widget.brewery.city}'
                                        '${(widget.brewery.state ?? '').isNotEmpty ? ', ${widget.brewery.state}' : ''}',
                                        style: kBodyTextStyle.copyWith(
                                          fontSize: 13,
                                          color: colors.textSecondary,
                                        ),
                                      ),
                                    ],
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                        Divider(color: colors.border, height: 1),
                        const SizedBox(height: 16),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_hasAddress)
                                _InfoRow(
                                  icon: Icons.location_on_outlined,
                                  child: Text(
                                    _addressLines,
                                    style: kBodyTextStyle.copyWith(
                                      fontSize: 13,
                                      color: colors.textPrimary,
                                      height: 1.5,
                                    ),
                                  ),
                                ),

                              if ((widget.brewery.websiteUrl ?? '').isNotEmpty)
                                ...[
                                  _InfoRow(
                                    icon: Icons.language_outlined,
                                    child: GestureDetector(
                                      onTap: () => launchExternalUrl(
                                        context,
                                        widget.brewery.websiteUrl!,
                                      ),
                                      child: Text(
                                        _displayWebsite,
                                        style: kBodyTextStyle.copyWith(
                                          fontSize: 13,
                                          color: kAccent,
                                          decoration: TextDecoration.underline,
                                          decorationColor:
                                              kAccent.withValues(alpha: 0.4),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],

                              if (_formattedPhone.isNotEmpty)
                                _InfoRow(
                                  icon: Icons.phone_outlined,
                                  child: Text(
                                    _formattedPhone,
                                    style: kBodyTextStyle.copyWith(
                                      fontSize: 13,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                ),

                              _InfoRow(
                                icon: Icons.local_drink_outlined,
                                child: Text(
                                  'Tipo: ${widget.brewery.type.label}',
                                  style: kBodyTextStyle.copyWith(
                                    fontSize: 13,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 4),
                              _FavoriteButton(brewery: widget.brewery),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  bool get _hasAddress =>
      (widget.brewery.street ?? '').isNotEmpty ||
      (widget.brewery.city ?? '').isNotEmpty;

  String get _addressLines {
    final parts = <String>[];
    if ((widget.brewery.street ?? '').trim().isNotEmpty) {
      parts.add(widget.brewery.street!.trim());
    }
    final cityState = [
      if ((widget.brewery.city ?? '').trim().isNotEmpty)
        widget.brewery.city!.trim(),
      if ((widget.brewery.state ?? '').trim().isNotEmpty)
        widget.brewery.state!.trim(),
    ].join(', ');
    if (cityState.isNotEmpty) parts.add(cityState);
    if ((widget.brewery.country ?? '').trim().isNotEmpty) {
      parts.add(widget.brewery.country!.trim());
    }
    return parts.join('\n');
  }
}

class _BackLink extends StatelessWidget {
  final VoidCallback onTap;
  const _BackLink({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.arrow_back_ios_rounded, size: 13, color: kAccent),
            const SizedBox(width: 4),
            Text(
              'Voltar ao mapa',
              style: kBodyTextStyle.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: kAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Widget child;
  const _InfoRow({required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = context.brewColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: colors.textSecondary),
          const SizedBox(width: 10),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _FavoriteButton extends StatefulWidget {
  final Brewery brewery;

  const _FavoriteButton({required this.brewery});

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.93,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _pulse;
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _handleTap({required Function(Brewery) toggleFavorite}) async {
    HapticFeedback.lightImpact();
    await _pulse.reverse();
    await _pulse.forward();
    await toggleFavorite(widget.brewery);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = getIt<BreweryCubit>();

    return BlocBuilder<BreweryCubit, BreweryState>(
      bloc: cubit,
      buildWhen: (previous, current) =>
          previous.favoriteBreweries != current.favoriteBreweries,
      builder: (context, state) {
        final isFavorited = state.isFavorite(widget.brewery.id);
        final colors = context.brewColors;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: ScaleTransition(
            scale: _scaleAnim,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _handleTap(toggleFavorite: cubit.toggleFavorite),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: kAccent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: kAccent.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isFavorited
                          ? Icons.sports_bar_rounded
                          : Icons.sports_bar_outlined,
                      size: 24,
                      color: colors.onAccent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isFavorited ? 'Favorito' : 'Adicionar aos Favoritos',
                      style: kBodyTextStyle.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colors.onAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
