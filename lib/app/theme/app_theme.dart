import 'package:flutter/material.dart';

import 'tokens.dart';
import 'typography.dart';

/// Material 3 위에 tokens.md를 얹은 단일 테마. 그림자 없음, 선으로 구분.
ThemeData buildAppTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.ink,
    onPrimary: AppColors.bg,
    secondary: AppColors.done,
    onSecondary: AppColors.bg,
    error: AppColors.danger,
    onError: AppColors.bg,
    surface: AppColors.bg,
    onSurface: AppColors.ink,
    onSurfaceVariant: AppColors.inkSub,
    surfaceContainerHighest: AppColors.surface,
    outline: AppColors.lineStrong,
    outlineVariant: AppColors.line,
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: AppFonts.sans,
    scaffoldBackgroundColor: AppColors.bg,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
  );

  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      headlineSmall: AppText.screenTitle,
      titleMedium: AppText.appBarTitle,
      bodyLarge: AppText.body,
      bodyMedium: AppText.body,
      bodySmall: AppText.caption,
      labelLarge: AppText.button,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppText.appBarTitle,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.line,
      thickness: AppSizes.hairline,
      space: AppSizes.hairline,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.cardRadius),
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      titleTextStyle: AppText.cardTitle,
      contentTextStyle: AppText.body,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bg,
      hintStyle: AppText.body.copyWith(color: AppColors.inkMute),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      constraints: const BoxConstraints(minHeight: AppSizes.inputHeight),
      border: _inputBorder(AppColors.ink),
      enabledBorder: _inputBorder(AppColors.ink),
      focusedBorder: _inputBorder(AppColors.ink),
      errorBorder: _inputBorder(AppColors.danger),
      focusedErrorBorder: _inputBorder(AppColors.danger),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.ink,
      contentTextStyle: AppText.body.copyWith(color: AppColors.bg),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
    ),
    // 켜짐 = ink. done(그린)은 챙김 상태에만 쓰므로 스위치에 쓰지 않는다.
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(AppColors.bg),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.ink
            : AppColors.lineStrong,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.done,
      linearTrackColor: AppColors.line,
    ),
  );
}

OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(AppSizes.inputRadius),
  borderSide: BorderSide(color: color, width: AppSizes.border),
);
