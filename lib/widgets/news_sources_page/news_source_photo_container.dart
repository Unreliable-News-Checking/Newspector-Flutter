import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_source.dart';
import 'package:newspector_flutter/widgets/photo_container.dart';
import 'package:newspector_flutter/application_constants.dart' as app_const;

class NewsSourcePhotoContainer extends StatefulWidget {
  final double size;
  final NewsSource newsSource;
  final double borderRadius;

  const NewsSourcePhotoContainer({
    @required this.size,
    @required this.newsSource,
    @required this.borderRadius,
  });
  @override
  _NewsSourcePhotoContainerState createState() =>
      _NewsSourcePhotoContainerState();
}

class _NewsSourcePhotoContainerState extends State<NewsSourcePhotoContainer>
    with SingleTickerProviderStateMixin, PhotoContainer {
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
  Widget build(BuildContext context) {
    return buildPhotoContainer(
      animationController: _animationController,
      height: widget.size,
      width: widget.size,
      borderRadius: widget.borderRadius,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Uint8List getPhotoInBytes() {
    return widget.newsSource.photoInBytes;
  }

  @override
  String getPhotoUrl() {
    return widget.newsSource.photoUrl;
  }

  @override
  void storeCachedImage(Uint8List photoInBytes) {
    widget.newsSource.photoInBytes = photoInBytes;
  }

  @override
  Widget getDefaultPhotoImage() {
    return Container(
      color: app_const.activeColor, //Color(0xFF3484F0),
    );
  }
}
