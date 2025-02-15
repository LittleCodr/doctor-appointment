import 'package:doctro/chat/constants/colors.dart';
import 'package:doctro/constant/app_string.dart';
import 'package:doctro/localization/localization_constant.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullPhotoPage extends StatelessWidget {
  final String url;

  FullPhotoPage({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstants.greyColor2,
        elevation: 0,
        title: Text(
          getTranslated(context, AppString.full_photo).toString(),
          style: TextStyle(color: ColorConstants.primaryColor),
        ),
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: ColorConstants.black,
          ),
        ),
      ),
      body: PhotoView(
        imageProvider: NetworkImage(url),
      ),
    );
  }
}
