import 'dart:async';

import 'package:emergency_app/Company/Home.dart';
import 'package:emergency_app/Constants.dart';
import 'package:emergency_app/Employee/Home.dart';
import 'package:emergency_app/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(                           //return LayoutBuilder
        builder: (context, constraints) {
      return OrientationBuilder( //return OrientationBuilder
        builder: (context, orientation) {
          //initialize SizerUtil()
          SizerUtil().init(constraints, orientation); //initialize SizerUtil
          return MaterialApp(
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: FlashScreen(),
          );
        },
      );
    });
  }
}
class FlashScreen extends StatefulWidget {
  @override
  _FlashScreenState createState() => _FlashScreenState();
}

class _FlashScreenState extends State<FlashScreen> {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    Timer( Duration(seconds: 6),
            () {
          bool login=false;
          if(login) {
            int userType = 0; // 0 for company 1 for administrator 2 for employee
            // check if current user logged in nav to home
            // check user type and navigate appropriately
            if (userType == 1) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => CompanyHome()));
            }
            else {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => EmployeeHome()));
            }
          }
          else {
            //not login nav to continue as company, administrator or employee.
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => EmpOrAdmin()));
          }
        }
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.primary,
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20.0.h,),
            Center(child: Image.asset('assets/logo.png',width: 20.0.h,height: 20.0.h,fit: BoxFit.fill,)),
            SizedBox(height: 20,),
            Center(
               child: Text(
                      "Emergency",
                      style: GoogleFonts.lato(textStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.w600, letterSpacing: .5,fontSize: 30.0.sp))
               )
            ),
            Spacer(),
            Center(
                child: Text("Loading...",style: GoogleFonts.lato(textStyle: TextStyle(color: Colors.white, letterSpacing: .5,fontSize: 16.0.sp)))
            ),
            SizedBox(height: 15.0.h,),
          ],
      ),
    );
  }
}

class EmpOrAdmin extends StatefulWidget {
  @override
  _EmpOrAdminState createState() => _EmpOrAdminState();
}

class _EmpOrAdminState extends State<EmpOrAdmin> {
  @override
  void initState(){
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Constants.primary,
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                 child: Text("Continue As",style: TextStyle(fontSize: 26.0.sp,color:Colors.white),),
              ),
              SizedBox(height: 10.0.h,),
              roundButton(title: "Company or Admin",onTap: (){
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (BuildContext context) => LoginScreen(userType: 0,)));
              }),
              SizedBox(height: 20,),
              Center(
                 child: Text("OR",style: GoogleFonts.lato(fontSize: 14.0.sp,color: Colors.white),),
              ),
              SizedBox(height: 20,),
              roundButton(title: "Employee or Contractor",onTap: (){
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (BuildContext context) => LoginScreen(userType: 2,)));
              }),
            ],
        ),
      ),
    );
  }
  Widget roundButton({String title, var onTap}){
      return RaisedButton(
        color: Colors.white ,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
        ),
        child: SizedBox(
            width: 60.0.w,
            height: 6.5.h,
            child: Center(child: Text(title,style: GoogleFonts.lato(fontSize: 14.0.sp,color: Constants.secondary),))
        ),
        onPressed: onTap,
      );
  }
}



