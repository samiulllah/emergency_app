import 'package:emergency_app/Company/QrCode.dart';
import 'package:emergency_app/Company/Employees.dart';
import 'package:emergency_app/Company/Home.dart';
import 'package:emergency_app/Company/Profile.dart';
import 'package:emergency_app/Company/Setting.dart';
import 'package:emergency_app/Constants.dart';
import 'package:emergency_app/Providers/SharedPref.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

class CompanyMain extends StatefulWidget {
  int utype;
  CompanyMain({this.utype});
  @override
  _CompanyMainHomeState createState() => _CompanyMainHomeState(utype: utype);
}
class _Page {
  _Page({this.widget});
  final StatefulWidget widget;
}
class _CompanyMainHomeState extends State<CompanyMain>  with SingleTickerProviderStateMixin{
  var _controller;
  List<_Page> _allPages;
  int selected=0;
  int utype;
  _CompanyMainHomeState({this.utype});

  @override
  void initState(){
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    _allPages= <_Page>[
      _Page(widget: CompanyHome(utype: utype,)),
      _Page(widget: CompanyEmployees()),
      _Page(widget: CompanyQr()),
      _Page(widget: CompanySettingScreen(utype: utype,))
    ];
    _controller = TabController(vsync: this, length: _allPages.length);
    _controller.addListener((){
      print('index = $selected');
       setState(() {
            selected=_controller.index;
       });
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
                  if(utype==0)IconButton(
                      icon: Icon(Icons.people_outline,color: selected==1?Colors.greenAccent:Colors.white,size: 5.0.h),
                      onPressed: () {
                        _controller.index=1;
                        setState(() {
                          selected=1;
                        });
                      }
                 ),
                 IconButton(
                      icon: Icon(Icons.qr_code,color: selected==2?Colors.greenAccent:Colors.white,size: 5.0.h),
                      onPressed: () {
                        _controller.index=2;
                        setState(() {
                          selected=2;
                        });
                      }
                ),
                  IconButton(
                    icon: Icon(Icons.person_pin,color: selected==3?Colors.greenAccent:Colors.white,size: 5.0.h),
                    onPressed: () {
                      _controller.index=3;
                      setState(() {
                        selected=3;
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
}
