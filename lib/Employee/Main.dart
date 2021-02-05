import 'dart:html';

import 'package:audioplayers/audioplayers.dart';
import 'package:emergency_app/Constants.dart';
import 'package:emergency_app/Employee/Home.dart';
import 'package:emergency_app/Employee/Profile.dart';
import 'package:emergency_app/Employee/Setting.dart';
import 'package:emergency_app/Providers/EmployeeServies.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sizer/sizer.dart';
class EmployeeMain extends StatefulWidget {
  @override
  _EmployeeMainState createState() => _EmployeeMainState();
}
class _Page {
  _Page({this.widget});
  final StatefulWidget widget;
}
class _EmployeeMainState extends State<EmployeeMain> with SingleTickerProviderStateMixin {
  var _controller;
  List<_Page> _allPages;
  int selected=0;
  String playerId;
  GlobalKey<NavigatorState> navigatorKey;
  bool _requireConsent = false;
  AudioPlayer audioPlugin=AudioPlayer();
  @override
  void initState(){
    _allPages= <_Page>[
      _Page(widget: EmployeeHome()),
      _Page(widget: EmployeeSetting()),
    ];
    _controller = TabController(vsync: this, length: _allPages.length);
    _controller.addListener((){
      print('index = $selected');
      setState(() {
        selected=_controller.index;
      });
    });

    super.initState();
    navigatorKey = GlobalKey<NavigatorState>();
    initPlatformState(context);
  }
  Future<void> initPlatformState(BuildContext context) async {
    if (!mounted) return;

    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    OneSignal.shared.setRequiresUserPrivacyConsent(_requireConsent);

    var settings = {
      OSiOSSettings.autoPrompt: false,
      OSiOSSettings.promptBeforeOpeningPushUrl: true
    };

    OneSignal.shared.setNotificationReceivedHandler((OSNotification notification) {
       // play the clip
        String url=notification.payload.additionalData['clipUrl'];
        audioPlugin.play(url);
    });

    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {

      showMessage(navigatorKey.currentContext,result.notification.payload.title,result.notification.payload.subtitle);

    });

    OneSignal.shared
        .setInAppMessageClickedHandler((OSInAppMessageAction action) {

    });

    OneSignal.shared
        .setSubscriptionObserver((OSSubscriptionStateChanges changes) {
      print("SUBSCRIPTION STATE CHANGED: ${changes.jsonRepresentation()}");
    });

    OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
      print("PERMISSION STATE CHANGED: ${changes.jsonRepresentation()}");
    });

    OneSignal.shared.setEmailSubscriptionObserver(
            (OSEmailSubscriptionStateChanges changes) {
          print("EMAIL SUBSCRIPTION STATE CHANGED ${changes.jsonRepresentation()}");
        });

    await OneSignal.shared
        .init("bead113a-0024-4ffc-833b-75f1aff226ed", iOSSettings: settings);

    OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.notification);
    var status = await OneSignal.shared.getPermissionSubscriptionState();
    playerId= status.subscriptionStatus.userId;
    EmployeeOperations empOp=new EmployeeOperations();
    await empOp.savePlayerId(playerId);
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body: TabBarView(
            controller: _controller,
            children: _allPages.map<Widget>((_Page page) {
              return SafeArea(
                top: false,
                bottom: false,
                child: Container(
                    key: ObjectKey(page.widget),
                    padding: const EdgeInsets.all(12.0),
                    child: page.widget
                ),
              );
            }).toList(),
          ),
          bottomNavigationBar: BottomAppBar(
            color: Colors.transparent,
            child: Container(
              height: 10.0.h,
              decoration: BoxDecoration(
                  color: Constants.primary,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  )
              ),
              child: new Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                      icon: Icon(Icons.home_outlined,color: selected==0?Colors.greenAccent:Colors.white,size: 5.0.h,),
                      onPressed: () {
                        _controller.index=0;
                        setState(() {
                          selected=0;
                        });
                      }
                  ),
                  IconButton(
                      icon: Icon(Icons.person_pin,color: selected==1?Colors.greenAccent:Colors.white,size: 5.0.h),
                      onPressed: () {
                        _controller.index=1;
                        setState(() {
                          selected=1;
                        });
                  }
                  ),
                ],
              ),
            ),
          )
      ),
    );
  }
  void showMessage(BuildContext context,String title,String desc)async{
    await Alert(
      context: context,
      type: AlertType.info,
      title: title,
      desc: desc,
      buttons: [
        DialogButton(
          child: Text(
            "Stop",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed:()async{
            Navigator.of(context, rootNavigator: true).pop();
          },
          color: Constants.primary,
          radius: BorderRadius.circular(10.0),
        ),
      ],
    ).show();

    Future.delayed(const Duration(milliseconds: 1000), () {
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    });
  }
}
