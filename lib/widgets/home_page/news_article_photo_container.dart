import 'dart:typed_data';
import 'package:http/http.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_article.dart';

class NewsArticlePhotoContainer extends StatefulWidget {
  final NewsArticle newsArticle;
  final double height;

  const NewsArticlePhotoContainer({
    @required this.newsArticle,
    @required this.height,
  });
  @override
  _NewsArticlePhotoContainerState createState() =>
      _NewsArticlePhotoContainerState();
}

class _NewsArticlePhotoContainerState extends State<NewsArticlePhotoContainer> {
  Uint8List photoInBytes;
  @override
  Widget build(BuildContext context) {
    // No profile photo
    if (widget.newsArticle.photoUrl == null) {
      return _getDefaultPhoto();
    }

    // There is a cached image
    if (widget.newsArticle.photoInBytes != null) {
      photoInBytes = widget.newsArticle.photoInBytes;
      return _getNewsArticlePhoto(photoInBytes);
    }

    // regular profile photo
    return FutureBuilder(
      future: fetchImage(widget.newsArticle.photoUrl),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            photoInBytes = snapshot.data;
            storeCachedImage(widget.newsArticle, photoInBytes);
            return _getNewsArticlePhoto(photoInBytes);
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

  Widget _getNewsArticlePhoto(Uint8List _photoInBytes) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: widget.height,
        width: double.infinity,
        child: FittedBox(
          child: Image.memory(_photoInBytes),
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  Widget _getLoadingPhoto() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: widget.height,
        width: double.infinity,
        color: Colors.grey.shade800,
      ),
    );
  }
}
