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

    if (doFade) {
      imageContainer = FadeTransition(
        child: image,
        opacity: animationController,
      );
      animationController.forward();
    }

    if (shadow) {
      shadowContainer = Container(
        height: height - 50,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: LinearGradient(
            colors: [Color.fromRGBO(0, 0, 0, 0.8), Colors.transparent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
      );
    }

    return Container(
      height: height,
      width: width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Container(
              height: height,
              width: width,
              child: FittedBox(
                child: imageContainer,
                fit: BoxFit.cover,
              ),
            ),
            shadowContainer,
          ],
        ),
      ),
    );
  }

  // Widget getLoadingPhoto(
  //   double height,
  //   double width,
  //   double borderRadius,
  // ) {
  //   return ClipRRect(
  //     borderRadius: BorderRadius.circular(borderRadius),
  //     child: Container(
  //       height: height,
  //       width: width,
  //       color: app_const.inactiveColor,
  //     ),
  //   );
  // }

  // Widget getDefaultPhoto(
  //   double height,
  //   double width,
  //   double borderRadius,
  // ) {
  //   return ClipRRect(
  //     borderRadius: BorderRadius.circular(borderRadius),
  //     child: Container(
  //       height: height,
  //       width: width,
  //       child: getDefaultPhotoImage(),
  //     ),
  //   );
  // }

  Widget getDefaultPhotoImage();
}

enum PhotoType {
  Loading,
  Default,
  Actual,
}
