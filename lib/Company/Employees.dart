import 'package:emergency_app/Models/Employee.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  void dispose(){
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    employees.add(new Employee(name: "Adnan",email:"adnan2@gmailcom"));
    employees.add(new Employee(name: "Philips",email: "ph23@gmail.com"));
    employees.add(new Employee(name: "John ",email: "jhon44@hotmail.com"));
    employees.add(new Employee(name: "Elizabeth",email: "eliza9090@gmail.com"));
    completeList=employees;
    searchController.addListener(() {
      filterList(searchController.text);
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          resizeToAvoidBottomInset: false,
          body:SingleChildScrollView(
            child: Container(
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
                  listOfEmployees(context)
                ],
              ),
            ),
          ),
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
          Icon(Icons.person_pin,size: 15.0.w,),
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
              print("value:$value");
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
  List<PopupMenuEntry<Object>> popupList(){
    var list = List<PopupMenuEntry<Object>>();
    list.add(
      PopupMenuItem(
        child: Text("Details"),
        value: 1,
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
}
