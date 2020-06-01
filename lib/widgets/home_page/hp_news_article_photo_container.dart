import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/news_article.dart';
import 'package:newspector_flutter/services/news_group_service.dart';
import 'package:newspector_flutter/widgets/photo_container.dart';

class HpNewsArticlePhotoContainer extends StatefulWidget {
  final NewsArticle newsArticle;
  final double width;
  final double height;
  final double borderRadius;
  final bool shadow;

  const HpNewsArticlePhotoContainer({
    @required this.newsArticle,
    @required this.width,
    @required this.height,
    @required this.borderRadius,
    @required this.shadow,
  });
  @override
  _HpNewsArticlePhotoContainerState createState() =>
      _HpNewsArticlePhotoContainerState();
}

class _HpNewsArticlePhotoContainerState
    extends State<HpNewsArticlePhotoContainer>
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
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  String getPhotoUrl() {
    return widget.newsArticle.photoUrl;
  }

  @override
  Uint8List getPhotoInBytes() {
    return widget.newsArticle.photoInBytes;
  }

  @override
  void storeCachedImage(Uint8List photoInBytes) {
    widget.newsArticle.photoInBytes = photoInBytes;
  }

  @override
  Widget build(BuildContext context) {
    return buildPhotoContainer(
      animationController: _animationController,
      shadow: widget.shadow,
      height: widget.height,
      width: widget.width,
      borderRadius: widget.borderRadius,
    );
  }

  @override
  Widget getDefaultPhotoImage() {
    var _newsGroupId = widget.newsArticle.newsGroupId;
    var _newsGroup = NewsGroupService.getNewsGroup(_newsGroupId);
    var imagePath = _newsGroup.category.backgroundImagePath();

    return Image.asset(imagePath);
  }
}
