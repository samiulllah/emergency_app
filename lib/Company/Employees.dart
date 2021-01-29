import 'package:flutter/material.dart';

class CompanyEmployees extends StatefulWidget {
  @override
  _CompanyEmployeesState createState() => _CompanyEmployeesState();
}

class _CompanyEmployeesState extends State<CompanyEmployees> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          body: Center(child:Text("Company employees")),
        )
    );
  }
}
