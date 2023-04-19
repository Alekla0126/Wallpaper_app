import 'package:easy_localization/easy_localization.dart';
import 'package:walpy/translations/locale_keys.g.dart';
import 'package:walpy/widgets/popular_items.dart';
import 'package:walpy/widgets/new_items.dart';
import 'package:flutter/material.dart';

class ExplorePage extends StatefulWidget {
  ExplorePage({Key? key}) : super(key: key);

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> with TickerProviderStateMixin {

  var scaffoldKey = GlobalKey<ScaffoldState>();
  TabController? tabController;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Container(
          child: SafeArea(
            child: TabBar(
              controller: tabController,
              labelStyle: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500),
              tabs: <Widget>[
                Tab(
                  child: Text(LocaleKeys.walpy_day.tr()),
                ),
                Tab(
                  child: Text(LocaleKeys.new_walpys.tr()),
                )
              ],
              labelColor: Colors.black,
              indicatorColor: Colors.grey[900],
              unselectedLabelColor: Colors.grey,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: <Widget>[
                PopularItems(scaffoldKey: scaffoldKey,), 
                NewItems(scaffoldKey: scaffoldKey,)
                
              ],
            ),
          ),
        ],
      ),
    );
  }
}
