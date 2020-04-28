import 'dart:typed_data';
import 'package:http/http.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_article.dart';

class HpNewsArticlePhotoContainer extends StatefulWidget {
  final NewsArticle newsArticle;
  final double height;
  final double borderRadius;

  const HpNewsArticlePhotoContainer({
    @required this.newsArticle,
    @required this.height,
    @required this.borderRadius,
  });
  @override
  _HpNewsArticlePhotoContainerState createState() =>
      _HpNewsArticlePhotoContainerState();
}

class _HpNewsArticlePhotoContainerState
    extends State<HpNewsArticlePhotoContainer>
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
    if (widget.newsArticle.photoUrl == null) {
      return _getDefaultPhoto();
    }

    // There is a cached image
    if (widget.newsArticle.photoInBytes != null) {
      photoInBytes = widget.newsArticle.photoInBytes;
      return _getNewsArticlePhoto(photoInBytes, false);
    }

    // regular profile photo
    return FutureBuilder(
      future: fetchImage(widget.newsArticle.photoUrl),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            photoInBytes = snapshot.data;
            storeCachedImage(widget.newsArticle, photoInBytes);
            return _getNewsArticlePhoto(photoInBytes, true);
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

  void storeCachedImage(NewsArticle newsArticle, Uint8List _photoInBytes) {
    newsArticle.photoInBytes = _photoInBytes;
  }

  Widget _getDefaultPhoto() {
    return _getLoadingPhoto();
  }

  Widget _getNewsArticlePhoto(Uint8List _photoInBytes, bool doFade) {
    Widget image = Image.memory(_photoInBytes);
    Widget imageContainer = image;

    if (doFade) {
      imageContainer = FadeTransition(
        child: image,
        opacity: _animationController,
      );
      _animationController.forward();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Stack(
        children: <Widget>[
          Container(
            height: widget.height,
            width: double.infinity,
            color: Colors.grey.shade800,
            child: FittedBox(
              child: imageContainer,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Container(
              height: widget.height - 50,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                gradient: LinearGradient(
                  colors: [Color.fromRGBO(0, 0, 0, 0.8), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getLoadingPhoto() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Container(
        height: widget.height,
        width: double.infinity,
        color: Colors.grey.shade800,
      ),
    );
  }
}
