import 'dart:async';

import 'package:flutter/material.dart';

class TopNotification extends StatefulWidget {
  final String message;
  final Duration duration;
  final Color backgroundColor;

  const TopNotification({
    super.key,
    required this.message,
    this.duration = const Duration(seconds: 3),
    this.backgroundColor = const Color(0xFF111827),
  });

  static OverlayEntry show(BuildContext context,
      {required String message,
      Duration duration = const Duration(seconds: 3),
      Color backgroundColor = const Color(0xFF111827)}) {
    final entry = OverlayEntry(
        builder: (ctx) => TopNotification(
              message: message,
              duration: duration,
              backgroundColor: backgroundColor,
            ));
    Overlay.of(context).insert(entry);
    // Schedule removal after duration + small fade
    Timer(duration + const Duration(milliseconds: 350), () {
      try {
        entry.remove();
      } catch (_) {}
    });
    return entry;
  }

  @override
  State<TopNotification> createState() => _TopNotificationState();
}

class _TopNotificationState extends State<TopNotification>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 300));
  late final Animation<Offset> _slide =
      Tween(begin: const Offset(0, -1), end: Offset.zero)
          .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    _ctrl.forward();
    Future.delayed(widget.duration, () async {
      await _ctrl.reverse();
      if (mounted) {
        // removal handled by caller's timer using OverlayEntry
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).viewPadding.top + 8;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: SlideTransition(
          position: _slide,
          child: Padding(
            padding: EdgeInsets.only(top: 8.0, left: 12, right: 12),
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.25), blurRadius: 8)
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(widget.message,
                          style: const TextStyle(color: Colors.white)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 18),
                      onPressed: () {
                        _ctrl.reverse();
                        // removal is handled by OverlayEntry timer in show()
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
