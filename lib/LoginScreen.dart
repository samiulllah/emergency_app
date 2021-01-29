import 'package:emergency_app/Constants.dart';
import 'package:emergency_app/Employee/RegistrationScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import 'Company/RegistrationScreen.dart';
class LoginScreen extends StatefulWidget {
  // this variable is used to show guide for users and appropriate registration page
  int userType;
  LoginScreen({this.userType});
  @override
  _LoginScreenState createState() => _LoginScreenState(userType: userType);
}

class _LoginScreenState extends State<LoginScreen> {
  int userType;
  TextEditingController email=new TextEditingController();
  TextEditingController password=new TextEditingController();

  _LoginScreenState({this.userType});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       home: Scaffold(
           backgroundColor: Constants.primary,
           body: SingleChildScrollView(
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               crossAxisAlignment: CrossAxisAlignment.center,
               children: <Widget>[
                 SizedBox(height: 20.0.h,),
                 Text(
                   "LOGIN",
                   style: GoogleFonts.lato(fontSize: 24,fontWeight: FontWeight.bold,letterSpacing: .5,color: Colors.white),
                 ),
                 SizedBox(height: 10.0.h),
                 Center(
                   child: Container(
                     width: 90.0.w,
                     height: 7.0.h,
                     alignment: Alignment.center,
                     padding: EdgeInsets.only(left: 20,right: 20),
                     child: TextField(
                       controller: email,
                       textAlignVertical: TextAlignVertical.center,
                       textAlign: TextAlign.left,
                       keyboardType: TextInputType.emailAddress,
                       decoration: new InputDecoration(
                           border: new OutlineInputBorder(
                             borderRadius: const BorderRadius.all(
                               const Radius.circular(25.0),
                             ),
                              borderSide:  BorderSide(color:Constants.secondary)
                           ),
                           filled: true,
                           hintStyle: new TextStyle(color: Colors.grey[800]),
                           hintText: " Enter email",
                           fillColor: Colors.white
                       ),
                     ),
                   ),
                 ),
                 SizedBox(height: 5.0.h,),
                 Center(
                   child: Container(
                     width: 90.0.w,
                     height: 7.0.h,
                     padding: EdgeInsets.only(left: 20,right: 20),
                     child: TextField(
                       controller: password,
                       obscureText: true,
                       decoration: new InputDecoration(
                           border: new OutlineInputBorder(
                             borderRadius: const BorderRadius.all(
                               const Radius.circular(25.0),
                             ),
                             borderSide:  BorderSide(color:Constants.secondary)
                           ),
                           filled: true,
                           hintText: " Enter password",
                           fillColor: Colors.white),
                     ),
                   ),
                 ),
                 SizedBox(height: 5.0.h,),
                 OutlineButton(
                   color:Colors.white,
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(18.0),
                   ),
                   borderSide: BorderSide(color: Colors.white, width: 2,
                       style: BorderStyle.solid),
                   child: SizedBox(
                       width: 40.0.w,
                       height: 6.5.h,
                       child: Center(child: Text("Submit",style: GoogleFonts.breeSerif(fontSize: 14.0.sp,letterSpacing: .5,color: Colors.white),))
                   ),
                   onPressed: (){},
                 ),
                 SizedBox(height: 5.0.h,),
                 Text("-----------OR-----------",style: GoogleFonts.lato(color: Colors.white,fontSize: 16),),
                 SizedBox(height: 5.0.h,),
                 GestureDetector(
                     onTap: (){
                        if(userType==0){
                            // company registration
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) => CompanyRegistration()));
                        }
                        else{
                          // employee registration
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) => EmployeeRegistration()));
                        }
                        print('value of user type = $userType');
                     },
                     child: Text("Doesn't have account? Register",style: GoogleFonts.lato(color: Colors.white,fontSize: 16),)
                 )
               ],
             ),
           ),
       ),
    );
  }
}
