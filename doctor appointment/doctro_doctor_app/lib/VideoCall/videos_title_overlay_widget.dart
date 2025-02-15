import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants.dart';
import 'overlay_handler.dart';

class VideoTitleOverlayWidget extends StatefulWidget {
  final Function onClear;
  final Widget widget;

  VideoTitleOverlayWidget({required this.onClear, required this.widget});

  @override
  _VideoTitleOverlayWidgetState createState() => _VideoTitleOverlayWidgetState();
}

class _VideoTitleOverlayWidgetState extends State<VideoTitleOverlayWidget> {
  late double width;
  late double oldWidth;
  late double oldHeight;
  late double height;

  bool isInPipMode = false;

  Offset offset = Offset(0, 0);

  late Widget player;

  _onExitPipMode() {
    Future.microtask(() {
      setState(() {
        isInPipMode = false;
        width = oldWidth;
        height = oldHeight;
        offset = Offset(0, 0);
      });
    });
    Future.delayed(const Duration(milliseconds: 250), () {
      Provider.of<OverlayHandlerProvider>(context, listen: false).disablePip();
    });
  }

  _onPipMode() {
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        isInPipMode = true;
        width = oldWidth - 32.0;
        height = Constants.VIDEO_TITLE_HEIGHT_PIP;
        print(oldHeight - height - Constants.BOTTOM_PADDING_PIP);
        offset = Offset(16, oldHeight - height - Constants.BOTTOM_PADDING_PIP);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    oldWidth = width = MediaQuery.of(context).size.width;
    oldHeight = height = MediaQuery.of(context).size.height;
    return Consumer<OverlayHandlerProvider>(builder: (context, overlayProvider, _) {
      if (overlayProvider.inPipMode != isInPipMode) {
        isInPipMode = overlayProvider.inPipMode;
        if (isInPipMode)
          _onPipMode();
        else
          _onExitPipMode();
      }
      return AnimatedPositioned(
        duration: Duration(milliseconds: 150),
        left: offset.dx,
        top: offset.dy,
        child: Material(
          elevation: isInPipMode ? 5.0 : 0.0,
          child: AnimatedContainer(
            height: height,
            width: width,
            child: widget.widget,
            duration: Duration(milliseconds: 250),
          ),
        ),
      );
    });
  }
}
