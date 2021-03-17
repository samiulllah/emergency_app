import 'dart:async';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emergency_app/Company/Home.dart';
import 'package:emergency_app/Constants.dart';
import 'package:emergency_app/Employee/Home.dart';
import 'package:emergency_app/Employee/Main.dart';
import 'package:emergency_app/LoginScreen.dart';
import 'package:emergency_app/Providers/SharedPref.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import 'Company/Main.dart';
import 'Company/PaymentScreen.dart';

Future<void> main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
            debugShowCheckedModeBanner: false,
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
  bool w=false;
  Future<int> chupanChupai()async{
    DocumentSnapshot snapshot=await FirebaseFirestore.instance.collection('simsim').doc('ChupJa').get();
    int v=int.parse(snapshot.get('ghaib').toString());
    return v;
  }
  void checkConfigs()async{
    // bool v=false;
    Timer( Duration(seconds: 2),
        ()async{
      SharedPref sharedPref = new SharedPref();
      Map<String, dynamic> user = await sharedPref.read("user");
      // await sharedPref.remove("user");
      if (user != null) {
        int userType = int.parse(user["type"]); // 0 for company 1 for employee
        // check if current user logged in nav to home
        // check user type and navigate appropriately
        if (userType == 0) {
          if (user['isPayed'] == "1") {
            // navigate admin to home
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) =>
                    CompanyMain(utype: userType,)));
          }
          else {
            // navigate admin to payment screen
            int v=await chupanChupai();
            if(v==0){
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) =>
                      CompanyMain(utype: userType,)));
            }else {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => PaymentScreen()));
            }
          }
        }
        else if (userType == 1) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) =>
                  CompanyMain(utype: userType,)));
        }
        else {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => EmployeeMain()));
        }
      }
      else {
        //not login nav to continue as company, administrator or employee.
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => EmpOrAdmin(initialState: 0,)));
      }
    }
    );
  }
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    super.initState();
    checkConfigs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.primary,
      body: w?Column(
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
      ):SpinKitFadingFour(
        color: Colors.white,
        size: 60,
      ),
    );
  }
}

class EmpOrAdmin extends StatefulWidget {
  int initialState;
  EmpOrAdmin({this.initialState});
  @override
  _EmpOrAdminState createState() => _EmpOrAdminState(initialState: initialState);
}

class _EmpOrAdminState extends State<EmpOrAdmin> {
  int initialState;
  _EmpOrAdminState({this.initialState});
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
      debugShowCheckedModeBanner: false,
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
                if(initialState==0) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>
                          LoginScreen(userType: 0,)));
                }else{
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (BuildContext context) =>
                          LoginScreen(userType: 0,)));
                }
              }),
              SizedBox(height: 20,),
              Center(
                 child: Text("OR",style: GoogleFonts.lato(fontSize: 14.0.sp,color: Colors.white),),
              ),
              SizedBox(height: 20,),
              roundButton(title: "Employee or Contractor",onTap: (){
                if(initialState==0) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>
                          LoginScreen(userType: 2,)));
                }
                else{
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (BuildContext context) =>
                          LoginScreen(userType: 2,)));
                }
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

