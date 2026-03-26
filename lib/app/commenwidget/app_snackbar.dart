import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────── PUBLIC SNACKBAR CLASS ───────────────────

class TcSnackbar {
  static OverlayEntry? _currentEntry;
  static bool _isShowing = false;

  static void success(String title, String message) =>
      _show(title: title, message: message, type: _SnackType.success);

  static void warning(String title, String message) =>
      _show(title: title, message: message, type: _SnackType.warning);

  static void error(String title, String message) {
    final msg = message.toLowerCase();
    final isNetwork =
        msg.contains('socketexception') ||
        msg.contains('failed host lookup') ||
        msg.contains('network error') ||
        msg.contains('clientexception');

    if (isNetwork) {
      noInternet();
    } else {
      _show(title: title, message: message, type: _SnackType.error);
    }
  }

  static void info(String title, String message) =>
      _show(title: title, message: message, type: _SnackType.info);

  static void noInternet() => _show(
    title: 'No Connection',
    message: 'Please check your internet connection and try again.',
    type: _SnackType.error,
  );

  static void _show({
    required String title,
    required String message,
    required _SnackType type,
  }) {
    final context = Get.overlayContext ?? Get.context;
    if (context == null) return;
    if (_isShowing) _forceRemove();

    _isShowing = true;
    HapticFeedback.lightImpact();

    try {
      final overlay = Overlay.of(context, rootOverlay: true);

      _currentEntry = OverlayEntry(
        builder: (_) => _SnackbarWidget(
          title: title,
          message: message,
          type: type,
          onDismissed: _forceRemove,
        ),
      );

      overlay.insert(_currentEntry!);
    } catch (_) {
      // Fallback if overlay not available (e.g. during early app startup)
      _isShowing = false;
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: _typeToColor(type),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        animationDuration: const Duration(milliseconds: 250),
      );
    }
  }

  static void _forceRemove() {
    _currentEntry?.remove();
    _currentEntry = null;
    _isShowing = false;
  }

  static Color _typeToColor(_SnackType type) {
    switch (type) {
      case _SnackType.success:
        return const Color(0xFF22C55E);
      case _SnackType.warning:
        return const Color(0xFFF59E0B);
      case _SnackType.error:
        return const Color(0xFFEF4444);
      case _SnackType.info:
        return const Color(0xFF3B82F6);
    }
  }
}

// ─────────────────── TYPE ENUM ───────────────────

enum _SnackType { success, warning, error, info }

extension _SnackTypeExt on _SnackType {
  Color get accent {
    switch (this) {
      case _SnackType.success:
        return const Color(0xFF22C55E);
      case _SnackType.warning:
        return const Color(0xFFF59E0B);
      case _SnackType.error:
        return const Color(0xFFEF4444);
      case _SnackType.info:
        return const Color(0xFF3B82F6);
    }
  }

  IconData get icon {
    switch (this) {
      case _SnackType.success:
        return Icons.check_circle_rounded;
      case _SnackType.warning:
        return Icons.warning_amber_rounded;
      case _SnackType.error:
        return Icons.cancel_rounded;
      case _SnackType.info:
        return Icons.info_rounded;
    }
  }

  String get label {
    switch (this) {
      case _SnackType.success:
        return 'Success';
      case _SnackType.warning:
        return 'Warning';
      case _SnackType.error:
        return 'Error';
      case _SnackType.info:
        return 'Info';
    }
  }
}

// ─────────────────── WIDGET ───────────────────

class _SnackbarWidget extends StatefulWidget {
  final String title;
  final String message;
  final _SnackType type;
  final VoidCallback onDismissed;

  const _SnackbarWidget({
    required this.title,
    required this.message,
    required this.type,
    required this.onDismissed,
  });

  @override
  State<_SnackbarWidget> createState() => _SnackbarWidgetState();
}

class _SnackbarWidgetState extends State<_SnackbarWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  static const _showDuration = Duration(milliseconds: 380);
  static const _holdDuration = Duration(milliseconds: 3200);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: _showDuration);

    _slide = Tween<Offset>(
      begin: const Offset(0, -1.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // Play enter animation, hold, then exit
    _controller.forward().then((_) async {
      await Future.delayed(_holdDuration);
      if (mounted) {
        await _controller.reverse();
        widget.onDismissed();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() async {
    if (_controller.isAnimating) return;
    await _controller.reverse();
    widget.onDismissed();
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final type = widget.type;

    return Positioned(
      top: safeTop + 14,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _slide,
          child: FadeTransition(opacity: _fade, child: _buildToast(type)),
        ),
      ),
    );
  }

  Widget _buildToast(_SnackType type) {
    return GestureDetector(
      onTap: _dismiss,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Dark pill card ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xFF18181B),
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: type.accent.withOpacity(0.32),
                  blurRadius: 30,
                  spreadRadius: -4,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Icon with glowing ring ──
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: type.accent.withOpacity(0.15),
                    border: Border.all(
                      color: type.accent.withOpacity(0.55),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: type.accent.withOpacity(0.45),
                        blurRadius: 14,
                        spreadRadius: -3,
                      ),
                    ],
                  ),
                  child: Icon(type.icon, color: type.accent, size: 18),
                ),
                const SizedBox(width: 10),
                // ── Text ──
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title.isNotEmpty ? widget.title : type.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (widget.message.isNotEmpty) ...[
                        const SizedBox(height: 1),
                        Text(
                          widget.message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.5),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // ── X dismiss chip ──
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 13,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 7),
          // ── Gradient progress line ──
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              final remaining = (1.0 - _controller.value).clamp(0.0, 1.0);
              return ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: SizedBox(
                  height: 2.5,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(color: type.accent.withOpacity(0.15)),
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _controller.isCompleted ? 0.0 : remaining,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                type.accent,
                                type.accent.withOpacity(0.45),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  } // end _buildToast
} // end _SnackbarWidgetState
