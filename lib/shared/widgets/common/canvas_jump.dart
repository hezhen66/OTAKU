import 'dart:async';
import 'package:astral/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:astral/core/models/room.dart';

class CanvasJump {
  static void show(BuildContext context, {required List<Room> rooms, required Function(Room) onSelect}) {
    showDialog(
      context: context,
      barrierColor: const Color(0xFF030A10).withValues(alpha: 0.75),
      builder: (context) => _CanvasDialog(rooms: rooms, onSelect: onSelect),
    );
  }
}

class _CanvasDialog extends StatefulWidget {
  final List<Room> rooms;
  final Function(Room) onSelect;
  const _CanvasDialog({required this.rooms, required this.onSelect});
  @override
  State<_CanvasDialog> createState() => _CanvasDialogState();
}

class _CanvasDialogState extends State<_CanvasDialog> {
  late List<Room> _filteredRooms;
  final TextEditingController _searchController = TextEditingController();
  String _currentHoveredRoomName = '';

  @override
  void initState() {
    super.initState();
    _filteredRooms = widget.rooms;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterRooms(String query) {
    setState(() {
      _filteredRooms = widget.rooms
          .where((room) => room.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Material(
      type: MaterialType.transparency,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: screenSize.width / 1.2,
          constraints: BoxConstraints(maxHeight: screenSize.height / 2 + 80),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1B2A),
            border: Border.all(color: const Color(0xFF1E3A5A), width: 1),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 2),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题栏
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(children: [
                  Icon(Icons.meeting_room, color: AppTheme.primary, size: 22),
                  const SizedBox(width: 10),
                  Text('选择房间',
                      style: AppTheme.hudTitle().copyWith(fontSize: 16)),
                ]),
              ),
              const SizedBox(height: 16),
              // 搜索框
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.none),
                  decoration: InputDecoration(
                    hintText: '搜索房间',
                    hintStyle: TextStyle(color: AppTheme.textSecondary),
                    prefixIcon: const Icon(Icons.search, size: 22, color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: const Color(0xFF07121E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(color: const Color(0xFF1E3A5A)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(color: const Color(0xFF1E3A5A)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(color: AppTheme.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: _filterRooms,
                ),
              ),
              const SizedBox(height: 12),
              // 列表
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _filteredRooms.length,
                  itemBuilder: (context, index) {
                    final room = _filteredRooms[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: MouseRegion(
                        onEnter: (_) => setState(() => _currentHoveredRoomName = room.name),
                        onExit: (_) => setState(() => _currentHoveredRoomName = ''),
                        child: GestureDetector(
                          onTap: () {
                            widget.onSelect(room);
                            Navigator.pop(context);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: _currentHoveredRoomName == room.name
                                  ? AppTheme.primary.withValues(alpha: 0.08)
                                  : const Color(0xFF07121E),
                              border: Border.all(
                                color: _currentHoveredRoomName == room.name
                                    ? AppTheme.primary
                                    : Colors.transparent,
                                width: 1,
                              ),
                            ),
                            child: Row(children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(room.name,
                                        style: AppTheme.hudBody(fontSize: 15, color: Colors.white)),
                                    const SizedBox(height: 2),
                                    Text(room.encrypted ? '加密房间' : '开放房间',
                                        style: AppTheme.hudBody(fontSize: 12, color: AppTheme.textSecondary)),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                            ]),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // 取消
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 16, 12),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('取消',
                        style: TextStyle(fontFamily: 'Orbitron', fontSize: 14,
                            color: AppTheme.primary, decoration: TextDecoration.none)),
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
