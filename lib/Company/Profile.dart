import 'package:emergency_app/Constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
class CompanyProfile extends StatefulWidget {
  @override
  _CompanyProfileState createState() => _CompanyProfileState();
}

class _CompanyProfileState extends State<CompanyProfile> {
  TextEditingController name=new TextEditingController();
  TextEditingController phone=new TextEditingController();
  TextEditingController address=new TextEditingController();
  @override
  void iniState(){
    name.text="Jhon Smith";
     super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          resizeToAvoidBottomPadding: false,
          body: Container(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                      SizedBox(height: 10.0.h,),
                      Icon(Icons.person_pin,size: 20.0.h,),
                      SizedBox(height: 5.0.h,),
                      Padding(
                        padding: const EdgeInsets.only(left:15.0),
                        child: Row(
                          children: [
                              Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   SizedBox(height: 3.5.h,),
                                   Text("Name",style: GoogleFonts.lato(fontSize: 20,fontWeight: FontWeight.bold),),
                                   SizedBox(height: 4.0.h,),
                                   Text("Address",style: GoogleFonts.lato(fontSize: 20,fontWeight: FontWeight.bold),),
                                   SizedBox(height: 4.0.h,),
                                   Text("Phone",style: GoogleFonts.lato(fontSize: 20,fontWeight: FontWeight.bold),),
                                 ],
                              ),
                              SizedBox(width: 15,),
                              Column(
                                 children: [
                                   SizedBox(
                                     width: 60.0.w,
                                     child: TextField(
                                       controller: name,
                                       style: TextStyle( decoration: TextDecoration.none),
                                       decoration: InputDecoration(
                                           suffixIcon: Icon(Icons.edit,color: Colors.blue,)
                                       ),
                                     ),
                                   ),
                                   SizedBox(
                                     width: 60.0.w,
                                     child: TextField(
                                       controller: name,
                                       style: TextStyle( decoration: TextDecoration.none),
                                       decoration: InputDecoration(
                                           suffixIcon: Icon(Icons.edit,color: Colors.blue,)
                                       ),
                                     ),
                                   ),
                                   SizedBox(
                                     width: 60.0.w,
                                     child: TextField(
                                       controller: name,
                                       style: TextStyle( decoration: TextDecoration.none),
                                       decoration: InputDecoration(
                                           suffixIcon: Icon(Icons.edit,color: Colors.blue,)
                                       ),
                                     ),
                                   )

                                 ],
                              )
                          ],
                        ),
                      ),
                    SizedBox(height: 5.0.h,),
                    RaisedButton(
                       color: Constants.secondary,
                       shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                       ),
                       child: Text("Logout",style: GoogleFonts.lato(color: Colors.white,),),
                       onPressed: (){},
                    )
                  ],
              ),
          ),
        )
    );
  }
}
