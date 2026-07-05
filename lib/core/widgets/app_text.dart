// dart format off

import 'package:flutter/material.dart';
import 'package:peng_houth_cycle/core/const/constant.dart';

enum TextVariant { h1, h2, h3, big, body, small }

// (size, weight, height) — height tightens headings, loosens body
const Map<TextVariant, (double, FontWeight, double)> _variantStyles = {
  TextVariant.h1:    (AppFontSizes.fontSize3XL, AppFontWeights.fontWeightBold,     1.2),
  TextVariant.h2:    (AppFontSizes.fontSize2XL, AppFontWeights.fontWeightBold,     1.25),
  TextVariant.h3:    (AppFontSizes.fontSizeXL,  AppFontWeights.fontWeightSemiBold, 1.3),
  TextVariant.big:   (AppFontSizes.fontSizeLG,  AppFontWeights.fontWeightRegular,  1.4),
  TextVariant.body:  (AppFontSizes.fontSizeMD,  AppFontWeights.fontWeightRegular,  1.5),
  TextVariant.small: (AppFontSizes.fontSizeSM,  AppFontWeights.fontWeightRegular,  1.4),
};

class AppText extends StatelessWidget {
  final String text;
  final TextVariant variant;      // non-null, defaults to body
  final FontWeight? fontWeight;   // override
  final Color? color;             // override
  final int maxLines;
  final TextOverflow overflow;
  final TextAlign? textAlign;
  final bool isItalic;

  const AppText(
    this.text, {                  // 'text' must be first, positional
    super.key,
    this.variant = TextVariant.body,
    this.fontWeight,
    this.color,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign,
    this.isItalic = false,
  });

  // Named constructors — call sites read as intent
  const AppText.h1(this.text, {super.key, this.color, this.fontWeight,
    this.maxLines = 2, this.overflow = TextOverflow.ellipsis, this.textAlign,
    this.isItalic = false}) : variant = TextVariant.h1;

  const AppText.h2(this.text, {super.key, this.color, this.fontWeight,
    this.maxLines = 2, this.overflow = TextOverflow.ellipsis, this.textAlign,
    this.isItalic = false}) : variant = TextVariant.h2;

  const AppText.body(this.text, {super.key, this.color, this.fontWeight,
    this.maxLines = 1, this.overflow = TextOverflow.ellipsis, this.textAlign,
    this.isItalic = false}) : variant = TextVariant.body;

  const AppText.small(this.text, {super.key, this.color, this.fontWeight,
    this.maxLines = 1, this.overflow = TextOverflow.ellipsis, this.textAlign,
    this.isItalic = false}) : variant = TextVariant.small;

  @override
  Widget build(BuildContext context) {
    final (size, weight, height) = _variantStyles[variant]!;

    return Text(
      text,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: size,
        height: height,
        fontWeight: fontWeight ?? weight,
        color: color ?? AppColors.textPrimaryColor,
        fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
      ),
    );
  }
}