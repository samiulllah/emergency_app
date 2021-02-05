import 'package:emergency_app/Company/Main.dart';
import 'package:emergency_app/Company/PaymentScreen.dart';
import 'package:emergency_app/Constants.dart';
import 'package:emergency_app/Employee/Main.dart';
import 'package:emergency_app/Employee/RegistrationScreen.dart';
import 'package:emergency_app/Employee/ScanQr.dart';
import 'package:emergency_app/Providers/EmployeeServies.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sizer/sizer.dart';

import 'Company/RegistrationScreen.dart';
import 'Providers/CompanyOperations.dart';
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
  CompanyOperations company;

  bool progress=false;
  @override
  void initState(){
    company=new CompanyOperations();
    super.initState();
  }
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
                       textAlign: TextAlign.left,
                       keyboardType: TextInputType.emailAddress,
                       decoration: new InputDecoration(
                           contentPadding: EdgeInsets.only(top: 12,left: 10),
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
                          contentPadding: EdgeInsets.only(top: 12,left: 10),
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
                 !progress?OutlineButton(
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
                   onPressed: ()async{
                     //start progress
                     setState(() {
                       progress=true;
                     });
                     // handle login
                     if(userType==0){
                       // admin
                       List<String> done=await company.handleLogin(email: email.text,password: password.text);
                       if(done[0]=="88"){
                         showMessage(context, "The account doen't exists !");
                         setState(() {
                           progress=false;
                         });
                         return;
                       }
                       if(done[0]=="1"){
                          // checking user type
                          if(done[2]=="0") {   // company
                            if (done[1] == "1") {
                              // navigate admin to home
                              Navigator.of(context).pushReplacement(MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      CompanyMain(utype: 0,)));
                            }
                            else {
                              // navigate admin to payment screen
                              Navigator.of(context).pushReplacement(MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      PaymentScreen()));
                            }
                          }
                          else if(done[2]=="1"){
                            // admin
                            Navigator.of(context).pushReplacement(MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    CompanyMain(utype: 1,)));
                          }
                          else{
                            showMessage(context, "This account isn't associated with admin or company !");
                          }
                       }
                       else{
                         showMessage(context, done[1]);
                       }
                     }
                     else{
                       // employee
                        EmployeeOperations empOps=new EmployeeOperations();
                        List<String> done=await empOps.handleLogin(email: email.text,password: password.text);
                        if(done[0]=="3"){
                          showMessage(context, "The account doesn't exists !");
                          setState(() {
                            progress=false;
                          });
                          return;
                        }
                        if(done[0]=="1"){
                          Navigator.of(context).pushReplacement(MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  EmployeeMain()));
                        }
                        else{
                          showMessage(context, done[1]);
                        }
                     }
                     //stop progress
                     setState(() {
                       progress=false;
                     });
                     // clear fields
                     email.text="";
                     password.text="";
                   },
                 ):CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),),
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
                              builder: (BuildContext context) => ScanQr()));
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
  void showMessage(BuildContext context,String message){
    Alert(

      context: context,
      type: AlertType.info,
      title: "Login Failed",
      desc: message,
      buttons: [
        DialogButton(
          child: Text(
            "Try Again",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () =>    Navigator.of(context, rootNavigator: true).pop(),
          color: Color.fromRGBO(0, 179, 134, 1.0),
          radius: BorderRadius.circular(0.0),
        ),
      ],
    ).show();
  }

}
