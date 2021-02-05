import 'package:audioplayers/audioplayers.dart';
import 'package:emergency_app/Models/SoundClip.dart';
import 'package:emergency_app/Providers/EmployeeServies.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuts_activity_indicator/nuts_activity_indicator.dart';
import 'package:sizer/sizer.dart';

import '../Constants.dart';
class EmployeeHome extends StatefulWidget {
  @override
  _EmployeeHomeState createState() => _EmployeeHomeState();
}

class _EmployeeHomeState extends State<EmployeeHome> {
  AudioPlayer audioPlugin;

  List<SoundClip> soundClips=new List<SoundClip>();
  List<SoundClip> completeList=new List<SoundClip>();

  TextEditingController searchController=new TextEditingController();
  bool progress=true;
  int playingIndex=-1;
  Future<void> getAllClips() async {
    EmployeeOperations emp=new EmployeeOperations();
    List<SoundClip> clips=await emp.getAllClips();
    setState(() {
      soundClips=clips;
      completeList=clips;
      progress=false;
    });
  }
  @override
  void dispose(){
    searchController.dispose();
    audioPlugin.dispose();
    super.dispose();
  }
  @override
  void initState(){
    searchController.addListener(() {
      filterList(searchController.text);
    });
    audioPlugin= AudioPlayer();
    getAllClips();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          resizeToAvoidBottomInset: false,
          body:!progress?Container(
            child:Column(
              children: [
                if(completeList.length>0)SizedBox(height: 5.0.h,),
                if(completeList.length>0)Container(
                  width: 90.0.w,
                  height: 7.0.h,
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(left: 20,right: 20),
                  child: TextField(
                    textAlignVertical: TextAlignVertical.center,
                    textAlign: TextAlign.left,
                    controller: searchController,
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
                ),
                completeList.length>0?Expanded(child: listOfClips(context)):
                Container(
                    margin: EdgeInsets.only(top: 20),
                    child: Center(child:Text("No alarm found")))
              ],
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
          ),
        )
    );
  }
  Widget listOfClips(BuildContext context){
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: soundClips.length,
      itemBuilder: (context,index){
        return clipItem(soundClips[index]);
      },
    );
  }
  Widget clipItem(SoundClip clip){
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Row(
        children: [
          Icon(Icons.surround_sound,size: 12.0.w,),
          SizedBox(width: 20,),
          SizedBox(
            width: 50.0.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(clip.title,style: GoogleFonts.lato(fontSize: 14.0.sp,fontWeight: FontWeight.bold),),
                SizedBox(height: 5,),
                Text(clip.description,style: GoogleFonts.lato(fontSize: 11.0.sp,color: Colors.black54),)
              ],
            ),
          ),
          Spacer(),
          GestureDetector(
            onTap: (){
              setState(() {
                clip.playing=!clip.playing;
              });
            },
            child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    shape: BoxShape.circle
                ),
                child: Center(child: Icon(!clip.playing?Icons.play_arrow_outlined:Icons.pause))
            ),
          ),
          SizedBox(width: 10,),
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
          SizedBox(width: 2,),

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
    return list;
  }
  void filterList(String name){
    List<SoundClip> clips=[];
    if(name==""){
      setState(() {
        soundClips=completeList;
      });
    }
    else {
      String up=name[0].toString().toUpperCase()+name.substring(1,name.length);
      String low=name[0].toString().toLowerCase()+name.substring(1,name.length);
      print("Upper case $up and lower case $low");
      for (SoundClip s in soundClips) {
        if (s.title.contains(up) || s.title.contains(low)) {
          clips.add(s);
        }
      }
      setState(() {
        soundClips = clips;
      });
    }
  }
}
