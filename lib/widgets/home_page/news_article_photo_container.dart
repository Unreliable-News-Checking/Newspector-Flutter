import 'dart:typed_data';
import 'package:http/http.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_article.dart';

class NewsArticlePhotoContainer extends StatefulWidget {
  final NewsArticle newsArticle;

  const NewsArticlePhotoContainer({
    @required this.newsArticle,
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
    if (widget.newsArticle.photoUrl == "") {
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
    return null;
  }

  Widget _getNewsArticlePhoto(Uint8List _photoInBytes) {
    return Image.memory(_photoInBytes);
  }

  Widget _getLoadingPhoto() {
    return null;
  }
}
