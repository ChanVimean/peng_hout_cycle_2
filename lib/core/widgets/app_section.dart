import 'package:flutter/material.dart';

class AppSection extends StatelessWidget {
  final List<Widget> children;
  final String? header;
  final bool? centerSubHeader;
  final double spacing;
  final double paddingAll;
  final double marginHorizontal;

  const AppSection({
    super.key,
    required this.children,
    this.header,
    this.centerSubHeader = false,
    this.spacing = 4.0,
    this.paddingAll = 6,
    this.marginHorizontal = 16,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: marginHorizontal),
          padding: EdgeInsets.all(paddingAll),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),

            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: theme.colorScheme.onSurface.withAlpha(10),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            spacing: spacing,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (header != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Text(
                    header!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              if (header != null) const SizedBox(height: 6),
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1)
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: theme.colorScheme.onSurface.withAlpha(10),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
