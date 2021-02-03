import 'package:emergency_app/Company/Administrators.dart';
import 'package:emergency_app/Company/Profile.dart';
import 'package:emergency_app/Constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
class CompanySettingScreen extends StatefulWidget {
  @override
  _CompanySettingScreenState createState() => _CompanySettingScreenState();
}

class _CompanySettingScreenState extends State<CompanySettingScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
           body: Container(
             decoration: BoxDecoration(
               borderRadius: BorderRadius.all(Radius.circular(20)),
               color: Colors.white,
               boxShadow: [
                 BoxShadow(
                   color: Colors.grey[300],
                   blurRadius: 2.0,
                   spreadRadius: 0.0,
                   offset: Offset(2.0, 2.0), // shadow direction: bottom right
                 )
               ],
             ),
             child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Colors.pink,
                    ),
                    width: 100.0.w,
                    height: 30.0.h,
                    child: Center(child: Icon(Icons.settings,size: 25.0.w,color: Colors.white,)),
                  ),
                  SizedBox(height: 3.0.h,),
                  settingItem(title:"Administrators",icon:Icon(Icons.people,size: 10.0.w,color: Constants.primary,),callback:(){
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => CompanyAdministrators()));
                  }),
                  settingItem(title:"Profile",icon:Icon(Icons.person_sharp,size: 10.0.w,color: Constants.primary),callback:(){
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => CompanyProfile()));
                  }),
                  settingItem(title:"About us",icon:Icon(Icons.contact_mail_outlined,size:10.0.w,color: Constants.primary),callback:(){

                  }),
                  settingItem(title:"Logout",icon:Icon(Icons.logout,size:10.0.w,color: Constants.primary),callback:(){

                  }),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Text("© 2021 Emergency.  All rights reserved. ",style: TextStyle(color: Colors.grey),),
                    ),
                  ),
                  SizedBox(height: 3.0.h,),
                ],
             ),
           ),
        ),
    );
  }
  Widget settingItem({String title,Icon icon,Function callback}){
     return GestureDetector(
       onTap: callback,
       child: Container(
         padding: EdgeInsets.only(top: 10,bottom: 10),
         margin: EdgeInsets.only(top: 10),
         decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
           color: Colors.white,
         ),
          child: Row(
               children: [
                   SizedBox(width: 3.0.w,),
                   icon,
                   SizedBox(width: 3.0.w,),
                   Text(title,style: GoogleFonts.lato(fontSize: 16,fontWeight: FontWeight.bold),),
                   Spacer(),
                   Icon(Icons.arrow_forward_ios_sharp,color: Colors.blue),
                   SizedBox(width: 3.0.w,),
               ],
          ),
       ),
     );
  }
}
