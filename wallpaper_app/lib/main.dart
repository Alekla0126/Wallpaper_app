import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:walpy/blocs/bookmark_bloc.dart';
import 'package:walpy/blocs/userdata_bloc.dart';
import 'package:walpy/blocs/internet_bloc.dart';
import 'package:walpy/blocs/sign_in_bloc.dart';
import 'package:walpy/pages/sign_in_page.dart';
import 'package:walpy/blocs/data_bloc.dart';
import 'package:walpy/blocs/ads_bloc.dart';
import 'package:provider/provider.dart';
import 'package:walpy/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Add laucher icon and test the ads.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  await FlutterDownloader.initialize(
    debug: true
  );
  runApp(
    EasyLocalization(
        supportedLocales: [Locale('en', 'US'), Locale('es', 'ES')],
        path: 'assets/translations',
        fallbackLocale: Locale('en', 'US'),
        child: MyApp()
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<DataBloc>(
            create: (context) => DataBloc(),
          ),
          ChangeNotifierProvider<SignInBloc>(
            create: (context) => SignInBloc(),
          ),
          ChangeNotifierProvider<UserBloc>(
            create: (context) => UserBloc(),
          ),
          ChangeNotifierProvider<BookmarkBloc>(
            create: (context) => BookmarkBloc(),
          ),
          ChangeNotifierProvider<InternetBloc>(
            create: (context) => InternetBloc(),
          ),
          ChangeNotifierProvider<AdsBloc>(
            create: (context) => AdsBloc(),
          ),
        ],
        child: MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: 'Poppins',
              appBarTheme: AppBarTheme(
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarIconBrightness: Brightness.dark,
                  statusBarColor: Colors.transparent,
                ),
                color: Colors.white,
                titleTextStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600),
                elevation: 0,
                iconTheme: IconThemeData(
                  color: Colors.black,
                ),
              ),
              textTheme: TextTheme(
                  headline6: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  )
              ),
            ),
            home: MyApp1()
        )
    );
  }
}

class MyApp1 extends StatelessWidget {
  const MyApp1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sb = context.watch<SignInBloc>();
    return sb.isSignedIn == false && sb.guestUser == false
    ? SignInPage() : HomePage();
  }
}