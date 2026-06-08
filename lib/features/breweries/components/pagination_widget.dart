import 'package:brewmap/core/theme/theme.dart';
import 'package:brewmap/features/breweries/utils/brewery_list_filter.dart';
import 'package:flutter/material.dart';

class PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalResults;
  final int showing;
  final ValueChanged<int> onPageChanged;

  const PaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalResults,
    required this.showing,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.brewColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Text(
            'Encontramos ',
            style: kBodyTextStyle.copyWith(
              fontSize: 12,
              color: colors.textSecondary,
            ),
          ),
          Text(
            '$totalResults',
            style: kBodyTextStyle.copyWith(
              fontSize: 12,
              color: kAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            ' resultados',
            style: kBodyTextStyle.copyWith(
              fontSize: 12,
              color: colors.textSecondary,
            ),
          ),
          const Spacer(),
          _PageButton(
            icon: Icons.chevron_left_rounded,
            enabled: currentPage > 1,
            onTap: () => onPageChanged(currentPage - 1),
          ),
          const SizedBox(width: 4),
          ...BreweryListFilter.paginationPageSlots(currentPage, totalPages).map(
            (slot) => Padding(
              padding: const EdgeInsets.only(right: 4),
              child: slot == null
                  ? const _PageEllipsis()
                  : _PageNumber(
                      page: slot,
                      isActive: currentPage == slot,
                      onTap: () => onPageChanged(slot),
                    ),
            ),
          ),
          _PageButton(
            icon: Icons.chevron_right_rounded,
            enabled: currentPage < totalPages,
            onTap: () => onPageChanged(currentPage + 1),
          ),
        ],
      ),
    );
  }
}

class _PageEllipsis extends StatelessWidget {
  const _PageEllipsis();

  @override
  Widget build(BuildContext context) {
    final colors = context.brewColors;
    return SizedBox(
      width: 28,
      height: 28,
      child: Center(
        child: Text(
          '…',
          style: kMonoTextStyle.copyWith(
            fontSize: 12,
            color: colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _PageNumber extends StatelessWidget {
  final int page;
  final bool isActive;
  final VoidCallback onTap;

  const _PageNumber({
    required this.page,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.brewColors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isActive ? kAccent : colors.surfaceElevated,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isActive ? kAccent : colors.border),
        ),
        alignment: Alignment.center,
        child: Text(
          '$page',
          style: kMonoTextStyle.copyWith(
            fontSize: 12,
            color: isActive ? colors.onAccent : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _PageButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.brewColors;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: colors.border),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 16,
          color: enabled ? colors.textSecondary : colors.border,
        ),
      ),
    );
  }
}
