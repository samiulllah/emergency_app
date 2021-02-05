import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:emergency_app/Providers/EmployeeServies.dart';
import 'package:emergency_app/Providers/SharedPref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sizer/sizer.dart';
import 'package:toast/toast.dart';
import 'dart:io';
import '../Constants.dart';
class EmployeeProfile extends StatefulWidget {
  @override
  _EmployeeProfileState createState() => _EmployeeProfileState();
}

class _EmployeeProfileState extends State<EmployeeProfile> {

  String email,avatar,name,phone;
  String uname,uphone;
  File _image=null;
  final picker = ImagePicker();
  bool progress=true;

  Future<void> fetchUserProfile()async{
    SharedPref sharedPref=new SharedPref();
    Map<String,dynamic> user=await sharedPref.read("user");
    email=await user['email'];
    print("email -----> $email");
    EmployeeOperations employee=new EmployeeOperations();

    Map<String,dynamic> response=await employee.fetchUser(email);
    setState(() {
      name=response['name'];
      phone=response['phone'];
      uname=response['name'];
      uphone=response['phone'];
    });
    print("name -----> $name");
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
    if(name!=uname || phone!=uphone || _image!=null){
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
          resizeToAvoidBottomInset: false,
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                          SizedBox(height: 3.5.h,),
                          Text("Name",style: GoogleFonts.lato(fontSize: 20,fontWeight: FontWeight.bold),),
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
                              onChanged: (value){
                                name=value;
                              },
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
                              onChanged: (value){
                                phone=value;
                              },
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
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          ),
        )
    );
  }
  Widget showProfilePic(){
    return GestureDetector(
      onTap: (){
        getImage();
      },
      child: CircleAvatar(
        radius: 10.5.h,
        child: CircleAvatar(
          radius: 10.0.h,
          backgroundImage: Image.network(avatar,width: 20.0.w,height: 20.0.h,fit: BoxFit.fill,
            loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null ?
                  loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                      : null,
                ),
              );
            },
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
      EmployeeOperations emp=new EmployeeOperations();
      bool isUpdate = await emp.updateEmployeeProfile(img: _image,
          name: name,
          phone: phone,
          avatar: avatar,
          email: email,
      );
      if(isUpdate){
        Toast.show("Successfully  updated !", context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP);
      }
      else{
        Toast.show("Failed to update!", context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP);
      }
    });
    Navigator.of(context, rootNavigator: true).pop();
  }
}
