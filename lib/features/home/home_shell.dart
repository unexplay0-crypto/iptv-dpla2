import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';

/// Shell de navegacao adaptativa:
///  - TV/tablet (largura >= 960dp): barra lateral fixa (padrao Leanback).
///  - Celular: barra inferior (BottomNavigationBar).
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.child});

  final Widget child;

  static const _items = <_NavItem>[
    _NavItem(label: 'Inicio', icon: Icons.home, location: AppRouter.home),
    _NavItem(label: 'Ao Vivo', icon: Icons.live_tv, location: AppRouter.live),
    _NavItem(label: 'Filmes', icon: Icons.movie, location: AppRouter.movies),
    _NavItem(label: 'Series', icon: Icons.tv, location: AppRouter.series),
    _NavItem(
        label: 'Favoritos', icon: Icons.favorite, location: AppRouter.favorites),
    _NavItem(label: 'Busca', icon: Icons.search, location: AppRouter.search),
    _NavItem(
        label: 'Configuracoes', icon: Icons.settings, location: AppRouter.settings),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isTv = width >= 960;
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _selectedIndex(location);

    if (isTv) {
      return Scaffold(
        body: Row(
          children: [
            _TvSidebar(items: _items, selectedIndex: selectedIndex),
            Expanded(
              // Margens de seguranca (overscan) ~5%.
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.tvOverscanHorizontal,
                  vertical: AppConstants.tvOverscanVertical,
                ),
                child: child,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex < 0
            ? 0
            : (selectedIndex >= _items.length
                ? _items.length - 1
                : selectedIndex),
        onDestinationSelected: (i) => context.go(_items[i].location),
        destinations: _items
            .map((e) => NavigationDestination(icon: Icon(e.icon), label: e.label))
            .toList(),
      ),
    );
  }

  int _selectedIndex(String location) {
    for (var i = 0; i < _items.length; i++) {
      final loc = _items[i].location;
      if (loc == AppRouter.home) {
        if (location == '/' || location.isEmpty) return i;
      } else if (location.startsWith(loc)) {
        return i;
      }
    }
    return 0;
  }
}

class _NavItem {
  const _NavItem(
      {required this.label, required this.icon, required this.location});
  final String label;
  final IconData icon;
  final String location;
}

class _TvSidebar extends StatelessWidget {
  const _TvSidebar({required this.items, required this.selectedIndex});

  final List<_NavItem> items;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: AuroraColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 8, 12, 24),
            child: Text(
              AppConstants.appName,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];
                final selected = i == selectedIndex;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: _SidebarButton(
                    icon: item.icon,
                    label: item.label,
                    selected: selected,
                    autofocus: selected,
                    onTap: () => context.go(item.location),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarButton extends StatefulWidget {
  const _SidebarButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.autofocus = false,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool autofocus;

  @override
  State<_SidebarButton> createState() => _SidebarButtonState();
}

class _SidebarButtonState extends State<_SidebarButton> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      autofocus: widget.autofocus,
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: _focused
                ? Colors.white
                : (widget.selected ? AuroraColors.glass : Colors.transparent),
            borderRadius: BorderRadius.circular(10),
            border: _focused
                ? Border.all(color: AuroraColors.accentCyan, width: 2)
                : null,
          ),
          child: Row(
            children: [
              Icon(widget.icon,
                  size: 24,
                  color: _focused ? Colors.black : Colors.white),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        widget.selected ? FontWeight.bold : FontWeight.w500,
                    color: _focused ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
