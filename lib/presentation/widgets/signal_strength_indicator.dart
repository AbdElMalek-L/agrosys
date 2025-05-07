import 'package:flutter/material.dart';

class SignalStrengthIndicator extends StatelessWidget {
  final int signalStrength;

  const SignalStrengthIndicator({
    super.key,
    required this.signalStrength,
  });

  Color _getSignalColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (signalStrength >= 21) {
      return isDark ? Colors.green[300]! : Colors.green[700]!;
    } else if (signalStrength >= 13) {
      return isDark ? Colors.lightGreen[300]! : Colors.lightGreen[700]!;
    } else if (signalStrength >= 10) {
      return isDark ? Colors.orange[300]! : Colors.orange[700]!;
    } else {
      return isDark ? Colors.red[300]! : Colors.red[700]!;
    }
  }

  Widget _buildSignalBars(BuildContext context) {
    final color = _getSignalColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        final isActive = (signalStrength >= 21 && index < 4) ||
            (signalStrength >= 13 && index < 3) ||
            (signalStrength >= 10 && index < 2) ||
            (signalStrength >= 0 && index < 1);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 1),
          width: 3,
          height: 4 + (index * 2),
          decoration: BoxDecoration(
            color: isActive ? color : barColor,
            borderRadius: BorderRadius.circular(1.5),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _getSignalColor(context);
    
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey<int>(signalStrength),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSignalBars(context),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$signalStrength',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 