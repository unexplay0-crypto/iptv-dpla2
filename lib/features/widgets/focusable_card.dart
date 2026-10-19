import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

/// Envelope focavel por D-pad/toque. No foco: borda gradiente ciano-violeta
/// + escala + brilho (identidade Aurora). Usa FocusableActionDetector nativo.
class FocusableCard extends StatefulWidget {
  const FocusableCard({
    super.key,
    required this.child,
    required this.onSelected,
    this.focusScale = 1.06,
    this.borderRadius = 20,
    this.autofocus = false,
    this.padding = const EdgeInsets.all(6),
  });
  final Widget child;
  final VoidCallback onSelected;
  final double focusScale;
  final double borderRadius;
  final bool autofocus;
  final EdgeInsets padding;

  @override
  State<FocusableCard> createState() => _FocusableCardState();
}

class _FocusableCardState extends State<FocusableCard> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: FocusableActionDetector(
        autofocus: widget.autofocus,
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onSelected();
              return null;
            },
          ),
          ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
            onInvoke: (_) {
              widget.onSelected();
              return null;
            },
          ),
        },
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        onShowHoverHighlight: (v) => setState(() => _focused = v),
        child: GestureDetector(
          onTap: widget.onSelected,
          child: AnimatedScale(
            scale: _focused ? widget.focusScale : 1.0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: _focused ? const EdgeInsets.all(2) : EdgeInsets.zero,
              decoration: BoxDecoration(
                gradient: _focused ? AuroraColors.accentGradient : null,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: _focused
                    ? [
                        BoxShadow(
                          color: AuroraColors.accentCyan.withOpacity(0.45),
                          blurRadius: 22,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  _focused ? widget.borderRadius - 2 : widget.borderRadius,
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ButtonActivateIntent extends Intent {
  const ButtonActivateIntent();
}
