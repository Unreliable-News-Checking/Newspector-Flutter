import 'dart:typed_data';
import 'package:http/http.dart';
import 'package:flutter/material.dart';

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
      return getDefaultPhoto(
        height,
        width,
        borderRadius,
      );
    }

    if (getPhotoInBytes() != null) {
      return getPhoto(
        getPhotoInBytes(),
        false,
        animationController,
        shadow,
        height,
        width,
        borderRadius,
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
              photoInBytes,
              true,
              animationController,
              shadow,
              height,
              width,
              borderRadius,
            );
            break;
          default:
            return getLoadingPhoto(
              height,
              width,
              borderRadius,
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
    Uint8List _photoInBytes,
    bool doFade,
    AnimationController animationController,
    bool shadow,
    double height,
    double width,
    double borderRadius,
  ) {
    Widget image = Image.memory(_photoInBytes);
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

  Widget getLoadingPhoto(
    double height,
    double width,
    double borderRadius,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        height: height,
        width: width,
        color: Colors.grey.shade800,
      ),
    );
  }

  Widget getDefaultPhoto(
    double height,
    double width,
    double borderRadius,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        height: height,
        width: width,
        color: Color(0xFF3484F0),
      ),
    );
  }
}
