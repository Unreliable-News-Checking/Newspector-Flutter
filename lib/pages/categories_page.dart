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
    NewsCategory.finance,
    NewsCategory.jobsEducation,
    NewsCategory.travel,
    NewsCategory.petsAnimals,
    NewsCategory.foodDrink,
    NewsCategory.science,
    NewsCategory.artEntertainment,
    NewsCategory.peopleSociety,
    NewsCategory.computersElectronics,
    NewsCategory.businessIndustrial,
    NewsCategory.health,
    NewsCategory.lawGovernment,
    NewsCategory.sports,
    NewsCategory.general,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 120,
                width: 120,
                child: FittedBox(
                  child: Image.asset(
                    categories[index].iconImagePath(),
                    color: app_const.defaultTextColor,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              '${categories[index].name}',
              style: TextStyle(
                color: app_const.defaultTextColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
