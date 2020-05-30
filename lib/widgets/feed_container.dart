import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newspector_flutter/application_constants.dart' as app_const;
import 'package:newspector_flutter/widgets/sliver_app_bar.dart';

mixin FeedContainer<T extends StatefulWidget, E> on State<T> {
  Widget homeScaffold();
  Widget itemList();
  Future<E> getFeed();
  Future<void> fetchAdditionalItems();

  // shown when the page is loading the new feed
  Widget loadingScaffold(String title) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(color: app_const.defaultTextColor),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: app_const.backgroundColor,
      ),
      backgroundColor: app_const.backgroundColor,
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget sliverAppBar(String title, {List<Widget> actions, Widget leading}) {
    return defaultSliverAppBar(
      titleText: title,
      actions: actions,
      leading: leading,
    );
  }

  Widget refreshControl(Function onRefresh) {
    return defaultRefreshControl(onRefresh: onRefresh);
  }

  // shown when the page is loading the new feed
  Widget emptyList(String message) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.only(top: 50),
        child: Center(
          child: Text(message),
        ),
      ),
    );
  }

  Widget loadMoreContainer(bool loadMoreVisible) {
    if (!loadMoreVisible) {
      return SliverToBoxAdapter(
        child: Container(),
      );
    }

    return SliverToBoxAdapter(
      child: Container(
        height: 50,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  bool onScrollNotification(
    bool loadMoreVisible,
    bool isLoading,
    ScrollNotification scrollInfo,
    Function fetchAdditionalItems,
    Function(bool) setLoading,
  ) {
    if (!loadMoreVisible) return true;
    if (isLoading) return true;

    var reachedBottom =
        scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent * 0.5;

    if (!reachedBottom) return true;

    onBottomReached(
      loadMoreVisible,
      isLoading,
      fetchAdditionalItems,
      setLoading,
    );

    return true;
  }

  void onBottomReached(
    bool loadMoreVisible,
    bool isLoading,
    Function fetchAdditionalItems,
    Function(bool) setLoading,
  ) async {
    if (!loadMoreVisible) return;
    if (isLoading) return;

    if (mounted) {
      setState(() {
        setLoading(true);
      });
    }

    await fetchAdditionalItems();

    if (mounted) {
      setState(() {
        setLoading(false);
      });
    }
  }
}
