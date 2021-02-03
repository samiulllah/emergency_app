import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emergency_app/Constants.dart';
import 'package:emergency_app/Models/SoundClip.dart';
import 'package:emergency_app/Providers/CompanyOperations.dart';
import 'package:emergency_app/Providers/SharedPref.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuts_activity_indicator/nuts_activity_indicator.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sizer/sizer.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:toast/toast.dart';
import 'package:flutter/cupertino.dart' as cup;


class CompanyHome extends StatefulWidget {
  @override
  _CompanyHomeState createState() => _CompanyHomeState();
}
class _Page {
  _Page({this.widget});
  final StatelessWidget widget;
}
class _CompanyHomeState extends State<CompanyHome> {
  Map<String,dynamic> user;
  AudioPlayer audioPlugin;
  List<SoundClip> soundClips=new List<SoundClip>();
  bool progress=true;
  int playingIndex=-1;

  Future<void> getAllClips() async {
    CompanyOperations comp=new CompanyOperations();
    List<SoundClip> clips=await comp.getAllClips();
    setState(() {
        soundClips=clips;
        progress=false;
    });
  }
  @override
  void dispose(){
    audioPlugin.dispose();
     super.dispose();
  }
  @override
  void initState(){
    audioPlugin= AudioPlayer();
    getAllClips();
    // audioPlugin.onDurationChanged.listen((Duration d) {
    //   print('Max duration: $d');
    // });
    // audioPlugin.onAudioPositionChanged.listen((p) {
    //    print("position is $p");
    //  }
    // );
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
       home: Scaffold(
         body:Container(
           child:Column(
             mainAxisAlignment: !progress?MainAxisAlignment.start:cup.MainAxisAlignment.center,
             children: [
               !progress?soundClips.length>0?renderAllClips():Center(child:Text("No alarm found"))
                :Center(
                  child: NutsActivityIndicator(
                   radius: 20,
                   activeColor: Colors.indigo,
                   inactiveColor: Colors.red,
                   tickCount: 11,
                   startRatio: 0.55,
                   animationDuration: Duration(milliseconds: 123),
               ),
                ),
             ],
           ),
         ),
         floatingActionButton: FloatingActionButton(
              onPressed: (){
                addClipPopup(context);
              },
              backgroundColor: Constants.secondary,
              child: Icon(Icons.library_music_outlined,),
         ),
       )
    );
  }
  ListView renderAllClips(){
    return new ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: soundClips.length,
        itemBuilder: (context, index) {
          return clipItem(soundClips[index],context,index);
        }
    );
  }
  Widget clipItem(SoundClip clip,BuildContext context,int index){
      return Container(
          margin: EdgeInsets.only(top: 20),
          child: Row(
             children: [
                   clip.playing?clip.loading?SpinKitDualRing(
                     size: 8.0.w,
                     color: Colors.black,
                   ):SpinKitWave(
                     size: 8.0.w,
                     color: Colors.black,
                   ):Icon(Icons.surround_sound,size: 12.0.w,),
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
                       if(clip.playing==true){
                         setState(() {
                            clip.playing=false;
                         });
                       }
                       else{
                         if(playingIndex!=index && playingIndex>=0){
                           // means already one is playing let stop that first
                           setState(() {
                             soundClips[playingIndex].playing=false;
                           });
                           audioPlugin.stop();
                           audioPlugin.dispose();
                           audioPlugin=new AudioPlayer();
                         }
                          setState(() {
                              clip.playing=true;
                              clip.loading=true;
                          });
                         playingIndex=index;
                       }


                       if(clip.playing){
                         audioPlugin.play(clip.clipUri);
                         audioPlugin.onDurationChanged.listen((Duration d) {
                             print("duration fetched  =${d.inSeconds}");
                             if(d.inSeconds>0 ){
                                 setState(() {
                                     clip.loading=false;
                                 });
                             }
                       });
                         audioPlugin.onPlayerCompletion.listen((event) {
                           setState(() {
                             clip.playing=false;
                           });
                         });
                       }
                       else{
                         audioPlugin.stop();
                       }

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
          child: Text("Impose"),
          value: 1,
        ),
      );
        list.add(
          PopupMenuDivider(
            height: 10,
          ),
        );
        list.add(PopupMenuItem(
          child: Text("Details"),
          value: 1,
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

  addClipPopup(BuildContext context){
    showDialog(
        context: context,
        builder: (_) {
          return Upload();
    }).then((value){
        getAllClips();
    });
  }

}
class Upload extends StatefulWidget {
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  File audioFile=null;
  TextEditingController title=new TextEditingController();
  TextEditingController description=new TextEditingController();
  bool progress=false;
  @override
  Widget build(BuildContext context) {
    return   cup.SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: AlertDialog(
          content: SizedBox(
            height: cup.MediaQuery.of(context).size.height/3.5,
            child: Column(
              children: <Widget>[
                Text("Upload the clip",style: GoogleFonts.lato(fontSize: 18,fontWeight: FontWeight.bold),),
                SizedBox(height: 10,),
                TextField(
                  controller: title,
                  decoration: InputDecoration(
                    icon: Icon(Icons.title),
                    labelText: 'Title',
                  ),
                ),
                TextField(
                  controller: description,
                  obscureText: false,
                  decoration: InputDecoration(
                    icon: Icon(Icons.description),
                    labelText: 'description',
                  ),
                ),
                SizedBox(height: 10,),
                GestureDetector(
                  onTap: ()async{
                    FilePickerResult result = await FilePicker.platform.pickFiles(
                      type: FileType.audio,
                    );
                    if(result != null) {
                      setState(() {
                        audioFile = File(result.files.single.path);
                      });
                    } else {
                      // User canceled the picker
                    }
                  },
                  child: Row(
                    children: [
                      Icon(Icons.attach_file,color: Colors.black54,),
                      SizedBox(width: 15,),
                      Text(audioFile==null?"Choose file":basename(audioFile.path),style: GoogleFonts.lato(fontSize: 14,fontWeight: FontWeight.w400)),
                    ],
                  ),
                )
              ],
            ),
          ),
          actions: [
            !progress?DialogButton(
              color: Constants.primary,
              onPressed: () async {
                // let upload
                setState(() {
                  progress=true;
                });
                CompanyOperations company=new CompanyOperations();
                bool upload=await company.saveClip(title: title.text,description: description.text,file: audioFile);
                if(upload) {
                  // after successful upload
                  Toast.show("Successfully uploaded!", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.TOP);
                  title.text = "";
                  description.text = "";
                  setState(() {
                    audioFile = null;
                    progress = false;
                  });
                  Navigator.of(context).pop();
                }
                else{
                  Toast.show("Failed to upload!", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.TOP);
                }
              },
              child: Text(
                "Upload",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ):Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Constants.secondary),))
          ]),
    );
  }
}
