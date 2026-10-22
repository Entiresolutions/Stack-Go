import 'package:flutter/material.dart';

class PremiumButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool isPrimary;
  final Color? customAccent;
  final double height;

  const PremiumButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.isPrimary = false,
    this.customAccent,
    this.height = 54.0,
  });

  @override
  Widget build(BuildContext context) {
    final accent = customAccent ??
        (isPrimary ? const Color(0xFF55DDFB) : const Color(0xFF1D2940));
    final textColor =
        isPrimary ? const Color(0xFF0B1020) : const Color(0xFFF7FAFF);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor:
            (isPrimary ? Colors.white : Colors.blue).withValues(alpha: 0.2),
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(16),
            border: isPrimary
                ? null
                : Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1.0,
                  ),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: textColor, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
