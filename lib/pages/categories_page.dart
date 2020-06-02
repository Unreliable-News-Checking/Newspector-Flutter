import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:newspector_flutter/application_constants.dart' as app_const;
import 'package:newspector_flutter/models/category.dart';
import 'news_feed_page.dart';
import 'package:newspector_flutter/services/news_feed_service.dart';
import 'package:newspector_flutter/widgets/sliver_app_bar.dart';

class CategoriesPage extends StatefulWidget {
  final Stream Function() getScrollStream;

  CategoriesPage({
    Key key,
    @required this.getScrollStream,
  }) : super(key: key);

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  ScrollController _scrollController;
  var categories = [
    NewsCategory.general,
    NewsCategory.peopleSociety,
    NewsCategory.businessIndustrial,
    NewsCategory.lawGovernment,
    NewsCategory.finance,
    NewsCategory.jobsEducation,
    NewsCategory.science,
    NewsCategory.computersElectronics,
    NewsCategory.travel,
    NewsCategory.health,
    NewsCategory.sports,
    NewsCategory.foodDrink,
    NewsCategory.petsAnimals,
    NewsCategory.artEntertainment,
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    widget.getScrollStream().listen((event) {
      _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: app_const.backgroundColor,
      body: CupertinoScrollbar(
        child: CustomScrollView(
          controller: _scrollController,
          physics:
              BouncingScrollPhysics().applyTo(AlwaysScrollableScrollPhysics()),
          slivers: <Widget>[
            sliverAppBar("Categories"),
            itemList(),
          ],
        ),
      ),
    );
  }

  Widget sliverAppBar(String title, {List<Widget> actions}) {
    return defaultSliverAppBar(titleText: title, actions: actions);
  }

  Widget itemList() {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return categoryItem(index);
        },
        childCount: categories.length,
      ),
    );
  }

  Widget categoryItem(int index) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return NewsFeedPage(
            scrollController: ScrollController(),
            feedType: FeedType.Category,
            newsCategory: categories[index],
            title: categories[index].name,
          );
        }));
      },
      child: Container(
        margin: EdgeInsets.all(3),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              SizedBox.expand(
                child: FittedBox(
                  child: Image.asset(
                    categories[index].backgroundImagePath(),
                    // color: app_const.defaultTextColor,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  margin: EdgeInsets.all(8),
                  child: Text(
                    '${categories[index].name}',
                    style: TextStyle(
                      color: app_const.defaultTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      shadows: app_const.shadowsForWhiteWidgets(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
