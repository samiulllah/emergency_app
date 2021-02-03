import 'package:emergency_app/Models/SoundClip.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../Constants.dart';
class EmployeeHome extends StatefulWidget {
  @override
  _EmployeeHomeState createState() => _EmployeeHomeState();
}

class _EmployeeHomeState extends State<EmployeeHome> {
  List<SoundClip> soundClips=[];
  @override
  void initState(){
    super.initState();
    soundClips.add(new SoundClip(title: "Fire",description: "When fire breaks out you'll listen this sound, Please memorize it"));
    soundClips.add(new SoundClip(title: "Tornodo",description: "When there is tornodo out you'll listen this sound, Please memorize it"));
    soundClips.add(new SoundClip(title: "Volcano Erruption",description: "When volcano errupts out you'll listen this sound, Please memorize it"));
    soundClips.add(new SoundClip(title: "Earthquake",description: "When there is earthquake out you'll listen this sound, Please memorize it"));
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          resizeToAvoidBottomInset: false,
          body:Container(
            child:Column(
              children: [
                SizedBox(height: 5.0.h,),
                Container(
                  width: 90.0.w,
                  height: 7.0.h,
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(left: 20,right: 20),
                  child: TextField(
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
                ),
                Expanded(child: listOfClips(context))
              ],
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
}
