import 'package:flutter/material.dart';
import 'package:peng_houth_cycle/core/const/constant.dart';

enum TextVariant { h1, h2, h3, body, small, big }

const Map<TextVariant, (double size, FontWeight weight)> _variantStyles = {
  TextVariant.h1: (AppFontSizes.fontSize3XL, AppFontWeights.fontWeightBold),
  TextVariant.h2: (AppFontSizes.fontSize2XL, AppFontWeights.fontWeightBold),
  TextVariant.h3: (AppFontSizes.fontSizeXL, AppFontWeights.fontWeightSemiBold),
  TextVariant.big: (AppFontSizes.fontSizeLG, AppFontWeights.fontWeightRegular),
  TextVariant.body: (AppFontSizes.fontSizeMD, AppFontWeights.fontWeightRegular),
  TextVariant.small: (
    AppFontSizes.fontSizeSM,
    AppFontWeights.fontWeightRegular,
  ),
};

class CustomText extends StatelessWidget {
  final String text;
  final TextVariant? variant;
  final FontWeight? fontWeight; // Allow Override
  final Color? color;
  final int maxLine;
  final TextOverflow textOverflow;
  final TextAlign? textAlign;
  final bool isSubtitle;
  final bool isItalic;

  const CustomText(
    // 'Text' must be first argument
    this.text, {
    super.key,
    required this.variant,
    this.fontWeight,
    this.color,
    this.maxLine = 1,
    this.textOverflow = TextOverflow.ellipsis,
    this.textAlign = TextAlign.start,
    this.isSubtitle = false,
    this.isItalic = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (size, weight) =
        _variantStyles[variant] ??
        (AppFontSizes.fontSizeMD, AppFontWeights.fontWeightRegular);

    final Color textColor =
        color ?? (isSubtitle ? Colors.grey : theme.colorScheme.onSurface);

    final FontWeight textWeight =
        fontWeight ?? (isSubtitle ? AppFontWeights.fontWeightRegular : weight);

    final FontStyle italic = isItalic ? FontStyle.italic : FontStyle.normal;

    return Text(
      text,
      maxLines: maxLine,
      overflow: textOverflow,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: size,
        fontWeight: textWeight,
        color: textColor,
        fontStyle: italic,
      ),
    );
  }
}
