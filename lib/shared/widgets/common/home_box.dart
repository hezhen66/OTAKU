import 'package:astral/shared/theme/app_theme.dart';
import 'package:astral/shared/widgets/hud/frosted_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HomeBox extends StatefulWidget {
  final int widthSpan;
  final Widget? child;
  final double? fixedCellHeight;
  final bool? isBorder;

  const HomeBox({
    super.key,
    required this.widthSpan,
    this.child,
    this.fixedCellHeight,
    this.isBorder = true,
  });

  @override
  State<HomeBox> createState() => _HomeBoxState();
}

class _HomeBoxState extends State<HomeBox> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return widget.fixedCellHeight != null
        ? StaggeredGridTile.extent(
            crossAxisCellCount: widget.widthSpan,
            mainAxisExtent: widget.fixedCellHeight!,
            child: _buildContent(),
          )
        : StaggeredGridTile.fit(
            crossAxisCellCount: widget.widthSpan,
            child: _buildContent(),
          );
  }

  Widget _buildContent() {
    final effectiveBorder = widget.isBorder ?? true;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: FrostedGlassPanel(
        padding: EdgeInsets.all(effectiveBorder ? 12 : 1),
        borderRadius: effectiveBorder ? AppTheme.panelRadius : 0,
        borderColor: isHovered ? AppTheme.primary : AppTheme.glassBorder,
        showGlow: isHovered,
        glowColor: AppTheme.primary,
        child: SizedBox(
          height: widget.fixedCellHeight,
          width: double.infinity,
          child: widget.child,
        ),
      ),
    );
  }
}
