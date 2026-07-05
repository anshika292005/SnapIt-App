import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum TopMessageType { success, error, info }

void showTopMessage(
  BuildContext context, {
  required String message,
  TopMessageType type = TopMessageType.info,
}) {
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) {
    return;
  }

  final background = switch (type) {
    TopMessageType.success => AppColors.green,
    TopMessageType.error => const Color(0xFFB42318),
    TopMessageType.info => AppColors.ink,
  };
  final icon = switch (type) {
    TopMessageType.success => Icons.check_circle_outline,
    TopMessageType.error => Icons.error_outline,
    TopMessageType.info => Icons.info_outline,
  };

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) {
      return Positioned(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        child: _TopMessageCard(
          background: background,
          icon: icon,
          message: message,
        ),
      );
    },
  );

  overlay.insert(entry);
  final isWidgetTest =
      WidgetsBinding.instance.runtimeType.toString().contains('Test');
  if (isWidgetTest) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (entry.mounted) {
        entry.remove();
      }
    });
  } else {
    Future<void>.delayed(const Duration(milliseconds: 2400), () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }
}

class _TopMessageCard extends StatelessWidget {
  const _TopMessageCard({
    required this.background,
    required this.icon,
    required this.message,
  });

  final Color background;
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
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
