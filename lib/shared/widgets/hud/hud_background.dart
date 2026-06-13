import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class HUDScaffoldBackground extends StatelessWidget {
  final Widget child;
  final String backgroundAsset;

  const HUDScaffoldBackground({
    super.key,
    required this.child,
    this.backgroundAsset = 'assets/backgrounds/bg_main.png',
  });

  bool get _isVideo => !backgroundAsset.startsWith('assets/') &&
      RegExp(r'\.(mp4|mov|webm|avi|mkv)$', caseSensitive: false).hasMatch(backgroundAsset);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: Container(color: const Color(0xFF050B15))),
        Positioned.fill(child: _isVideo ? _VideoBg(path: backgroundAsset) : _StaticBg(path: backgroundAsset)),
        Positioned.fill(child: Container(color: const Color(0xFF0F141C).withValues(alpha: 0.18))),
        child,
      ],
    );
  }
}

class _StaticBg extends StatelessWidget {
  final String path;
  const _StaticBg({required this.path});
  @override
  Widget build(BuildContext context) {
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: const Color(0xFF050B15)),
          frameBuilder: (_, child, frame, wasSync) {
            if (wasSync) return child ?? Container(color: const Color(0xFF050B15));
            if (child == null) return Container(color: const Color(0xFF050B15));
            return child;
          });
    }
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: const Color(0xFF050B15)),
          frameBuilder: (_, child, frame, wasSync) {
            if (wasSync) return child ?? Container(color: const Color(0xFF050B15));
            if (child == null) return Container(color: const Color(0xFF050B15));
            return child;
          });
    }
    return Container(color: const Color(0xFF050B15));
  }
}

class _VideoBg extends StatefulWidget {
  final String path;
  const _VideoBg({required this.path});
  @override State<_VideoBg> createState() => _VideoBgState();
}

class _VideoBgState extends State<_VideoBg> {
  VideoPlayerController? _ctrl;
  String? _lastPath;

  void _loadVideo(String path) {
    _ctrl?.dispose();
    _lastPath = path;
    final ctrl = VideoPlayerController.file(File(path));
    ctrl.setLooping(true);
    ctrl.setVolume(0);
    _ctrl = ctrl;
    ctrl.initialize().then((_) {
      if (mounted) setState(() {});
      ctrl.play();
    }).catchError((e) {
      debugPrint('FVP Video init failed: $e');
    });
    ctrl.addListener(() {
      if (!mounted) return;
      final pos = ctrl.value.position;
      final dur = ctrl.value.duration;
      if (dur > Duration.zero && pos >= dur - const Duration(milliseconds: 100)) {
        ctrl.seekTo(Duration.zero);
        ctrl.play();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadVideo(widget.path);
  }

  @override
  void didUpdateWidget(_VideoBg old) {
    super.didUpdateWidget(old);
    if (widget.path != _lastPath) _loadVideo(widget.path);
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ctrl == null || !_ctrl!.value.isInitialized) return Container(color: const Color(0xFF050B15));
    return Positioned.fill(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _ctrl!.value.size.width,
          height: _ctrl!.value.size.height,
          child: VideoPlayer(_ctrl!),
        ),
      ),
    );
  }
}
