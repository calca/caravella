import 'dart:async';
import 'package:flutter/material.dart';

/// Lightweight toast / inline feedback replacing SnackBar with
/// fade + slide animation and automatic queue management.
class AppToast {
  AppToast._();

  static final List<_ToastEntry> _queue = [];
  static bool _showing = false;

  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 2400),
    ToastType type = ToastType.info,
    IconData? icon,
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    _queue.add(
      _ToastEntry(
        message: message,
        duration: duration,
        type: type,
        icon: icon,
        overlay: overlay,
      ),
    );
    if (!_showing) {
      _dequeue();
    }
  }

  static Future<void> _dequeue() async {
    if (_queue.isEmpty) {
      _showing = false;
      return;
    }
    _showing = true;
    final entry = _queue.removeAt(0);
    entry.show();
    await Future.delayed(entry.duration + const Duration(milliseconds: 220));
    _dequeue();
  }
}

enum ToastType { info, success, error }

class _ToastEntry {
  _ToastEntry({
    required this.message,
    required this.duration,
    required this.type,
    this.icon,
    required this.overlay,
  });
  final String message;
  final Duration duration;
  final ToastType type;
  final IconData? icon;
  final OverlayState overlay;
  late final OverlayEntry _entry;

  void show() {
    _entry = OverlayEntry(
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        Color bg;
        switch (type) {
          case ToastType.success:
            bg = scheme.surfaceContainerHigh;
            break;
          case ToastType.error:
            bg = scheme.errorContainer;
            break;
          case ToastType.info:
            bg = scheme.surfaceContainerHigh;
            break;
        }
        final fg = type == ToastType.error
            ? scheme.onErrorContainer
            : scheme.onSurfaceVariant;
        return _AnimatedToast(
          message: message,
          background: bg,
          foreground: fg,
          icon: icon ?? _defaultIcon(),
          duration: duration,
          onClosed: () {
            _entry.remove();
          },
        );
      },
    );
    overlay.insert(_entry);
  }

  IconData _defaultIcon() {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle_outline_rounded;
      case ToastType.error:
        return Icons.error_outline_outlined;
      case ToastType.info:
        return Icons.info_outline;
    }
  }
}

class _AnimatedToast extends StatefulWidget {
  const _AnimatedToast({
    required this.message,
    required this.background,
    required this.foreground,
    required this.icon,
    required this.duration,
    required this.onClosed,
  });
  final String message;
  final Color background;
  final Color foreground;
  final IconData icon;
  final Duration duration;
  final VoidCallback onClosed;

  @override
  State<_AnimatedToast> createState() => _AnimatedToastState();
}

class _AnimatedToastState extends State<_AnimatedToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    reverseDuration: const Duration(milliseconds: 240),
  );
  late final Animation<Offset> _offset = Tween(
    begin: const Offset(0, 0.35),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
    Future.delayed(widget.duration, () async {
      if (!mounted) return;
      await _controller.reverse();
      if (mounted) widget.onClosed();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Positioned(
      left: 0,
      right: 0,
      bottom: media.padding.bottom + 16,
      child: Semantics(
        liveRegion: true,
        container: true,
        label: widget.message,
        child: SlideTransition(
          position: _offset,
          child: FadeTransition(
            opacity: _fade,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Material(
                    color: widget.background.withValues(alpha: 0.95),
                    elevation: 0, // removed shadow
                    shadowColor: Colors.transparent,
                    clipBehavior: Clip.antiAlias,
                    borderRadius: BorderRadius.circular(14),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outlineVariant.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.icon,
                              color: widget.foreground,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                widget.message,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: widget.foreground),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
