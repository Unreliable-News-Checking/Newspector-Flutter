import 'dart:async';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/models/category.dart';
import 'package:newspector_flutter/models/feed.dart';
import 'package:newspector_flutter/pages/sign_page.dart';
import 'package:newspector_flutter/services/news_feed_service.dart';
import 'package:newspector_flutter/widgets/feed_container.dart';
import 'package:newspector_flutter/widgets/news_group_container.dart';
import 'package:newspector_flutter/application_constants.dart' as app_const;
import 'package:newspector_flutter/services/sign_in_service.dart'
    as sign_in_service;

class NewsFeedPage extends StatefulWidget {
  final ScrollController scrollController;
  final FeedType feedType;
  final NewsCategory newsCategory;
  final String title;

  NewsFeedPage({
    Key key,
    @required this.scrollController,
    @required this.feedType,
    @required this.title,
    this.newsCategory,
  }) : super(key: key);

  @override
  _NewsFeedPageState createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage>
    with FeedContainer<NewsFeedPage, Feed<String>> {
  Feed<String> _newsFeed;
  ScrollController _scrollController;
  FeedType feedType;
  SortingType sortingType;
  var pageSize = app_const.newsFeedPageSize;
  var newsGroupPageSize = app_const.newsGroupPageSize;
  var isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    feedType = widget.feedType;
    sortingType = SortingType.Latest;
  }

  @override
  Widget build(BuildContext context) {
    if (NewsFeedService.hasFeed(feedType, newsCategory: widget.newsCategory)) {
      _newsFeed = NewsFeedService.getFeed(
        feedType,
        newsCategory: widget.newsCategory,
      );

      return homeScaffold();
    }

    return FutureBuilder(
      future: getFeed(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            return homeScaffold();
            break;
          default:
            return loadingScaffold(widget.title);
        }
      },
    );
  }

  // shown when there is a feed with news groups
  Widget homeScaffold() {
    return Scaffold(
      backgroundColor: app_const.backgroundColor,
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          return onScrollNotification(
            _newsFeed.showLoadMore,
            isLoading,
            scrollInfo,
            fetchAdditionalItems,
            (loading) => isLoading = loading,
          );
        },
        child: CupertinoScrollbar(
          child: CustomScrollView(
            controller: _scrollController,
            physics: BouncingScrollPhysics()
                .applyTo(AlwaysScrollableScrollPhysics()),
            slivers: <Widget>[
              sliverAppBar(
                widget.title,
                leading: signOutButton(),
                actions: <Widget>[sortingMenu()],
              ),
              refreshControl(getFeed),
              itemList(),
              loadMoreContainer(_newsFeed.showLoadMore),
            ],
          ),
        ),
      ),
    );
  }

  Widget sortingMenu() {
    if (widget.feedType != FeedType.Home) return Container();

    return Container(
      padding: EdgeInsets.only(right: 15),
      alignment: Alignment.center,
      child: DropdownButton<SortingType>(
        value: sortingType,
        icon: Icon(
          Icons.arrow_drop_down,
          color: app_const.defaultTextColor,
        ),
        dropdownColor: app_const.backgroundColor,
        elevation: 16,
        style: TextStyle(color: app_const.defaultTextColor),
        underline: Container(),
        onChanged: (SortingType newValue) {
          if (mounted) {
            setState(() {
              sortingType = newValue;
              feedType = sortingType == SortingType.Latest
                  ? FeedType.Home
                  : FeedType.Trending;
            });
          }
        },
        items: <SortingType>[SortingType.Latest, SortingType.Trending]
            .map<DropdownMenuItem<SortingType>>(
          (SortingType value) {
            var textRep = value == SortingType.Trending ? "Trending" : "Latest";
            return DropdownMenuItem<SortingType>(
              value: value,
              child: Text(
                textRep,
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget signOutButton() {
    if (widget.feedType != FeedType.Home) return null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async => await hellwtf(),
      child: Icon(EvaIcons.logOut),
    );
  }

  Future<void> hellwtf() async {
    var signPageRoute = MaterialPageRoute(
      builder: (context) {
        return SignPage();
      },
    );

    Navigator.of(context, rootNavigator: true).pushReplacement(signPageRoute);
    signPageRoute.didPush().whenComplete(() => sign_in_service.signOutGoogle());
  }

  Widget itemList() {
    if (_newsFeed.getItemCount() == 0) {
      return emptyList("There are no news groups yet.");
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Container(
            child: NewsGroupContainer(
              newsGroupId: _newsFeed.getItem(index),
            ),
          );
        },
        childCount: _newsFeed.getItemCount(),
      ),
    );
  }

  /// If there is an existing feed returns it,
  /// if not fetches the feed from the database and returns it.
  @override
  Future<Feed<String>> getFeed() async {
    _newsFeed = await NewsFeedService.updateAndGetNewsFeed(
      pageSize: pageSize,
      newsGroupPageSize: newsGroupPageSize,
      feedType: feedType,
      newsCategory: widget.newsCategory,
    );

    if (mounted) setState(() {});
    return _newsFeed;
  }

  /// Fetches the wanted documents after the specified document.
  Future<void> fetchAdditionalItems() async {
    var lastDocumentId = _newsFeed.getLastItem();

    _newsFeed = await NewsFeedService.updateAndGetNewsFeed(
      pageSize: pageSize,
      lastDocumentId: lastDocumentId,
      newsGroupPageSize: newsGroupPageSize,
      feedType: feedType,
      newsCategory: widget.newsCategory,
    );
  }
}

enum SortingType {
  Latest,
  Trending,
}
