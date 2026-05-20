// Ficheiro: lib/core/utils/ui_utils.dart
import 'package:flutter/material.dart';

/// Centralized utility class for reusable UI feedback components.
/// Enforces the DRY principle across the application for standard notifications.
class UiUtils {
  /// Displays a standardized Optimistic UI SnackBar with an 'Undo' action.
  /// Used to mask latency and provide instant perceived feedback while allowing error recovery.
  /// 
  /// @param {BuildContext} context - The active build context.
  /// @param {String} message - The main feedback message to display.
  /// @param {VoidCallback} onUndo - The callback function executed if the user reverses the action.
  static void showUndoToast(BuildContext context, String message, VoidCallback onUndo) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'DESFAZER',
          textColor: theme.colorScheme.primary,
          onPressed: onUndo,
        ),
      ),
    );
  }
}