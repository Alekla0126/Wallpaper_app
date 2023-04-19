import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:walpy/translations/locale_keys.g.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:walpy/blocs/sign_in_bloc.dart';
import '../widgets/loading_animation.dart';
import 'package:walpy/pages/bookmark.dart';
import 'package:walpy/blocs/ads_bloc.dart';
import 'package:walpy/utils/dialog.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../blocs/internet_bloc.dart';
import '../pages/catagories.dart';
import '../blocs/data_bloc.dart';
import '../pages/bookmark.dart';
import '../pages/internet.dart';
import '../widgets/drawer.dart';
import '../models/config.dart';
import '../pages/details.dart';
import '../pages/explore.dart';
import 'dart:isolate';
import 'dart:ui';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int listIndex = 0;
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  //-------admob--------
  Future initAdmobAd() async{
    await MobileAds.instance.initialize()
    .then((value) => context.read<AdsBloc>().loadAdmobInterstitialAd()); 
  }



  //------fb-------
  // Future initFbAd() async {
  //   await FacebookAudienceNetwork.init()
  //   .then((value) => context.read<AdsBloc>().loadFbAd());
  // }



  Future getData() async {
    Future.delayed(Duration(milliseconds: 0)).then((f) {
      final sb = context.read<SignInBloc>();
      final db = context.read<DataBloc>();

      sb.getUserDatafromSP()
      .then((value) => db.getData())
      .then((value) => db.getCategories());
    });
  }





  @override
  void initState() {
    super.initState();
    initDownloader();
    initOnesignal();
    getData();

    initAdmobAd();          //-------admob--------
    //initFbAd();             //-------fb--------
  }



  initOnesignal (){
    OneSignal.shared.setAppId(Config().onesignalAppId);
  }




  initDownloader() {
    FlutterDownloader.registerCallback(downloadCallback);
  }



  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }



  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {

    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    final db = context.watch<DataBloc>();
    final ib = context.watch<InternetBloc>();
    final sb = context.watch<SignInBloc>();

    return ib.hasInternet == false
        ? NoInternetPage()
        : Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.white,
            endDrawer: DrawerWidget(),
            body: SafeArea(
              child: Column(
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(
                        left: 30,
                        right: 10,
                      ),
                      alignment: Alignment.centerLeft,
                      height: 70,
                      child: Row(
                        children: <Widget>[
                          Text(
                            Config().appName,
                            style: TextStyle(
                                fontSize: 27,
                                color: Colors.black,
                                fontWeight: FontWeight.w800),
                          ),
                          Spacer(),
                          InkWell(
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[300],
                                  image: !context.watch<SignInBloc>().isSignedIn || context.watch<SignInBloc>().imageUrl == null
                                  ? DecorationImage(image: AssetImage(Config().guestAvatar))
                                  : DecorationImage(image: CachedNetworkImageProvider(context.watch<SignInBloc>().imageUrl!))),
                            ),
                            onTap: () {
                              !sb.isSignedIn
                                  ? showGuestUserInfo(context)
                                  : showUserInfo(context, sb.name, sb.email, sb.imageUrl);
                            },
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          IconButton(
                            icon: Icon(
                              FontAwesomeIcons.stream,
                              size: 20,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              _scaffoldKey.currentState!.openEndDrawer();
                            },
                          )
                        ],
                      )),
                  Stack(
                    children: <Widget>[
                      CarouselSlider(
                        options: CarouselOptions(
                            enlargeStrategy: CenterPageEnlargeStrategy.height,
                            initialPage: 0,
                            viewportFraction: 0.90,
                            enlargeCenterPage: true,
                            enableInfiniteScroll: false,
                            height: h * 0.70,
                            onPageChanged: (int index, reason) {
                              setState(() => listIndex = index);
                            }),
                        items: db.alldata.length == 0
                            ? [0, 1]
                                .take(1)
                                .map((f) => LoadingWidget())
                                .toList()
                            : db.alldata.map((i) {
                                return Builder(
                                  builder: (BuildContext context) {
                                    return Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 0),
                                        child: InkWell(
                                          child: CachedNetworkImage(
                                            imageUrl: i['image url'],
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    Hero(
                                              tag: i['timestamp'],
                                              child: Container(
                                                margin: EdgeInsets.only(
                                                    left: 10,
                                                    right: 10,
                                                    top: 10,
                                                    bottom: 50),
                                                decoration: BoxDecoration(
                                                    color: Colors.grey[200],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    boxShadow: <BoxShadow>[
                                                      BoxShadow(
                                                          color:
                                                              Colors.grey[300]!,
                                                          blurRadius: 30,
                                                          offset: Offset(5, 20))
                                                    ],
                                                    image: DecorationImage(
                                                        image: imageProvider,
                                                        fit: BoxFit.cover)),
                                                child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 30,
                                                            bottom: 40),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: <Widget>[
                                                        Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            Text(
                                                              Config().hashTag,
                                                              style: TextStyle(
                                                                  decoration:
                                                                      TextDecoration
                                                                          .none,
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 14),
                                                            ),
                                                            Text(
                                                              i['category'],
                                                              style: TextStyle(
                                                                  decoration:
                                                                      TextDecoration
                                                                          .none,
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 25),
                                                            )
                                                          ],
                                                        ),
                                                        Spacer(),
                                                        Icon(
                                                          Icons.favorite,
                                                          size: 25,
                                                          color: Colors.white
                                                              .withOpacity(0.5),
                                                        ),
                                                        SizedBox(width: 2),
                                                        Text(
                                                          i['loves'].toString(),
                                                          style: TextStyle(
                                                              decoration:
                                                                  TextDecoration
                                                                      .none,
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.7),
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                        SizedBox(
                                                          width: 15,
                                                        )
                                                      ],
                                                    )),
                                              ),
                                            ),
                                            placeholder: (context, url) =>
                                                LoadingWidget(),
                                            errorWidget:
                                                (context, url, error) => Icon(
                                              Icons.error,
                                              size: 40,
                                            ),
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        DetailsPage(
                                                            tag: i['timestamp'],
                                                            imageUrl:
                                                                i['image url'],
                                                            category:
                                                                i['category'],
                                                            timestamp: i[
                                                                'timestamp'])));
                                          },
                                        ));
                                  },
                                );
                              }).toList(),
                      ),
                      Positioned(
                        top: 40,
                        left: w * 0.23,
                        child: Text(
                          LocaleKeys.walpy_day.tr(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        left: w * 0.34,
                        child: Container(
                          padding: EdgeInsets.all(12),
                          child: DotsIndicator(
                            dotsCount: 5,
                            position: listIndex.toDouble(),
                            decorator: DotsDecorator(
                              activeColor: Colors.black,
                              color: Colors.black,
                              spacing: EdgeInsets.all(3),
                              size: const Size.square(8.0),
                              activeSize: const Size(40.0, 6.0),
                              activeShape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0)),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Spacer(),
                  Container(
                    height: 50,
                    width: w * 0.80,
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(30)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(FontAwesomeIcons.dashcube,
                              color: Colors.grey[600], size: 20),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CatagoryPage()));
                          },
                        ),
                        IconButton(
                          icon: Icon(FontAwesomeIcons.solidCompass,
                              color: Colors.grey[600], size: 20),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ExplorePage()));
                          },
                        ),
                        IconButton(
                          icon: Icon(FontAwesomeIcons.solidHeart,
                              color: Colors.grey[600], size: 20),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FavouritePage(userUID: context.read<SignInBloc>().uid)));
                          },
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
          );
  }
}
