import 'package:emergency_app/Constants.dart';
import 'package:emergency_app/Providers/SharedPref.dart';
import 'package:emergency_app/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CompanyProfile extends StatefulWidget {
  int userType;
  String name,phone,address;
  CompanyProfile({this.userType,this.name,this.phone,this.address});
  @override
  _CompanyProfileState createState() => _CompanyProfileState(userType: userType,name: name,phone: phone,address: address);
}

class _CompanyProfileState extends State<CompanyProfile> {
  int userType;
  String name,phone,address;
  File _image=null;
  final picker = ImagePicker();

  _CompanyProfileState({this.userType,this.name,this.phone,this.address});


  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }
  @override
  void iniState(){
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
                      _image!=null?
                           GestureDetector(
                             onTap: (){
                               getImage();
                             },
                             child: CircleAvatar(
                               radius: 10.5.h,
                               child: CircleAvatar(
                                 radius: 10.0.h,
                                 backgroundImage: Image.file(_image,width: 20.0.w,height: 20.0.h,fit: BoxFit.fill,).image,
                               ),
                             ),
                           )
                          :GestureDetector(
                          onTap: (){
                            getImage();
                          },
                          child: Icon(Icons.person_pin,size: 20.0.h,)
                      ),
                      SizedBox(height: 5.0.h,),
                      Padding(
                        padding: const EdgeInsets.only(left:15.0),
                        child: Row(
                          children: [
                              Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   SizedBox(height: 2.0.h,),
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
                                       textAlignVertical: TextAlignVertical.bottom,
                                       controller: TextEditingController(text: name),
                                       style: TextStyle( decoration: TextDecoration.none),
                                       decoration: InputDecoration(
                                           suffixIcon: Icon(Icons.edit,color: Colors.blue,)
                                       ),
                                     ),
                                   ),
                                   SizedBox(
                                     width: 60.0.w,
                                     child: TextField(
                                       textAlignVertical: TextAlignVertical.bottom,
                                       controller: TextEditingController(text: address),
                                       style: TextStyle( decoration: TextDecoration.none),
                                       decoration: InputDecoration(
                                           suffixIcon: Icon(Icons.edit,color: Colors.blue,)
                                       ),
                                     ),
                                   ),
                                   SizedBox(
                                     width: 60.0.w,
                                     child: TextField(
                                       textAlignVertical: TextAlignVertical.bottom,
                                       controller: TextEditingController(text: phone),
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
                       onPressed: ()async{
                         SharedPref sharedPref=new SharedPref();
                         await sharedPref.remove("user");
                         Navigator.of(context).pushReplacement(MaterialPageRoute(
                             builder: (BuildContext context) => EmpOrAdmin()));
                       },
                    )
                  ],
              ),
          ),
        )
    );
  }

}
