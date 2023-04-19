// Details page
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:walpy/translations/locale_keys.g.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:external_path/external_path.dart';
import 'package:walpy/blocs/sign_in_bloc.dart';
import 'package:walpy/blocs/ads_bloc.dart';
import 'package:wallpaper/wallpaper.dart';
import 'package:walpy/utils/dialog.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../utils/circular_button.dart';
import '../blocs/internet_bloc.dart';
import '../blocs/userdata_bloc.dart';
import '../models/icon_data.dart';
import '../blocs/data_bloc.dart';
import '../models/config.dart';
import 'dart:io';


class DetailsPage extends StatefulWidget {
  final String? tag;
  final String? imageUrl;
  final String? category;
  final String? timestamp;
  DetailsPage(
      {Key? key,
        required this.tag,
        this.imageUrl,
        this.category,
        this.timestamp})
      : super(key: key);
  @override
  _DetailsPageState createState() =>
      _DetailsPageState(this.tag, this.imageUrl, this.category, this.timestamp);
}

class _DetailsPageState extends State<DetailsPage> {
  String? tag;
  String? imageUrl;
  String? category;
  String? timestamp;
  _DetailsPageState(this.tag, this.imageUrl, this.category, this.timestamp);
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String progress = LocaleKeys.set_wallpaper.tr();
  bool downloading = false;
  late Stream<String> progressString;
  Icon dropIcon = Icon(Icons.arrow_upward);
  Icon upIcon = Icon(Icons.arrow_upward);
  Icon downIcon = Icon(Icons.arrow_downward);
  PanelController pc = PanelController();
  PermissionStatus? status;

