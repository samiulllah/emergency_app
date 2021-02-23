import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:emergency_app/Constants.dart';
import 'package:emergency_app/Providers/CompanyOperations.dart';
import 'package:emergency_app/Providers/SharedPref.dart';
import 'package:emergency_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuts_activity_indicator/nuts_activity_indicator.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sizer/sizer.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';


class CompanyProfile extends StatefulWidget {
  int userType;
  CompanyProfile({this.userType});
  @override
  _CompanyProfileState createState() => _CompanyProfileState(userType: userType);
}

class _CompanyProfileState extends State<CompanyProfile> {
  int userType;
  String email,avatar,name,address,phone;
  String uname,uphone,uaddress;
  File _image=null;
  final picker = ImagePicker();
  bool progress=true;
  _CompanyProfileState({this.userType,this.email});

  Future<void> fetchUserProfile()async{
    SharedPref sharedPref=new SharedPref();
    Map<String,dynamic> user=await sharedPref.read("user");
    email=await user['email'];
    CompanyOperations comapny=new CompanyOperations();

     Map<String,dynamic> response=await comapny.fetchUser(email, userType);
     setState(() {
         name=response['name'];
         phone=response['phone'];
         address=response['address'];
         uname=response['name'];
         uphone=response['phone'];
         uaddress=response['address'];
     });
     if(response.containsKey("avatar")){
       setState(() {
          avatar=response['avatar'];
       });
     }
     else{
       setState(() {
           avatar=null;
       });
     }
     setState(() {
        progress=false;
     });
  }
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
  void initState(){
     fetchUserProfile();
     BackButtonInterceptor.add(myInterceptor);
     super.initState();
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }
  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info)  {
    if(isChanged()) {
      showMessage(context);
      return true;
    }
    return false;
  }
  bool isChanged(){
     if(name!=uname || address!=uaddress || phone!=uphone || _image!=null){
        return true;
     }
     else{
       return false;
     }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          resizeToAvoidBottomPadding: false,
          body: Container(
            padding: EdgeInsets.all(15),
              child:!progress? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 2.0.h,),
                    GestureDetector(
                      onTap: ()async{
                        if(isChanged()) {
                          await showMessage(context);
                        }
                        else{
                           Navigator.pop(context);
                        }
                      },
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: 10,),
                            Icon(Icons.arrow_back,size: 20,),
                            SizedBox(width: 5,),
                            Text("Back")
                          ]),
                    ),
                      SizedBox(height: 10.0.h,),
                      // showing image
                      _image==null?avatar!=null?
                      showProfilePic():GestureDetector(
                          onTap: (){
                            getImage();
                          },
                          child: Icon(Icons.person_pin,size: 20.0.h,)
                      ):CircleAvatar(
                        radius: 10.5.h,
                        child: CircleAvatar(
                          radius: 10.0.h,
                          backgroundImage: Image.file(_image,width: 20.0.w,height: 20.0.h,fit: BoxFit.fill,).image,
                        ),
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
                                   if(userType==0)SizedBox(height: 4.0.h,),
                                   if(userType==0)Text("Address",style: GoogleFonts.lato(fontSize: 20,fontWeight: FontWeight.bold),),
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
                                       onChanged: (value){
                                         name=value;
                                       },
                                       textAlignVertical: TextAlignVertical.bottom,
                                       controller: TextEditingController(text: name),
                                       style: TextStyle( decoration: TextDecoration.none),
                                       decoration: InputDecoration(
                                           suffixIcon: Icon(Icons.edit,color: Colors.blue,)
                                       ),
                                     ),
                                   ),
                                  userType==0? SizedBox(
                                     width: 60.0.w,
                                     child: TextField(
                                       onChanged: (value){
                                         address=value;
                                       },
                                       textAlignVertical: TextAlignVertical.bottom,
                                       controller: TextEditingController(text: address),
                                       style: TextStyle( decoration: TextDecoration.none),
                                       decoration: InputDecoration(
                                           suffixIcon: Icon(Icons.edit,color: Colors.blue,)
                                       ),
                                     ),
                                   ):Container(),
                                   SizedBox(
                                     width: 60.0.w,
                                     child: TextField(
                                       onChanged: (value){
                                         phone=value;
                                       },
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
                       child: Text("Go Back",style: GoogleFonts.lato(color: Colors.white,),),
                       onPressed: ()async{
                         if(isChanged()) {
                           await showMessage(context);
                         }else{
                           Navigator.pop(context);
                         }
                         // Navigator.of(context).pop();
                       },
                    )
                  ],
              ):Center(
                 child: NutsActivityIndicator(
                   radius: 20,
                   activeColor: Colors.indigo,
                   inactiveColor: Colors.red,
                   tickCount: 11,
                   startRatio: 0.55,
                   animationDuration: Duration(milliseconds: 123),
                 ),
              ),
          ),
        )
    );
  }

  Widget showProfilePic(){
    return  GestureDetector(
      onTap: (){
        getImage();
      },
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 8.0.h,
        backgroundImage: Image.asset('assets/loading.gif').image,
        child: CircleAvatar(
          radius: 8.0.h,
          backgroundColor: Colors.transparent,
          backgroundImage: NetworkImage(avatar),
        ),
      ),
    );

    return GestureDetector(
      onTap: (){
        getImage();
      },
      child: CircleAvatar(
        radius: 10.5.h,
        child: CircleAvatar(
          radius: 10.0.h,
          backgroundColor: Colors.transparent,
          backgroundImage: FadeInImage.assetNetwork(
            placeholder: 'assets/user.png',
            image: avatar,
          ).image,
        ),
      ),
    );
  }
  void showMessage(BuildContext context)async{
    bool opt=false;
    await Alert(
      context: context,
      type: AlertType.info,
      title: "Do you want to save changes ?",
      buttons: [
        DialogButton(
          child: Text(
            "Yes",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed:()async{
            opt=true;
            Navigator.of(context, rootNavigator: true).pop();
          },
          color: Constants.primary,
          radius: BorderRadius.circular(10.0),
        ),
        DialogButton(
          child: Text(
            "No",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            opt=false;
            Navigator.of(context, rootNavigator: true).pop();
          },
          color: Constants.secondary,
          radius: BorderRadius.circular(10.0),
        )
      ],
    ).show();
    if(opt){
      await updatePopup(context);
    }
    Navigator.of(context).pop();
  }
  updatePopup(BuildContext context)async{

    AlertDialog alert = AlertDialog(
      content: SizedBox(
        width: 100,
        height:40,
        child:SpinKitDualRing (
          color: Colors.pinkAccent,
          size: 30,
        ),
      ),
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
    await Future.delayed(Duration(seconds: 1),()async{
      CompanyOperations comp=new CompanyOperations();
      bool isUpdate = await comp.updateCompanyProfile(img: _image,
            name: name,
            phone: phone,
            address: address,
            avatar: avatar,
            email: email,
            userType: userType
         );
      if(isUpdate){
         Toast.show("Successfully  updated !", context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP);
      }
      else{

      }
    });
    Navigator.of(context, rootNavigator: true).pop();
  }
}
