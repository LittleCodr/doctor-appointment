import 'package:doctro/VideoCall/overlay_handler.dart';
import 'package:doctro/VideoCall/videos_overlay_widget.dart';
import 'package:doctro/VideoCall/videos_title_overlay_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OverlayService {
  addVideosOverlay(BuildContext context, Widget widget) {
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => VideoOverlayWidget(
        onClear: () {
          Provider.of<OverlayHandlerProvider>(context, listen: false).removeOverlay(context);
        },
        widget: widget,
      ),
    );

    Provider.of<OverlayHandlerProvider>(context, listen: false).insertOverlay(context, overlayEntry);
  }

  addVideoTitleOverlay(BuildContext context, Widget widget) {
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => VideoTitleOverlayWidget(
        onClear: () {
          Provider.of<OverlayHandlerProvider>(context, listen: false).removeOverlay(context);
        },
        widget: widget,
      ),
    );

    Provider.of<OverlayHandlerProvider>(context, listen: false).insertOverlay(context, overlayEntry);
  }

  removeVideosOverlay(BuildContext context, Widget widget) {
    Provider.of<OverlayHandlerProvider>(context, listen: false).removeOverlay(context);
  }
}