  void openSetDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(LocaleKeys.set_as.tr()),
          contentPadding:
          EdgeInsets.only(left: 30, top: 40, bottom: 20, right: 40),
          children: <Widget>[
            ListTile(
              contentPadding: EdgeInsets.all(0),
              leading: circularButton(Icons.format_paint, Colors.blueAccent),
              title: Text(LocaleKeys.set_lockscreen.tr()),
              onTap: () async {
                await _setLockScreen();
                Navigator.pop(context);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.all(0),
              leading: circularButton(Icons.donut_small, Colors.pinkAccent),
              title: Text(LocaleKeys.set_homescreen.tr()),
              onTap: () async {
                await _setHomeScreen();
                Navigator.pop(context);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.all(0),
              leading: circularButton(Icons.compare, Colors.orangeAccent),
              title: Text(LocaleKeys.set_both.tr()),
              onTap: () async {
                await _setBoth();
                Navigator.pop(context);
              },
            ),
            SizedBox(
              height: 40,
            ),
            Center(
              child: TextButton(
                child: Text(LocaleKeys.cancel.tr()),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            )
          ],
        );
      },
    );
  }

  // Lock screen procedure
  _setLockScreen() {
    Platform.isIOS
        ? setState(() {
      progress = 'iOS is not supported';
    })
        : progressString = Wallpaper.imageDownloadProgress(imageUrl!);
    progressString.listen((data) {
      setState(() {
        downloading = true;
        progress =
            LocaleKeys.setting_lockscreen.tr() +
            '\n'+
            LocaleKeys.progress.tr() +
            data;
      });
      print("DataReceived: " + data);
    }, onDone: () async {
      progress = await Wallpaper.lockScreen();
      setState(() {
        downloading = false;
        progress = progress;
      });
      openCompleteDialog();
    }, onError: (error) {
      setState(() {
        downloading = false;
      });
      print("Algun error");
    });
  }
  // Home screen procedure
  _setHomeScreen() {
    Platform.isIOS
        ? setState(() {
      progress = 'iOS no es soportado';
    })
        : progressString = Wallpaper.imageDownloadProgress(imageUrl!);
    progressString.listen((data) {
      setState(() {
        //res = data;
        downloading = true;
        progress = LocaleKeys.setting_home_screen.tr()+
            '\n'+LocaleKeys.progress.tr()+
            data;
      });
      print("DataReceived: " + data);
    }, onDone: () async {
      progress = await Wallpaper.homeScreen();
      setState(() {
        downloading = false;
        progress = progress;
      });
      openCompleteDialog();
    }, onError: (error) {
      setState(() {
        downloading = false;
      });
      print("Algun error al descargar");
    });
  }
  // Both lock screen & home screen procedure
  _setBoth() {
    Platform.isIOS
        ? setState(() {
      progress = LocaleKeys.ios_support.tr();
    })
        : progressString = Wallpaper.imageDownloadProgress(imageUrl!);
    progressString.listen((data) {
      setState(() {
        downloading = true;
        progress = LocaleKeys.configuration.tr()+' $data';
      });
      print("DataReceived: " + data);
    }, onDone: () async {
      progress = await Wallpaper.bothScreen();
      setState(() {
        downloading = false;
        progress = progress;
      });
      openCompleteDialog();
    }, onError: (error) {
      setState(() {
        downloading = false;
      });
      print("Algun error");
    });
  }

  handleStoragePermission() async {
    await Permission.storage.request().then((_) async {
      if (await Permission.storage.status == PermissionStatus.granted) {
        await handleDownload();
      } else if (await Permission.storage.status == PermissionStatus.denied) {
      } else if (await Permission.storage.status == PermissionStatus.permanentlyDenied) {
        askOpenSettingsDialog();
      }
    });
  }

  void openCompleteDialog() async {
    var dialog_t = LocaleKeys.complete.tr();
    AwesomeDialog(
        context: context,
        dialogType: DialogType.SUCCES,
        title: dialog_t,
        animType: AnimType.SCALE,
        padding: EdgeInsets.all(30),
        body: Center(
          child: Container(
              alignment: Alignment.center,
              height: 80,
              child: Text(
                LocaleKeys.progress_finished.tr(),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              )),
        ),
        btnOkText: 'Ok',
        dismissOnTouchOutside: false,
        btnOkOnPress: () {
          context.read<AdsBloc>().showInterstitialAdAdmob();        //-------admob--------
          //context.read<AdsBloc>().showFbAdd();                        //-------fb--------
        }).show();
  }

  askOpenSettingsDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(LocaleKeys.permisson.tr()),
            content: Text(LocaleKeys.allow_storage.tr()),
            contentTextStyle:
            TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
            actions: [
              TextButton(
                child: Text(LocaleKeys.open_config.tr()),
                onPressed: () async {
                  Navigator.pop(context);
                  await openAppSettings();
                },
              ),
              TextButton(
                child: Text(LocaleKeys.close.tr()),
                onPressed: () async {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  Future handleDownload() async {
    final ib = context.read<InternetBloc>();
    await context.read<InternetBloc>().checkInternet();
    if(ib.hasInternet == true){
      var path = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_PICTURES);
      await FlutterDownloader.enqueue(
        url: imageUrl!,
        savedDir: path,
        fileName: '${Config().appName}-$category$timestamp',
        showNotification: true, // show download progress in status bar (for Android)
        openFileFromNotification: true, // click on notification to open downloaded file (for Android)
      );
      setState(() {
        progress = LocaleKeys.complete_download.tr()+'\n'+LocaleKeys.check_status_bar.tr();
      });
      await Future.delayed(Duration(seconds: 2));
      openCompleteDialog();
    } else{
      setState(() {
        progress = LocaleKeys.check_internet.tr();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    final DataBloc db = Provider.of<DataBloc>(context, listen: false);
    return Scaffold(
        key: _scaffoldKey,
        body: SlidingUpPanel(
          controller: pc,
          color: Colors.white.withOpacity(0.9),
          minHeight: 120,
          maxHeight: 450,
          backdropEnabled: false,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15), topRight: Radius.circular(15)),
          body: panelBodyUI(h, w),
          panel: panelUI(db),
          onPanelClosed: () {
            setState(() {
              dropIcon = upIcon;
            });
          },
          onPanelOpened: () {
            setState(() {
              dropIcon = downIcon;
            });
          },
        ));
  }

  // Floating ui
  Widget panelUI(db) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            child: Container(
              padding: EdgeInsets.only(top: 10),
              width: double.infinity,
              child: CircleAvatar(
                backgroundColor: Colors.grey[800],
                child: dropIcon,
              ),
            ),
            onTap: () {
              pc.isPanelClosed ? pc.open() : pc.close();
            },
          ),
          SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      Config().hashTag,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    Text(
                      '$category Wallpaper',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    )
                  ],
                ),
                Spacer(),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.favorite,
                      color: Colors.pinkAccent,
                      size: 22,
                    ),
                    StreamBuilder(
                      stream: firestore
                          .collection('contents')
                          .doc(timestamp)
                          .snapshots(),
                      builder: (context, AsyncSnapshot snap) {
                        if (!snap.hasData) return _buildLoves(0);
                        return _buildLoves(snap.data['loves']);
                      },
                    ),
                  ],
                ),
                SizedBox(
                  width: 20,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    InkWell(
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: Colors.grey[400]!,
                                  blurRadius: 10,
                                  offset: Offset(2, 2))
                            ]),
                        child: Icon(
                          Icons.format_paint,
                          color: Colors.white,
                        ),
                      ),
                      onTap: () async {
                        final ib =  context.read<InternetBloc>();
                        await context.read<InternetBloc>().checkInternet();
                        if (ib.hasInternet == false) {
                          setState(() {
                            progress = LocaleKeys.check_internet.tr();
                          });
                        } else {
                          openSetDialog();
                        }
                      },
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      LocaleKeys.set.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w600),
                    )
                  ],
                ),
                SizedBox(
                  width: 20,
                ),
                Column(
                  children: <Widget>[
                    InkWell(
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            color: Colors.pinkAccent,
                            shape: BoxShape.circle,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: Colors.grey[400]!,
                                  blurRadius: 10,
                                  offset: Offset(2, 2))
                            ]),
                        child: Icon(
                          Icons.donut_small,
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        handleStoragePermission();
                      },
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      LocaleKeys.download.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w600),
                    )
                  ],
                ),
                SizedBox(
                  width: 20,
                ),
              ],
            ),
          ),
          Spacer(),
          Padding(
              padding: const EdgeInsets.only(left: 20, right: 10),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 5,
                    height: 30,
                    color: Colors.blueAccent,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      progress,
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              )),
          SizedBox(
            height: 40,
          )
        ],
      ),
    );
  }

  Widget _buildLoves(loves) {
    return Text(
      loves.toString(),
      style: TextStyle(color: Colors.black54, fontSize: 16),
    );
  }

  // Background ui
  Widget panelBodyUI(h, w) {
    final SignInBloc sb = Provider.of<SignInBloc>(context, listen: false);
    return Stack(
      children: <Widget>[
        Container(
          height: h,
          width: w,
          color: Colors.grey[200],
          child: Hero(
            tag: tag!,
            child: CachedNetworkImage(
              imageUrl: imageUrl!,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover)),
              ),
              placeholder: (context, url) => Icon(Icons.image),
              errorWidget: (context, url, error) =>
                  Center(child: Icon(Icons.error)),
            ),
          ),
        ),
        Positioned(
          top: 60,
          right: 20,
          child: InkWell(
            child: Container(
                height: 40,
                width: 40,
                decoration:
                BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: _buildLoveIcon(sb.uid)),
            onTap: () {
              _loveIconPressed();
            },
          ),
        ),
        Positioned(
          top: 60,
          left: 20,
          child: InkWell(
            child: Container(
              height: 40,
              width: 40,
              decoration:
              BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(
                Icons.close,
                size: 25,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        )
      ],
    );
  }

  Widget _buildLoveIcon(uid) {
    final sb = context.watch<SignInBloc>();
    if (sb.guestUser == false) {
      return StreamBuilder(
        stream: firestore.collection('users').doc(uid).snapshots(),
        builder: (context, AsyncSnapshot snap) {
          if (!snap.hasData) return LoveIcon().greyIcon;
          List d = snap.data['loved items'];
          if (d.contains(timestamp)) {
            return LoveIcon().pinkIcon;
          } else {
            return LoveIcon().greyIcon;
          }
        },
      );
    } else {
      return LoveIcon().greyIcon;
    }
  }

  _loveIconPressed() async {
    final sb = context.read<SignInBloc>();
    if (sb.guestUser == false) {
      context.read<UserBloc>().handleLoveIconClick(context, timestamp, sb.uid);
    } else {
      await showGuestUserInfo(context);
    }
  }
}