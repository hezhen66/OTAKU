import 'package:astral/shared/theme/app_theme.dart';
import 'package:astral/shared/widgets/hud/frosted_glass.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/core/models/room.dart';
import 'package:flutter/material.dart';

class RoomCard extends StatefulWidget {
  final Room room;
  final bool isSelected;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;

  const RoomCard({
    super.key,
    required this.room,
    this.isSelected = false,
    this.onEdit,
    this.onDelete,
    this.onShare,
  });

  @override
  State<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final room = widget.room;

    final Color glassBorder = widget.isSelected
        ? AppTheme.primaryGlow
        : (_isHovered ? AppTheme.primary : AppTheme.glassBorder);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: FrostedGlassPanel(
        padding: const EdgeInsets.all(16),
        borderColor: glassBorder,
        showGlow: widget.isSelected || _isHovered,
        glowColor: AppTheme.primary,
        onTap: () {
          ServiceManager().room.setRoom(room);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (widget.isSelected)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.check_circle,
                            color: AppTheme.primaryGlow,
                            size: 20,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          room.name,
                          style: AppTheme.hudBody(fontSize: 16, color: AppTheme.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    if (widget.onShare != null)
                      IconButton(
                        icon: Icon(Icons.share, size: 18, color: AppTheme.textSecondary),
                        onPressed: widget.onShare,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: '分享房间',
                      ),
                    if (widget.onShare != null &&
                        (widget.onDelete != null || widget.onEdit != null))
                      const SizedBox(width: 8),
                    if (widget.onDelete != null)
                      widget.isSelected
                          ? Tooltip(
                              message: '不能删除正在连接的房间',
                              child: IconButton(
                                icon: Icon(Icons.delete, size: 18, color: AppTheme.textSecondary),
                                onPressed: null,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            )
                          : IconButton(
                              icon: Icon(Icons.delete, size: 18, color: const Color(0xFFCC3333)),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  barrierColor: const Color(0xFF030A10).withValues(alpha: 0.80),
                                  builder: (ctx) => Material(
                                    type: MaterialType.transparency,
                                    child: Center(
                                      child: Container(
                                        width: 420,
                                        padding: const EdgeInsets.all(28),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF030A10).withValues(alpha: 0.85),
                                          border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.55), width: 1),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            const Text('确认删除',
                                                style: TextStyle(fontFamily: 'Orbitron', fontSize: 16,
                                                    fontWeight: FontWeight.bold, color: Colors.white,
                                                    letterSpacing: 2, decoration: TextDecoration.none)),
                                            const SizedBox(height: 20),
                                            const Text('确定要删除这个房间吗？',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontFamily: 'Orbitron', fontSize: 13,
                                                    color: Color(0xFF5F7588), letterSpacing: 1.5,
                                                    decoration: TextDecoration.none)),
                                            const SizedBox(height: 28),
                                            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                              _DialogBtn(
                                                  label: 'CANCEL',
                                                  onTap: () => Navigator.pop(ctx)),
                                              const SizedBox(width: 16),
                                              _DialogBtn(
                                                  label: 'DELETE',
                                                  color: const Color(0xFFCC3333),
                                                  onTap: () {
                                                    Navigator.pop(ctx);
                                                    widget.onDelete?.call();
                                                  }),
                                            ]),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              tooltip: '删除房间',
                            ),
                    if (widget.onDelete != null && widget.onEdit != null)
                      const SizedBox(width: 8),
                    if (widget.onEdit != null)
                      IconButton(
                        icon: Icon(Icons.edit, size: 18, color: AppTheme.textSecondary),
                        onPressed: widget.onEdit,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: '编辑房间',
                      ),
                    const SizedBox(width: 8),
                    Icon(
                      room.encrypted ? Icons.lock : Icons.lock_open,
                      color: room.encrypted ? const Color(0xFFCC3333) : const Color(0xFF22CC66),
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '类型: ${room.encrypted ? "保护" : "不保护"}',
                  style: AppTheme.hudBody(fontSize: 12, color: AppTheme.textSecondary),
                ),
                if (room.servers.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      '携带服务器',
                      style: AppTheme.hudMono(color: AppTheme.primary),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogBtn extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _DialogBtn({required this.label, required this.onTap, this.color});

  @override
  State<_DialogBtn> createState() => _DialogBtnState();
}

class _DialogBtnState extends State<_DialogBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.color ?? const Color(0xFF5F7588);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: _hovered ? c.withValues(alpha: 0.1) : Colors.transparent,
            border: Border.all(color: c.withValues(alpha: 0.65), width: 0.65),
          ),
          child: Text(widget.label,
              style: TextStyle(fontFamily: 'Orbitron', fontSize: 14,
                  fontWeight: FontWeight.w500, color: c,
                  letterSpacing: 2, decoration: TextDecoration.none)),
        ),
      ),
    );
  }
}
