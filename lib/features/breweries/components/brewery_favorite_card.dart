import 'package:brewmap/core/theme/theme.dart';
import 'package:brewmap/core/utils/url_launcher_helper.dart';
import 'package:brewmap/features/breweries/components/type_badge_widget.dart';
import 'package:brewmap/features/breweries/models/brewery_model.dart';
import 'package:flutter/material.dart';

class BreweryFavoriteCard extends StatefulWidget {
  const BreweryFavoriteCard({
    super.key,
    required this.brewery,
    required this.onRemove,
  });

  final Brewery brewery;
  final VoidCallback onRemove;

  @override
  State<BreweryFavoriteCard> createState() => _BreweryFavoriteCardState();
}

class _BreweryFavoriteCardState extends State<BreweryFavoriteCard>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late final AnimationController _removeAnim;

  @override
  void initState() {
    super.initState();
    _removeAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      lowerBound: 0.0,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _removeAnim.dispose();
    super.dispose();
  }

  Future<void> _handleRemove() async {
    await _removeAnim.reverse();
    widget.onRemove();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.brewColors;

    return AnimatedBuilder(
      animation: _removeAnim,
      builder: (context, child) => Opacity(
        opacity: _removeAnim.value,
        child: Transform.scale(
          scale: 0.96 + 0.04 * _removeAnim.value,
          child: child,
        ),
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hovered ? colors.surfaceHover : colors.border,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.brewery.name,
                          style: kBodyTextStyle.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.brewery.compactLocation != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            widget.brewery.compactLocation!,
                            style: kBodyTextStyle.copyWith(
                              fontSize: 12,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _handleRemove,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 6, top: 1),
                      child: Icon(Icons.star_rounded, size: 20, color: kAccent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TypeBadge(type: widget.brewery.type, variant: TypeBadgeVariant.soft),
              const SizedBox(height: 10),
              Divider(color: colors.border, height: 1),
              const SizedBox(height: 10),
              if ((widget.brewery.websiteUrl ?? '').isNotEmpty)
                InfoLine(
                  icon: Icons.language_outlined,
                  label: displayWebsiteUrl(widget.brewery.websiteUrl!),
                  color: kAccent,
                  underline: true,
                  onTap: () =>
                      launchExternalUrl(context, widget.brewery.websiteUrl!),
                ),
              if ((widget.brewery.phone ?? '').isNotEmpty)
                InfoLine(
                  icon: Icons.phone_outlined,
                  label: formatPhoneUS10(widget.brewery.phone!),
                  color: colors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoLine extends StatelessWidget {
  const InfoLine({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
    this.underline = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool underline;

  @override
  Widget build(BuildContext context) {
    final colors = context.brewColors;
    final textStyle = kBodyTextStyle.copyWith(
      fontSize: 12,
      color: color,
      decoration: underline ? TextDecoration.underline : null,
      decorationColor: underline ? color.withValues(alpha: 0.4) : null,
    );

    final labelWidget = Text(
      label,
      style: textStyle,
      overflow: TextOverflow.ellipsis,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 13, color: colors.textSecondary),
          const SizedBox(width: 6),
          Expanded(
            child: onTap != null
                ? GestureDetector(onTap: onTap, child: labelWidget)
                : labelWidget,
          ),
        ],
      ),
    );
  }
}

