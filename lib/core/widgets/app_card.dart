import 'package:flutter/material.dart';
import 'package:peng_houth_cycle/core/const/constant.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double? padding;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    this.color,
    this.padding = 8,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Material(
      color: color ?? theme.colorScheme.surface,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.radiusXL)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(
          Radius.circular(AppRadius.radiusXL),
        ),
        child: Padding(
          padding: padding != null
              ? EdgeInsets.all(padding!)
              : const EdgeInsets.all(12.0),
          child: child,
        ),
      ),
    );
  }
}
