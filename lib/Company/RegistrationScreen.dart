import 'package:emergency_app/Company/PaymentScreen.dart';
import 'package:emergency_app/Providers/CompanyOperations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sizer/sizer.dart';
import '../Constants.dart';
class CompanyRegistration extends StatefulWidget {
  @override
  _CompanyRegistrationState createState() => _CompanyRegistrationState();
}

class _CompanyRegistrationState extends State<CompanyRegistration> {

  // field controllers
  TextEditingController companyName=new TextEditingController();
  TextEditingController emailAddress=new TextEditingController();
  TextEditingController companyAddress=new TextEditingController();
  TextEditingController phoneNumber=new TextEditingController();
  TextEditingController password=new TextEditingController();
  CompanyOperations company;

  bool progress=false;
  @override
  void initState(){
     company=new CompanyOperations();
     super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Constants.primary,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 10.0.h,),
              Text(
                "Company Registration",
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
                    controller: companyName,
                    textAlignVertical: TextAlignVertical.center,
                    textAlign: TextAlign.left,
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
                        hintText: " Enter company name",
                        fillColor: Colors.white
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5.0.h),
              Center(
                child: Container(
                  width: 90.0.w,
                  height: 7.0.h,
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(left: 20,right: 20),
                  child: TextField(
                    controller: companyAddress,
                    textAlignVertical: TextAlignVertical.center,
                    textAlign: TextAlign.left,
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
                        hintText: " Enter Address",
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
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(left: 20,right: 20),
                  child: TextField(
                    controller: phoneNumber,
                    textAlignVertical: TextAlignVertical.center,
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.phone,
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
                        hintText: "Enter phone number",
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
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(left: 20,right: 20),
                  child: TextField(
                    controller: emailAddress,
                    textAlignVertical: TextAlignVertical.center,
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
                        hintText: "Enter email",
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
                        contentPadding: EdgeInsets.only(top: 20,left: 10),
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
                    child: Center(child: Text("Next",style: GoogleFonts.breeSerif(fontSize: 14.0.sp,letterSpacing: .5,color: Colors.white),))
                ),
                onPressed: ()async{
                  setState(() {
                      progress=true;
                  });
                  List<String> res=await company.handleSignUp(name: companyName.text,email: emailAddress.text,phone: phoneNumber.text
                                          ,address: companyAddress.text,password: password.text);
                  setState(() {
                    progress=false;
                  });
                  if(res[0]=="1") {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (BuildContext context) => PaymentScreen()));
                  }
                  else{
                     // toast error message
                    showMessage(context,res[1]);
                  }
                  // clear all
                  companyName.text="";
                  companyAddress.text="";
                  phoneNumber.text="";
                  emailAddress.text="";
                  password.text="";
                },
              ):CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),),

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
      title: "SignUp Failed",
      desc: message,
      buttons: [
        DialogButton(
          child: Text(
            "Try Again",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          color: Color.fromRGBO(0, 179, 134, 1.0),
          radius: BorderRadius.circular(0.0),
        ),
      ],
    ).show();
  }

}
