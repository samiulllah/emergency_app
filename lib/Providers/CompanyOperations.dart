import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emergency_app/Models/SoundClip.dart';
import 'package:emergency_app/Providers/SharedPref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path/path.dart';
class CompanyOperations{


  // signing up company
  Future<List<String>> handleSignUp({String name,String email,String phone,String address,String password})async{
    List<String> response=[];
    try {
      UserCredential  userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password
      );

      var signup=await FirebaseFirestore.instance.collection("CompanyRegistrations").add(
        {
          "CompanyName":name,
          "CompanyEmail":email,
          "CompanyPhone":phone,
          "CompanyAddress":address,
          "CompanyAvatar":userCredential.user.photoURL,
          "isPayed":"0",
          "Datetime":DateTime.now().toString()
        }
      );
      SharedPref sharedPref=new SharedPref();
      sharedPref.save("user", {'type':'0','name':'$name','email':'$email','phone':'$phone','address':'$address','isPayed':'0'});
      response.add("1");
    } catch (e) {
      response.add("0");
      //response.add(e.toString());
      if (e.code == 'weak-password') {
        response.add("Weak password isn't allowed");
      } else if (e.code == 'email-already-in-use') {
        response.add("Account already exist please login");
      }
    }
    return response;
  }


  // login
  Future<List<String>> handleLogin({String email,String password})async{
    List<String> response=[];
    try {
      UserCredential  userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password
      );

      response.add("1");
      QuerySnapshot snapshot=await FirebaseFirestore.instance.collection("CompanyRegistrations").where("CompanyEmail",isEqualTo: email).get();
      Map<String,dynamic> data=snapshot.docs[0].data();
      SharedPref sharedPref=new SharedPref();
      sharedPref.save("user", {'type':'0','name':'${data['CompanyName']}','email':'${data['CompanyEmail']}','phone':'${data['CompanyPhone']}','address':'${data['CompanyAddress']}','isPayed':'0'});

      if(snapshot.docs[0].get("isPayed")=="0"){
        // navigate to payment screen
        response.add("0");
      }
      else{
         // navigate to home
        response.add("1");
      }

    } on FirebaseAuthException catch (e) {
      response.add("0");
      if (e.code == 'user-not-found') {
        response.add("This $email isn't  registered.");
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        response.add("Incorrect password.");
        print('Wrong password provided for that user.');
      }
    }
    return response;
  }

  // saving clip
  Future<bool> saveClip({String title,String description,File file})async{
    try {
      FirebaseStorage storage = await FirebaseStorage.instance;
      Reference reference = await storage.ref().child(
          "SoundClips/${basename(file.path)}${DateTime.now().millisecondsSinceEpoch}");

      await reference.putFile(file).then((value) async {
        String dwnUrl = await value.ref.getDownloadURL();
        SharedPref sharedPref=new SharedPref();
        Map<String,dynamic> user=await sharedPref.read("user");
        FirebaseFirestore.instance.collection("CompanySounds").doc("${user['email']}").collection("All").add({
          "datetime":DateTime.now().toString(),
          "downloadUrl":dwnUrl,
          "title":title,
          "description":description,
          "email":user['email'],
          "sid":user['email']+'${DateTime.now().millisecondsSinceEpoch}',
        });
      });
      return true;
    }catch(e){
      return false;
    }
  }
  // fetch all clips of this company
  Future<List<SoundClip>> getAllClips()async{
    List<SoundClip> clips=new List<SoundClip>();
    SharedPref sharedPref=new SharedPref();
    Map<String,dynamic> user=await sharedPref.read("user");
    QuerySnapshot snapshot=await FirebaseFirestore.instance.collection("CompanySounds").doc("${user['email']}").collection("All").get();
    for(int i=0;i<snapshot.docs.length;i++){
      clips.add(SoundClip.fromJson(snapshot.docs[i].data()));
    }
    return clips;
  }
}