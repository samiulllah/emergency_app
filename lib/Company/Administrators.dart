import 'package:flutter/material.dart';

class CompanyAdministrators extends StatefulWidget {
  @override
  _CompanyAdministratorsState createState() => _CompanyAdministratorsState();
}

class _CompanyAdministratorsState extends State<CompanyAdministrators> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       home: Scaffold(
          body: Center(
             child: Text("hi admins"),
          ),
       ),
    );
  }
}
