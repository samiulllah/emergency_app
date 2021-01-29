import 'package:emergency_app/Company/Emergency.dart';
import 'package:emergency_app/Company/Employees.dart';
import 'package:emergency_app/Company/Home.dart';
import 'package:emergency_app/Company/Profile.dart';
import 'package:flutter/material.dart';

class CompanyMain extends StatefulWidget {
  @override
  _CompanyMainHomeState createState() => _CompanyMainHomeState();
}
class _Page {
  _Page({this.widget});
  final StatefulWidget widget;
}
class _CompanyMainHomeState extends State<CompanyMain>  with SingleTickerProviderStateMixin{
  var _controller;
  List<_Page> _allPages;
  @override
  void initState(){
    _allPages= <_Page>[
      _Page(widget: CompanyHome()),
      _Page(widget: CompanyEmployees()),
      _Page(widget: CompnayEmgergency()),
      _Page(widget: CompanyProfile()),
    ];
    _controller = TabController(vsync: this, length: _allPages.length);

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
            child: new Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                    icon: Icon(Icons.home_outlined),
                    onPressed: () {

                }),
                IconButton(
                    icon: Icon(Icons.people_outline),
                    onPressed: () {

               }),
               IconButton(
                    icon: Icon(Icons.add_alert_outlined),
                    onPressed: () {
              }),
                IconButton(
                  icon: Icon(Icons.person_pin),
                )
              ],
            ),
          )
      ),
    );
  }
}
