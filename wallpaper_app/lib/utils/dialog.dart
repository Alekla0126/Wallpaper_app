import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:walpy/translations/locale_keys.g.dart';
import 'package:walpy/blocs/sign_in_bloc.dart';
import 'package:walpy/pages/sign_in_page.dart';
import 'package:walpy/utils/next_screen.dart';
import 'package:provider/src/provider.dart';
import 'package:walpy/models/config.dart';
import 'package:flutter/material.dart';


void openDialog(context, title, message) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(message),
          title: Text(title),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'))
          ],
        );
      });
}

showUserInfo(context, name, email, imageUrl) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding:
              EdgeInsets.only(left: 0, right: 0, top: 40, bottom: 0),
          content: Container(
              height: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[300],
                        image: DecorationImage(
                            image: CachedNetworkImageProvider(imageUrl))),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Hi $name,',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    LocaleKeys.signin_message.tr()+'\n$email',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey),
                  ),
                  Spacer(),
                  InkWell(
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.blueAccent,
                      child: Text(
                        LocaleKeys.success_message.tr(),
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              )),
        );
      });
}



showGuestUserInfo(context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding:
              EdgeInsets.only(left: 0, right: 0, top: 40, bottom: 0),
          content: Container(
              height: 350,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[300],
                        image: !context.watch<SignInBloc>().isSignedIn || context.watch<SignInBloc>().imageUrl == null
                                  ? DecorationImage(image: AssetImage(Config().guestAvatar))
                                  : DecorationImage(image: CachedNetworkImageProvider(context.watch<SignInBloc>().imageUrl!))),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Hi there,',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: Text(
                      "You didn't sign in with ${Config().appName} yet. Sign in to unlock likes and save feature.\nDo you want to sign in now?",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey),
                    ),
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        flex: 1,
                        child: InkWell(
                          child: Container(
                            height: 50,
                            alignment: Alignment.center,
                            color: Colors.blueAccent,
                            child: Text(
                              'Yes, Now',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          onTap: () async {
                            Navigator.pop(context);
                            nextScreenPopup(context, SignInPage(closeDialog: true,));
                          },
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: InkWell(
                          child: Container(
                            height: 50,
                            alignment: Alignment.center,
                            color: Colors.blue[400],
                            child: Text(
                              'Maybe Later',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              )),
        );
      });
}
