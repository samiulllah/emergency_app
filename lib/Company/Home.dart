import 'package:flutter/material.dart';

class CompanyHome extends StatefulWidget {
  @override
  _CompanyHomeState createState() => _CompanyHomeState();
}
class _Page {
  _Page({this.widget});
  final StatelessWidget widget;
}
class _CompanyHomeState extends State<CompanyHome> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       home: Scaffold(
         body: Center(child:Text("Company Home")),
       )
    );
  }
}
