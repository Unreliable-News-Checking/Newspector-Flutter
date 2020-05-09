import 'dart:typed_data';
import 'package:http/http.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_source.dart';
import 'package:newspector_flutter/application_constants.dart' as app_const;

class NewsSourcePhotoContainer extends StatefulWidget {
  final double radius;
  final NewsSource newsSource;

  const NewsSourcePhotoContainer({
    @required this.radius,
    @required this.newsSource,
  });
  @override
  _NewsSourcePhotoContainerState createState() =>
      _NewsSourcePhotoContainerState();
}

class _NewsSourcePhotoContainerState extends State<NewsSourcePhotoContainer> {
  Uint8List photoInBytes;
  @override
  Widget build(BuildContext context) {
    // No profile photo
    if (widget.newsSource.photoUrl == "") {
      return _getDefaultPhoto(widget.radius);
    }

    // There is a cached image
    if (widget.newsSource.photoInBytes != null) {
      photoInBytes = widget.newsSource.photoInBytes;
      return _getUserPhoto(photoInBytes, widget.radius);
    }

    // regular profile photo
    return FutureBuilder(
      future: fetchImage(widget.newsSource.photoUrl),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            photoInBytes = snapshot.data;
            storeCachedImage(widget.newsSource, photoInBytes);
            return _getUserPhoto(photoInBytes, widget.radius);
            break;
          default:
            return _getLoadingPhoto(widget.radius);
        }
      },
    );
  }

  Future<Uint8List> fetchImage(String photoUrl) async {
    Response response = await get(photoUrl);
    return response.bodyBytes;
  }

  void storeCachedImage(NewsSource user, Uint8List _photoInBytes) {
    user.photoInBytes = _photoInBytes;
  }

  Widget _getDefaultPhoto(double radius) {
    return Container(
      height: radius,
      width: radius,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.person,
        color: Colors.blue,
      ),
    );
  }

  Widget _getUserPhoto(Uint8List _photoInBytes, double radius) {
    return Container(
      height: radius,
      width: radius,
      // color: app_const.backgroundColor,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(_photoInBytes),
      ),
    );
  }

  Widget _getLoadingPhoto(double radius) {
    return Container(
      height: radius,
      width: radius,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
