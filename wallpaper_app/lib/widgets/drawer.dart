import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:walpy/translations/locale_keys.g.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:launch_review/launch_review.dart';
import 'package:walpy/blocs/sign_in_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../pages/sign_in_page.dart';
import '../utils/next_screen.dart';
import '../pages/catagories.dart';
import '../pages/bookmark.dart';
import '../models/config.dart';
import '../pages/explore.dart';


class DrawerWidget extends StatefulWidget {
  DrawerWidget({Key? key}) : super(key: key);
  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class Language {
  final int id;
  final String name;
  final String languageCode;
  const Language(this.id, this.name, this.languageCode);
}

const List<Language> getLanguages = <Language>[
  Language(0, 'Spanish', 'es'),
  Language(1, 'English', 'en'),
];

String? selectedValue;

class _DrawerWidgetState extends State<DrawerWidget> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  var textCtrl = TextEditingController();

  final List title = [
    LocaleKeys.items_categories.tr(),
    LocaleKeys.items_explore.tr(),
    LocaleKeys.items_favourites.tr(),
    LocaleKeys.items_about_the_app.tr(),
    LocaleKeys.items_rate_app.tr(),
    LocaleKeys.items_change_language.tr()
  ];

  final List icons = [
    FontAwesomeIcons.dashcube,
    FontAwesomeIcons.solidCompass,
    FontAwesomeIcons.solidHeart,
    FontAwesomeIcons.info,
    FontAwesomeIcons.star,
    FontAwesomeIcons.language
  ];

  Future openLogoutDialog(context1) async {
    showDialog(
        context: context1,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Logout?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            content: Text(LocaleKeys.logout_confirm.tr()),
            actions: <Widget>[
              TextButton(
                child: Text('Yes'),
                onPressed: () async {
                  final sb = context.read<SignInBloc>();
                  Navigator.pop(context);
                  await sb
                      .userSignout()
                      .then((_) => nextScreenReplace(context, SignInPage()));
                },
              ),
              TextButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  aboutAppDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AboutDialog(
            applicationVersion: Config().appVersion,
            applicationName: Config().appName,
            applicationIcon: Image(
              height: 40,
              width: 40,
              image: AssetImage(Config().appIcon),
            ),
            applicationLegalese: LocaleKeys.developed.tr(),
          );
        });
  }

  void handleRating() {
    LaunchReview.launch(
        androidAppId: Config().packageName, iOSAppId: null, writeReview: true);
  }

  void openLanguage() {
    String? selectedValue;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          var languages = [LocaleKeys.supported_languages_spanish.tr(),
            LocaleKeys.supported_languages_english.tr()
          ];
          switch (context.locale.toString()) {
            case 'es_ES':
              selectedValue = languages[0];
              break;
            case 'en_US':
              selectedValue = languages[1];
              break;
          }
          return AlertDialog(
            content: Container(
              decoration: BoxDecoration(
                  // color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(10)),
              child: DropdownButton(
                  hint: Text(
                      selectedValue.toString()
                  ),
                  icon: Visibility (
                      visible: true,
                      child: Icon(Icons.arrow_downward)
                  ),
                  iconSize: 24,
                  elevation: 16,
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  style: new TextStyle(
                    color: Colors.deepPurpleAccent,
                    fontSize: 20
                  ),
                  items: getLanguages.map((Language lang) {
                    return new DropdownMenuItem<String>(
                      value: context.locale.toString(),
                      child: new Text(
                          languages[lang.id]
                      ),
                    );
                  }).toList(),
                  onChanged: (val) async {
                    switch (val) {
                      case 'es_ES':
                        context.setLocale(context.supportedLocales[0]);
                        setState(() {
                          selectedValue = languages[0];
                        });
                        break;
                      case 'en_US':
                        context.setLocale(context.supportedLocales[1]);
                        setState(() {
                          selectedValue = languages[1];
                        });
                        break;
                    }
                  },
                ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                    LocaleKeys.close.tr()
                ),
              ),
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 50, left: 0),
                alignment: Alignment.center,
                height: 150,
                child: Text(
                  Config().hashTag.toUpperCase(),
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: title.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      child: Container(
                        height: 45,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                icons[index],
                                color: Colors.grey,
                                size: 22,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(title[index],
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500))
                            ],
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        if (index == 0) {
                          nextScreeniOS(context, CatagoryPage());
                        } else if (index == 1) {
                          nextScreeniOS(context, ExplorePage());
                        } else if (index == 2) {
                          nextScreeniOS(context, FavouritePage(userUID: context.read<SignInBloc>().uid));
                        } else if (index == 3) {
                          aboutAppDialog();
                        } else if (index == 4) {
                          handleRating();
                        } else if (index == 5) {
                          openLanguage();
                        }
                      },
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider();
                  },
                ),
              ),
              Column(
                children: [
                  !context.watch<SignInBloc>().isSignedIn
                      ? Container()
                      : Column(
                          children: [
                            Divider(),
                            InkWell(
                              child: Container(
                                height: 45,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        FontAwesomeIcons.signOutAlt,
                                        color: Colors.grey,
                                        size: 22,
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text(LocaleKeys.close.tr(),
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500))
                                    ],
                                  ),
                                ),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                openLogoutDialog(context);
                              },
                            ),
                          ],
                        ),
                ],
              ),
            ],
          )),
    );
  }
}
