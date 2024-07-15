/*
 * Author     : Mochamad Firgia
 * Website    : https://www.firgia.com
 * Repository : https://github.com/firgia/soca
 * 
 * Created on Thu Jan 26 2023
 * Copyright (c) 2023 Mochamad Firgia
 */

import 'package:flutter/material.dart';
import '../../../config/config.dart';
import '../../../core/core.dart';

class OutlinedButtonStyle extends ButtonStyle {
  static Color defaultPrimary = AppColors.lightBlue;

  OutlinedButtonStyle({
    Color? color,
    BorderRadius? borderRadius,
    ButtonSize size = ButtonSize.medium,
    TextStyle? textStyle,
    bool expanded = false,
  }) : super(
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) =>
                states.any((element) => element == WidgetState.disabled)
                    ? AppColors.disableButtonForeground
                    : color ?? defaultPrimary,
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius:
                  borderRadius ?? BorderRadius.circular(kBorderRadius),
            ),
          ),
          side: WidgetStateProperty.resolveWith(
            (states) => BorderSide(
              color: states.any((element) => element == WidgetState.disabled)
                  ? AppColors.disableButtonForeground.withOpacity(.4)
                  : color ?? defaultPrimary,
            ),
          ),
          overlayColor: WidgetStateProperty.all(
            color?.withOpacity(.2) ?? defaultPrimary.withOpacity(.2),
          ),
          textStyle: WidgetStateProperty.all(
            textStyle?.copyWith(
                  fontSize: (size == ButtonSize.small)
                      ? 12
                      : (size == ButtonSize.medium)
                          ? 15
                          : 18,
                  fontFamily: AppFont.poppins,
                ) ??
                TextStyle(
                  fontSize: (size == ButtonSize.small)
                      ? 12
                      : (size == ButtonSize.medium)
                          ? 15
                          : 18,
                  fontWeight: (size == ButtonSize.large)
                      ? FontWeight.w700
                      : FontWeight.w600,
                  letterSpacing: .2,
                  fontFamily: AppFont.poppins,
                ),
          ),
          minimumSize: WidgetStateProperty.all(
            (size == ButtonSize.small)
                ? Size(expanded ? double.infinity : 60, 20)
                : (size == ButtonSize.medium)
                    ? Size(expanded ? double.infinity : 80, 35)
                    : Size(expanded ? double.infinity : 100, 60),
          ),
          padding: WidgetStateProperty.all(
            (size == ButtonSize.small)
                ? const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  )
                : (size == ButtonSize.medium)
                    ? const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 14,
                      )
                    : const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
}

class FlatButtonStyle extends _SolidButtonStyle {
  FlatButtonStyle({
    Color? primary,
    Color? onPrimary,
    BorderRadius? borderRadius,
    ButtonSize size = ButtonSize.medium,
    TextStyle? textStyle,
    bool expanded = false,
  }) : super(
          useElevation: false,
          primary: primary,
          onPrimary: onPrimary,
          borderRadius: borderRadius,
          size: size,
          textStyle: textStyle,
          expanded: expanded,
        );
}

class RaisedButtonStyle extends _SolidButtonStyle {
  RaisedButtonStyle({
    Color? primary,
    Color? onPrimary,
    BorderRadius? borderRadius,
    ButtonSize size = ButtonSize.medium,
    TextStyle? textStyle,
    bool expanded = false,
  }) : super(
          useElevation: true,
          primary: primary,
          onPrimary: onPrimary,
          borderRadius: borderRadius,
          size: size,
          textStyle: textStyle,
          expanded: expanded,
        );
}

class _SolidButtonStyle extends ButtonStyle {
  static const Color _onPrimaryColor = Colors.white;
  static Color defaultPrimary = AppColors.lightBlue;

  _SolidButtonStyle({
    Color? primary,
    Color? onPrimary,
    BorderRadius? borderRadius,
    ButtonSize size = ButtonSize.medium,
    TextStyle? textStyle,
    required bool expanded,
    required bool useElevation,
  }) : super(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) =>
                states.any((element) => element == WidgetState.disabled)
                    ? AppColors.disableButtonBackground
                    : primary ?? defaultPrimary,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) =>
                states.any((element) => element == WidgetState.disabled)
                    ? AppColors.disableButtonForeground
                    : onPrimary ?? _onPrimaryColor,
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius:
                  borderRadius ?? BorderRadius.circular(kBorderRadius),
            ),
          ),
          overlayColor: WidgetStateProperty.all(
            onPrimary?.withOpacity(.2) ?? _onPrimaryColor.withOpacity(.2),
          ),
          textStyle: WidgetStateProperty.all(
            textStyle?.copyWith(
                  fontSize: (size == ButtonSize.small)
                      ? 12
                      : (size == ButtonSize.medium)
                          ? 15
                          : 18,
                  fontFamily: AppFont.poppins,
                ) ??
                TextStyle(
                  fontSize: (size == ButtonSize.small)
                      ? 12
                      : (size == ButtonSize.medium)
                          ? 15
                          : 18,
                  fontWeight: (size == ButtonSize.large)
                      ? FontWeight.w700
                      : FontWeight.w600,
                  letterSpacing: .2,
                  fontFamily: AppFont.poppins,
                ),
          ),
          minimumSize: WidgetStateProperty.all(
            (size == ButtonSize.small)
                ? Size(expanded ? double.infinity : 60, 20)
                : (size == ButtonSize.medium)
                    ? Size(expanded ? double.infinity : 80, 35)
                    : Size(expanded ? double.infinity : 100, 60),
          ),
          padding: WidgetStateProperty.all(
            (size == ButtonSize.small)
                ? const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  )
                : (size == ButtonSize.medium)
                    ? const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 14,
                      )
                    : const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          elevation: !useElevation
              ? null
              : WidgetStateProperty.resolveWith((states) =>
                  states.any((element) => element == WidgetState.pressed)
                      ? (size == ButtonSize.small)
                          ? 5
                          : (size == ButtonSize.medium)
                              ? 8
                              : 10
                      : 0),
        );
}
