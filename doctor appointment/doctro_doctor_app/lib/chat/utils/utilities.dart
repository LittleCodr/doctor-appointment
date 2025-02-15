import 'package:flutter/material.dart';

class Utilities {
  static bool isKeyboardShowing() {
    // ignore: unnecessary_null_comparison
    if (WidgetsBinding.instance != null) {
      // ignore: deprecated_member_use
      return WidgetsBinding.instance.window.viewInsets.bottom > 0;
    } else {
      return false;
    }
  }

  static closeKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }
}
