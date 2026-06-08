import 'package:brewmap/core/theme/theme.dart';
import 'package:flutter/material.dart';

class MapZoomControls extends StatelessWidget {
  const MapZoomControls({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MapControlButton(icon: Icons.add_rounded, onTap: onZoomIn),
        const SizedBox(height: 4),
        _MapControlButton(icon: Icons.remove_rounded, onTap: onZoomOut),
      ],
    );
  }
}

class _MapControlButton extends StatelessWidget {
  const _MapControlButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.brewColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 4,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: colors.textSecondary),
      ),
    );
  }
}

