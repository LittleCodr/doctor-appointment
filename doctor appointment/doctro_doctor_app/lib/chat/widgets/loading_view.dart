import 'package:flutter/material.dart';

import '../constants/colors.dart';

class LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Center(
        child: CircularProgressIndicator(
          color: ColorConstants.themeColor,
        ),
      ),
      color: Colors.white.withOpacity(0.8),
    );
  }
}
