import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Chip de categoria/filtro focavel. Selecionado: fundo gradiente Aurora.
class CategoryChip extends StatefulWidget {
  const CategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<CategoryChip> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onTap();
            return null;
          },
        ),
      },
      onShowFocusHighlight: (v) => setState(() => _focused = v),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
          decoration: BoxDecoration(
            gradient: (_focused || widget.selected)
                ? AuroraColors.accentGradient
                : null,
            color:
                (_focused || widget.selected) ? null : AuroraColors.glass,
            borderRadius: BorderRadius.circular(24),
            border: _focused
                ? Border.all(color: Colors.white, width: 2)
                : null,
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: (_focused || widget.selected)
                  ? Colors.white
                  : AuroraColors.onSurfaceMuted,
              fontWeight:
                  widget.selected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
