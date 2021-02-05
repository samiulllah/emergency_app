import 'package:emergency_app/Constants.dart';
import 'package:emergency_app/Employee/Home.dart';
import 'package:emergency_app/Employee/Profile.dart';
import 'package:emergency_app/Employee/Setting.dart';
import 'package:flutter/material.dart';
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
}
