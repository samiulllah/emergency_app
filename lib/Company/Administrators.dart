import 'dart:async';

import 'package:emergency_app/Models/Employee.dart';
import 'package:emergency_app/Providers/CompanyOperations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuts_activity_indicator/nuts_activity_indicator.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:toast/toast.dart';
import '../Constants.dart';
import 'package:sizer/sizer.dart';

class CompanyAdministrators extends StatefulWidget {
  @override
  _CompanyAdministratorsState createState() => _CompanyAdministratorsState();
}

class _CompanyAdministratorsState extends State<CompanyAdministrators> {
  List<Employee> employees=[];
  bool progress=true;
  List<Employee> completeList=[];
  TextEditingController searchController=new TextEditingController();

  Future<void> getAllAdmins()async{
    CompanyOperations comp=new CompanyOperations();
    List<Employee> admins=await comp.getAllAdministrators();
    setState(() {
      employees=admins;
      completeList=admins;
      progress=false;
    });
  }

  @override
  void initState(){
    getAllAdmins();
     super.initState();
    searchController.addListener(() {
      filterList(searchController.text);
    });
  }
  @override
  void dispose(){
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
       home: Scaffold(
         body:Container(
           child:!progress?Column(
             children: [
               SizedBox(height: 2.0.h,),
               GestureDetector(
                 onTap: (){
                   Navigator.pop(context);
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
               completeList.length>0?SizedBox(height: 3.0.h,):Container(),
               completeList.length>0?Container(
                 width: 90.0.w,
                 height: 7.0.h,
                 alignment: Alignment.center,
                 padding: EdgeInsets.only(left: 20,right: 20),
                 child: TextField(
                   controller: searchController,
                   textAlignVertical: TextAlignVertical.center,
                   textAlign: TextAlign.left,
                   keyboardType: TextInputType.emailAddress,
                   decoration: new InputDecoration(
                       suffixIcon: Icon(Icons.search),
                       contentPadding: EdgeInsets.only(top: 12,left: 10),
                       border: new OutlineInputBorder(
                           borderRadius: const BorderRadius.all(
                             const Radius.circular(25.0),
                           ),
                           borderSide:  BorderSide(color:Constants.secondary)
                       ),
                       filled: true,
                       hintStyle: new TextStyle(color: Colors.grey[800]),
                       hintText: "Search",
                       fillColor: Colors.grey[100]
                   ),
                 ),
               ):Container(),
               employees.length>0?listOfEmployees(context):
               Container(
                   margin: EdgeInsets.only(top: 20),
                   child: Center(child:Text("No administrator found ")))
             ],
           ): Center(
             child: NutsActivityIndicator(
               radius: 20,
               activeColor: Colors.indigo,
               inactiveColor: Colors.red,
               tickCount: 11,
               startRatio: 0.55,
               animationDuration: Duration(milliseconds: 123),
             ),
           )
           ,
         ),
         floatingActionButton: FloatingActionButton(
           onPressed: (){
             createAdminPopup(context);
           },
           backgroundColor: Constants.secondary,
           child: Icon(Icons.person_add_alt_1_outlined,),
         ),
       )
      ,
    );
  }
  Widget listOfEmployees(BuildContext context){
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: employees.length,
      itemBuilder: (context,index){
        return adminItem(employees[index]);
      },
    );
  }
  Widget showProfilePic(String avatar){
    return CircleAvatar(
      backgroundColor: Colors.transparent,
      radius: 30,
      backgroundImage: Image.asset('assets/loading.gif').image,
      child: CircleAvatar(
        radius: 30,
        backgroundColor: Colors.transparent,
        backgroundImage: NetworkImage(avatar),
      ),
    );

  }
  Widget adminItem(Employee emp){
    return Container(
      margin: EdgeInsets.only(top: 20,left:10,right: 10),
      child: Row(
        children: [
          emp.avatar==null?Icon(Icons.person_pin,size: 15.0.w,):
          showProfilePic(emp.avatar),
          SizedBox(width: 20,),
          SizedBox(
            width: 50.0.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(emp.name,style: GoogleFonts.lato(fontSize: 14.0.sp,fontWeight: FontWeight.bold),),
                SizedBox(height: 5,),
                Text(emp.email,style: GoogleFonts.lato(fontSize: 11.0.sp,color: Colors.black54),)
              ],
            ),
          ),
          Spacer(),
          PopupMenuButton(
            itemBuilder: (context) {
              return popupList();
            },
            onSelected: (value) {
               if(value==0){
                  detailPopup(context, emp);
               }
               else if(value==1){
                  removePopup(context, emp);
               }
            },
            elevation: 4,
            offset: Offset(0, 105),
            child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    shape: BoxShape.circle
                ),
                child: Center(child: Icon(Icons.more_horiz))
            ),
          ),
          SizedBox(width: 10,),

        ],
      ),
    );
  }
  void filterList(String name) {
    List<Employee> emps = [];
    if (name == "") {
      setState(() {
        employees = completeList;
      });
    }
    else {
      String up = name[0].toString().toUpperCase() +
          name.substring(1, name.length);
      String low = name[0].toString().toLowerCase() +
          name.substring(1, name.length);
      // print("Upper case $up and lower case $low");
      for (Employee s in employees) {
        if (s.name.contains(up) || s.name.contains(low)) {
          emps.add(s);
        }
      }
      setState(() {
        employees = emps;
      });
    }
  }
  List<PopupMenuEntry<Object>> popupList(){
    var list = List<PopupMenuEntry<Object>>();
    list.add(PopupMenuItem(
      child: Text("Detail"),
      value: 0,
    ));
    list.add(
      PopupMenuDivider(
        height: 10,
      ),
    );
    list.add(
      PopupMenuItem(
        child: Text("Remove"),
        value: 1,
      ),
    );
    return list;
  }

  createAdminPopup(BuildContext context){
    showDialog(
        context: context,
        builder: (_) {
          return createAdmin();
        }).then((value){
      getAllAdmins();
    });
  }
  detailPopup(BuildContext context,Employee emp)async{
    AlertDialog alert = AlertDialog(
      content: SizedBox(
        height:100.0.h/2,
        child:Expanded(
          child: Column(
            children: [
              if(emp.avatar!=null)CircleAvatar(
                radius: 10.5.h,
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 10.0.h,
                  backgroundImage: FadeInImage.assetNetwork(
                    placeholder: 'assets/user.png',
                    image: emp.avatar,
                  ).image,
                ),
              ),
              if(emp.avatar!=null)SizedBox(height: 4.0.h,),
              Expanded(
                child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Name",style: GoogleFonts.lato(fontSize: 14,fontWeight: FontWeight.bold),),
                      SizedBox(height: 3.0.h,),
                      Text("Email",style: GoogleFonts.lato(fontSize: 14,fontWeight: FontWeight.bold),),
                      SizedBox(height: 3.0.h,),
                      Text("Phone Number",style: GoogleFonts.lato(fontSize: 14,fontWeight: FontWeight.bold),),
                      SizedBox(height: 3.0.h,),
                      Text("Created on",style: GoogleFonts.lato(fontSize: 14,fontWeight: FontWeight.bold),),
                    ],
                  ),
                  SizedBox(width: 3.0.w,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(emp.name,style:  GoogleFonts.lato(fontSize: 14),),
                        SizedBox(height: 3.0.h,),
                        Text(emp.email,style:  GoogleFonts.lato(fontSize: 14),),
                        SizedBox(height: 3.0.h,),
                        Text(emp.phoneNumber,style:  GoogleFonts.lato(fontSize: 14),),
                        SizedBox(height: 3.0.h,),
                        Flexible(child: Text(emp.joinedOn,style:  GoogleFonts.lato(fontSize: 14,),textAlign: TextAlign.left))
                      ],
                    ),
                  )
                ],
            ),
              ),
           ]
          ),
        ),
      ),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  removePopup(BuildContext context,Employee emp)async{

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
      bool isDeleted=await comp.removeAdmin(emp.email);
      if(isDeleted){
        await getAllAdmins();
      }
    });
    Navigator.of(context, rootNavigator: true).pop();
  }


}
class createAdmin extends StatefulWidget {
  @override
  _createAdminState createState() => _createAdminState();
}

