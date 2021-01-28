import 'package:flutter/material.dart';
class CompanyRegistration extends StatefulWidget {
  @override
  _CompanyRegistrationState createState() => _CompanyRegistrationState();
}

class _CompanyRegistrationState extends State<CompanyRegistration> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       home: Scaffold(
           body: Center(
               child: Text("Company registration"),
           ),
       ),
    );
  }
}
