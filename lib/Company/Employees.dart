import 'package:cached_network_image/cached_network_image.dart';
import 'package:emergency_app/Models/Employee.dart';
import 'package:emergency_app/Providers/CompanyOperations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuts_activity_indicator/nuts_activity_indicator.dart';
import 'package:sizer/sizer.dart';
import '../Constants.dart';

class CompanyEmployees extends StatefulWidget {
  @override
  _CompanyEmployeesState createState() => _CompanyEmployeesState();
}

class _CompanyEmployeesState extends State<CompanyEmployees> {
  List<Employee> employees=[];
  List<Employee> completeList=[];
  TextEditingController searchController=new TextEditingController();
  bool progress=true;

  Future<void> getAllEmps()async{
    CompanyOperations comp=new CompanyOperations();
    List<Employee> admins=await comp.getAllEmployees();
    setState(() {
      employees=admins;
      completeList=admins;
      progress=false;
    });
  }
  @override
  void dispose(){
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState(){
    searchController.addListener(() {
      filterList(searchController.text);
    });
    getAllEmps();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          resizeToAvoidBottomInset: false,
          body:!progress?SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(12.0),
              child:Column(
                children: [
                  completeList.length>0?SizedBox(height: 5.0.h,):Container(),
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
                  employees.length>0?listOfEmployees(context): Container(
                      margin: EdgeInsets.only(top: 20),
                      child: Center(child:Text("No employee found ")))


                ],
              ),
            ),
          ):Center(
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
        )
    );
  }
  Widget listOfEmployees(BuildContext context){
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: employees.length,
      itemBuilder: (context,index){
        return employeeItem(employees[index]);
      },
    );
  }
  Widget employeeItem(Employee emp){
    return Container(
      margin: EdgeInsets.only(top: 20),
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
  Widget showProfilePic(String avatar){
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0.h),
      child: CachedNetworkImage(
          fit: BoxFit.cover,
          width: 8.0.h,
          height: 8.0.h,
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,),
            ),
          ),
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              CircularProgressIndicator(value: downloadProgress.progress),
          errorWidget: (context, url, error) => Icon(Icons.error),
          imageUrl:avatar
      ),
    );
  }
  List<PopupMenuEntry<Object>> popupList(){
    var list = List<PopupMenuEntry<Object>>();
    list.add(
      PopupMenuItem(
        child: Text("Details"),
        value: 0,
      ),
    );
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
  void filterList(String name){
    List<Employee> emps=[];
    if(name==""){
      setState(() {
        employees=completeList;
      });
    }
    else {
      String up=name[0].toString().toUpperCase()+name.substring(1,name.length);
      String low=name[0].toString().toLowerCase()+name.substring(1,name.length);
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
                    radius: 10.0.h,
                    backgroundImage: Image.network(emp.avatar,width: 10.0.w,height: 10.0.h,fit: BoxFit.fill,
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
      bool isDeleted=await comp.removeEmployee(emp.email);
      if(isDeleted){
        await getAllEmps();
      }
    });
    Navigator.of(context, rootNavigator: true).pop();
  }

}
