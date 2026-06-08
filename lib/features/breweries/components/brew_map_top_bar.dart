import 'package:brewmap/core/theme/theme.dart';
import 'package:brewmap/core/components/brew_map_logo.dart';
import 'package:flutter/material.dart';

const int brewMapExploreTabIndex = 0;
const int brewMapFavoritesTabIndex = 1;

class BrewMapTopBar extends StatelessWidget {
  const BrewMapTopBar({
    super.key,
    required this.tabController,
    required this.onAboutTap,
    this.onToggleTheme,
  });

  static const double compactBreakpoint = 700;

  final TabController tabController;
  final VoidCallback onAboutTap;
  final VoidCallback? onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < compactBreakpoint;
    final useIconNav = width < 400;
    final logoSize = isCompact ? 40.0 : 48.0;

    return ListenableBuilder(
      listenable: tabController,
      builder: (context, _) {
        final activeIndex = tabController.index;

        return Container(
          height: isCompact ? 56 : 80,
          padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 20),
          child: Row(
            children: [
              BrewMapLogo(size: logoSize),
              if (!isCompact) ...[
                const SizedBox(width: 14),
                Text(
                  'BrewMap',
                  style: kBrandTitleTextStyle.copyWith(color: kAccent),
                ),
              ],
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),
                    _BrewMapNavItem(
                      key: const Key('nav_explore'),
                      label: 'Explorar',
                      icon: Icons.explore_outlined,
                      active: activeIndex == brewMapExploreTabIndex,
                      compact: isCompact,
                      iconOnly: useIconNav,
                      onTap: () =>
                          tabController.animateTo(brewMapExploreTabIndex),
                    ),
                    const SizedBox(width: 14),
                    _BrewMapNavItem(
                      key: const Key('nav_favorites'),
                      label: 'Favoritos',
                      icon: Icons.favorite_border_rounded,
                      active: activeIndex == brewMapFavoritesTabIndex,
                      compact: isCompact,
                      iconOnly: useIconNav,
                      onTap: () =>
                          tabController.animateTo(brewMapFavoritesTabIndex),
                    ),
                    const SizedBox(width: 14),
                    _BrewMapNavItem(
                      label: 'Sobre',
                      icon: Icons.info_outline_rounded,
                      active: false,
                      compact: isCompact,
                      iconOnly: useIconNav,
                      onTap: onAboutTap,
                    ),
                    IconButton(
                      onPressed: onToggleTheme,
                      icon: Icon(
                        Theme.of(context).brightness == Brightness.dark
                            ? Icons.lightbulb
                            : Icons.lightbulb_outline_rounded,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BrewMapNavItem extends StatelessWidget {
  const _BrewMapNavItem({
    super.key,
    required this.label,
    required this.icon,
    required this.active,
    required this.compact,
    required this.iconOnly,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final bool compact;
  final bool iconOnly;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.brewColors;
    final color = active ? kAccent : colors.textSecondary;
    final fontSize = compact ? 12.0 : 14.0;

    return Semantics(
      button: true,
      label: label,
      selected: active,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.only(
            left: compact ? 4 : 12,
            right: compact ? 4 : 12,
            top: compact ? 4 : 6,
            bottom: compact ? 2 : 4,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? kAccent : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: iconOnly
              ? Icon(icon, size: 22, color: color)
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: kBodyTextStyle.copyWith(
                      fontSize: fontSize,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      color: color,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
