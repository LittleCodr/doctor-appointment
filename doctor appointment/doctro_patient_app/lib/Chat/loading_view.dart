import 'package:doctro_patient/const/Palette.dart';
import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: CircularProgressIndicator(
          color: Palette.blue,
        ),
      ),
      color: Colors.white.withOpacity(0.8),
    );
  }
}
