import 'dart:typed_data';
import 'package:http/http.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_source.dart';

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

class _NewsSourcePhotoContainerState extends State<NewsSourcePhotoContainer>
    with SingleTickerProviderStateMixin {
  Uint8List photoInBytes;
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    Tween(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // No profile photo
    if (widget.newsSource.photoUrl == null) {
      return _getDefaultPhoto(widget.radius);
    }

    // There is a cached image
    if (widget.newsSource.photoInBytes != null) {
      photoInBytes = widget.newsSource.photoInBytes;
      return _getUserPhoto(photoInBytes, false);
    }

    // regular profile photo
    return FutureBuilder(
      future: fetchImage(widget.newsSource.photoUrl),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            photoInBytes = snapshot.data;
            storeCachedImage(widget.newsSource, photoInBytes);
            return _getUserPhoto(photoInBytes, true);
            break;
          default:
            return _getLoadingPhoto();
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

  Widget _getLoadingPhoto() {
    return Container(
      height: widget.radius,
      width: widget.radius,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _getUserPhoto(Uint8List _photoInBytes, bool doFade) {
    Widget image = Image.memory(_photoInBytes);
    Widget imageContainer = image;

    if (doFade) {
      imageContainer = FadeTransition(
        child: image,
        opacity: _animationController,
      );
      _animationController.forward();
    }

    return Container(
      height: widget.radius,
      width: widget.radius,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: imageContainer,
      ),
    );
  }
}
