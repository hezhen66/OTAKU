import 'package:astral/shared/theme/app_theme.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/core/states/connection_state.dart' show CoState;
import 'package:astral/core/navigation.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

class LeftNav extends StatefulWidget {
  final List<NavigationItem> items;
  final ColorScheme colorScheme;

  const LeftNav({super.key, required this.items, required this.colorScheme});

  @override
  State<LeftNav> createState() => _LeftNavState();
}

class _LeftNavState extends State<LeftNav> {
  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final selectedIndex = ServiceManager().uiState.selectedIndex.value;
      final hoveredIndex = ServiceManager().uiState.hoveredIndex.value;
      final connState = ServiceManager().connectionState.connectionState.watch(context);

      return Material(
        color: Colors.transparent,
        child: Container(
          width: AppTheme.leftNavWidth,
          decoration: BoxDecoration(
            color: AppTheme.bgPanel,
            border: Border(right: BorderSide(color: AppTheme.subtleDivider, width: 1)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    return _NavItem(
                      key: ValueKey('nav_$index'),
                      item: widget.items[index],
                      index: index,
                      isSelected: selectedIndex == index,
                      isHovered: hoveredIndex == index,
                      connectionIconLit: widget.items[index].label == '联机房间'
                          && connState == CoState.connected,
                      onTap: () {
                        if (widget.items[index].onTap != null) {
                          widget.items[index].onTap!();
                          return;
                        }
                        if (ServiceManager().uiState.selectedIndex.value != index) {
                          ServiceManager().uiState.selectedIndex.value = index;
                        }
                      },
                      onHoverEnter: () => ServiceManager().uiState.hoveredIndex.value = index,
                      onHoverExit: () => ServiceManager().uiState.hoveredIndex.value = null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _NavItem extends StatefulWidget {
  final NavigationItem item;
  final int index;
  final bool isSelected;
  final bool isHovered;
  final bool connectionIconLit;
  final VoidCallback onTap;
  final VoidCallback onHoverEnter;
  final VoidCallback onHoverExit;

  const _NavItem({
    super.key,
    required this.item,
    required this.index,
    required this.isSelected,
    required this.isHovered,
    this.connectionIconLit = false,
    required this.onTap,
    required this.onHoverEnter,
    required this.onHoverExit,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  static const Color _activeCyan = Color(0xFF00D2FF);
  static const Color _activeBg = Color(0x0A00FFFF);
  static const Color _activeBorder = Color(0x6600D2FF);
  static const Color _inactiveText = Color(0xFF5F7588);

  Color _prevIconColor = _inactiveText;
  Color _prevTextColor = _inactiveText;

  @override
  Widget build(BuildContext context) {
    final Color leftBarColor = widget.isSelected ? _activeCyan : Colors.transparent;
    final double leftBarWidth = widget.isSelected ? 3.0 : 0.0;

    final Color bgColor = widget.isSelected
        ? _activeBg
        : widget.isHovered
            ? _activeCyan.withValues(alpha: 0.04)
            : Colors.transparent;

    final Color borderColor = widget.isSelected ? _activeBorder : Colors.transparent;

    final Color iconColor = widget.isSelected
        ? _activeCyan
        : widget.connectionIconLit
            ? _activeCyan
            : widget.isHovered
                ? AppTheme.textPrimary
                : _inactiveText;
    final Color textColor = widget.isSelected
        ? AppTheme.textPrimary
        : widget.isHovered
            ? AppTheme.textPrimary
            : _inactiveText;

    // 记录当前颜色供下次动画起点
    final Color fromIcon = _prevIconColor;
    final Color fromText = _prevTextColor;
    _prevIconColor = iconColor;
    _prevTextColor = textColor;

    return MouseRegion(
      onEnter: (_) => widget.onHoverEnter(),
      onExit: (_) => widget.onHoverExit(),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          width: AppTheme.leftNavWidth,
          height: 56,
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.zero,
            border: Border.all(color: borderColor, width: widget.isSelected ? 1.0 : 0.0),
            boxShadow: widget.isSelected
                ? [BoxShadow(color: _activeCyan.withValues(alpha: 0.12), blurRadius: 8)]
                : null,
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOutCubic,
                  width: leftBarWidth,
                  decoration: BoxDecoration(
                    color: leftBarColor,
                    borderRadius: BorderRadius.zero,
                    boxShadow: widget.isSelected
                        ? [BoxShadow(color: _activeCyan.withValues(alpha: 0.55), blurRadius: 4)]
                        : null,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 图标 + 可选微光（主页激活时）
                    TweenAnimationBuilder<Color?>(
                      tween: ColorTween(begin: fromIcon, end: iconColor),
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOut,
                      builder: (context, color, _) => Icon(
                        widget.isSelected ? widget.item.activeIcon : widget.item.icon,
                        color: color,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 3),
                    // 文字颜色渐变
                    TweenAnimationBuilder<Color?>(
                      tween: ColorTween(begin: fromText, end: textColor),
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOut,
                      builder: (context, color, _) => Text(
                        widget.item.label,
                        style: AppTheme.hudBody(color: color, fontSize: 10).copyWith(
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.none,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
