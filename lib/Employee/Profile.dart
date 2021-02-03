import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../Constants.dart';
class EmployeeProfile extends StatefulWidget {
  @override
  _EmployeeProfileState createState() => _EmployeeProfileState();
}

class _EmployeeProfileState extends State<EmployeeProfile> {
  TextEditingController name=new TextEditingController(text: "Jhonson");
  TextEditingController phone=new TextEditingController(text: "2343234233");
  TextEditingController address=new TextEditingController(text: "Mohalla Pari");
  @override
  void iniState(){
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          resizeToAvoidBottomInset: false,
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 3.0.h,),
                Stack(
                   children: [
                     Container(
                        width: 100.0.w,
                        height: 30.0.h,
                        decoration: BoxDecoration(
                           shape:BoxShape.rectangle,
                           borderRadius: BorderRadius.circular(30),
                           color: Colors.pink
                        ),
                     ),
                     Container(
                         margin: EdgeInsets.only(top: 5.0.h,left: 30.0.w),
                         child: Icon(Icons.person,size: 20.0.h,color: Colors.white,)
                     )
                   ],
                ),
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
                              controller: address,
                              style: TextStyle( decoration: TextDecoration.none),
                              decoration: InputDecoration(
                                  suffixIcon: Icon(Icons.edit,color: Colors.blue,)
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 60.0.w,
                            child: TextField(
                              controller: phone,
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