class _createAdminState extends State<createAdmin> {
  TextEditingController name=new TextEditingController();
  TextEditingController email=new TextEditingController();
  TextEditingController phone=new TextEditingController();
  TextEditingController password=new TextEditingController();
  bool progress=false;

  @override
  Widget build(BuildContext context) {
    return   SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: AlertDialog(
          content: SizedBox(
            height: MediaQuery.of(context).size.height/2,
            child: Column(
              children: <Widget>[
                Text("Creating new admin for your company",style: GoogleFonts.lato(fontSize: 18,fontWeight: FontWeight.bold),),
                SizedBox(height: 10,),
                TextField(
                  controller: name,
                  decoration: InputDecoration(
                    icon: Icon(Icons.perm_identity_outlined),
                    labelText: 'Name',
                  ),
                ),
                TextField(

                  controller: email,
                  decoration: InputDecoration(
                    icon: Icon(Icons.email_outlined),
                    labelText: 'Email',
                  ),
                ),
                TextField(
                  controller: phone,
                  decoration: InputDecoration(
                    icon: Icon(Icons.phone),
                    labelText: 'Phone',
                  ),
                ),
                TextField(
                  obscureText: true,
                  controller: password,
                  decoration: InputDecoration(
                    icon: Icon(Icons.security),
                    labelText: 'Password',
                  ),
                ),
                SizedBox(height: 10,),
              ],
            ),
          ),
          actions: [
            !progress?DialogButton(
              color: Constants.primary,
              onPressed: () async {
                if(name.text==""||password.text==""||email.text==""||phone.text==""){
                  Toast.show("Sorry all fields are required", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
                  return;
                }
                CompanyOperations company=new CompanyOperations();
               // start progress
                setState(() {
                    progress=true;
                });

                bool isSaved=await company.saveAdmin(name: name.text,password: password.text,email: email.text,phone: phone.text);
                if(isSaved) {
                  // after successful upload
                  Toast.show("Successfully created!", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.TOP);
                }
                else{
                  Toast.show("Failed to create!", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.TOP);
                }
                Timer(Duration(seconds: 2), () {
                  Navigator.of(context).pop();
                });

              },
              child: Text(
                "Create",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ):Container(
                 padding: EdgeInsets.only(bottom: 20,right: 20),
                child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Constants.secondary),)
            )
          ]),
    );
  }


}