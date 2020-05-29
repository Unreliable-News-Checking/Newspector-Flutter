import 'dart:typed_data';
import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/application_constants.dart' as app_const;

mixin PhotoContainer {
  void storeCachedImage(Uint8List photoInBytes);
  String getPhotoUrl();
  Uint8List getPhotoInBytes();

  Widget buildPhotoContainer({
    @required AnimationController animationController,
    @required double height,
    @required double width,
    @required double borderRadius,
    bool shadow = false,
  }) {
    if (getPhotoUrl() == null) {
      return getPhoto(
        height,
        width,
        borderRadius,
        PhotoType.Default,
        shadow: shadow,
      );
    }

    if (getPhotoInBytes() != null) {
      return getPhoto(
        height,
        width,
        borderRadius,
        PhotoType.Actual,
        photoInBytes: getPhotoInBytes(),
        animationController: animationController,
        shadow: shadow,
      );
    }

    // regular profile photo
    return FutureBuilder(
      future: fetchImage(getPhotoUrl()),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            var photoInBytes = snapshot.data;
            storeCachedImage(photoInBytes);
            return getPhoto(
              height,
              width,
              borderRadius,
              PhotoType.Actual,
              photoInBytes: photoInBytes,
              doFade: true,
              animationController: animationController,
              shadow: shadow,
            );
            break;
          default:
            return getPhoto(
              height,
              width,
              borderRadius,
              PhotoType.Loading,
            );
        }
      },
    );
  }

  Future<Uint8List> fetchImage(String photoUrl) async {
    try {
      Response response = await get(photoUrl);
      return response.bodyBytes;
    } catch (e) {
      return null;
    }
  }

  Widget getPhoto(
    double height,
    double width,
    double borderRadius,
    PhotoType photoType, {
    bool doFade = false,
    bool shadow = false,
    Uint8List photoInBytes,
    AnimationController animationController,
  }) {
    Widget image;
    if (photoType == PhotoType.Actual) {
      image = Image.memory(photoInBytes);
    } else if (photoType == PhotoType.Loading) {
      image = Container(color: app_const.inactiveColor);
    } else if (photoType == PhotoType.Default) {
      image = getDefaultPhotoImage();
    }

    Widget imageContainer = image;
    Widget shadowContainer = Container();

    if (shadow) {
      shadowContainer = Image.asset(
        'assets/shadow.png',
        repeat: ImageRepeat.repeatX,
      );
    }

    Widget finalImageContainer = Container(
      height: height,
      width: width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: <Widget>[
            SizedBox.expand(
              child: FittedBox(
                child: imageContainer,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox.expand(
              child: FittedBox(
                child: shadowContainer,
                fit: BoxFit.fitHeight,
              ),
            ),
          ],
        ),
      ),
    );

    if (doFade) {
      finalImageContainer = FadeTransition(
        child: finalImageContainer,
        opacity: animationController,
      );
      animationController.forward();
    }

    return finalImageContainer;
  }

  Widget getDefaultPhotoImage();
}

enum PhotoType {
  Loading,
  Default,
  Actual,
}
