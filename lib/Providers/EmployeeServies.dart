import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:emergency_app/Models/SoundClip.dart';
import 'package:emergency_app/Providers/SharedPref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path/path.dart' as Path;
import 'package:firebase_storage/firebase_storage.dart';
class EmployeeOperations{

   // getting hash list of emails
   Future<List<Map<String,dynamic>>>  getAllHashedEmails()async{
     List<Map<String,dynamic>> listOfHashes=[];
     QuerySnapshot snapshot=await FirebaseFirestore.instance.collection("CompanyRegistrations").get();
     if(snapshot.docs.length>0){
       for(int i=0;i<snapshot.docs.length;i++){
         var bytes1 = utf8.encode(snapshot.docs[i].get("CompanyEmail"));
         List<int> d = md5.convert(bytes1).bytes;
         Map<String,dynamic> m=new Map();
         m['cid']=snapshot.docs[i].get("CompanyEmail");
         m['name']=snapshot.docs[i].get("CompanyName");
         m['digest']=d.toString();
         listOfHashes.add(m);
       }
     }
     return listOfHashes;
   }
   // signing up Employee
   Future<List<String>> handleSignUp({String name,String phone,String email,String password,String cid,String cname})async{
     List<String> response=[];
     try {
       UserCredential  userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
           email: email,
           password: password
       );

       await FirebaseFirestore.instance.collection("EmployeesRegistration").add(
           {
             "email":email,
             "phone":phone,
             "cid":cid,
             "cname":cname,
             "name":name,
             "Datetime":DateTime.now().toString()
           }
       );
       SharedPref sharedPref=new SharedPref();
       sharedPref.save("user", {'type':'2','name':'$name','email':'$email','phone':'$phone','cid':cid});
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
    bool isDelete=await runUserMiddleware(email,password);
    if(isDelete) {
      response.add("3");
      return response;
    }

    try {
      SharedPref sharedPref=new SharedPref();
      UserCredential  userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      response.add("1");
      QuerySnapshot snapshot=await FirebaseFirestore.instance.collection("EmployeesRegistration").where("email",isEqualTo:email).get();
      if(snapshot.docs.length>0){
        Map<String, dynamic> data = snapshot.docs[0].data();
        sharedPref.save("user", {'type':'2','name':'${data['name']}','email':'${data['email']}','phone':'${data['phone']}','cid':'${data['cid']}'});
      }

    } on FirebaseAuthException catch (e) {
      print("yes erro is thrown ----> $e");
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
  Future<bool> runUserMiddleware(String email,String password)async{
    try {
      // check if present in deleted
      QuerySnapshot snapshot=await FirebaseFirestore.instance.collection("DeletedEmployees").where("uid",isEqualTo: email).get();
      if(snapshot.docs.length>0){
        bool isDelete=await removeId(email, password);
        if(isDelete){
          await snapshot.docs[0].reference.delete();
        }else{
          return false;
        }
      }
      else{
        return false;
      }
      return true;
    }catch(e){
      return false;
    }
  }
  // remove auth id
  Future<bool> removeId(String email,String password)async{
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
          email: email,
          password: password
      );
      await userCredential.user.delete();
      return true;
    }catch(e){
      return false;
    }
  }
   // fetch user profile
   Future<Map<String,dynamic>>  fetchUser(String email)async{
     Map<String,dynamic> response=new Map();
     try{
         // Employee
         QuerySnapshot snapshot=await FirebaseFirestore.instance.collection("EmployeesRegistration").where("email",isEqualTo: email).get();
         if(snapshot.docs.length>0){
           response['success']="1";
           response['name']=snapshot.docs[0].data()['name'];
           response['phone']=snapshot.docs[0].data()['phone'];
           response['cid']=snapshot.docs[0].data()['cid'];
           response['cname']=snapshot.docs[0].data()['cname'];
           if(snapshot.docs[0].data().containsKey("avatar")){
             if(snapshot.docs[0].data()['avatar']!=null){
               response['avatar']=snapshot.docs[0].data()['avatar'];
             }
           }
         }

     }
     catch(e){
          response['success']="0";
          return response;
     }
     return response;
   }

   // update profile
   Future<bool>  updateEmployeeProfile({String name,String phone,File img,String avatar,String email})async{
     bool isUpdate=false;
     if(img!=null){
       if(avatar==null){
         // first time creation
         bool isSaved=await uploadAndWrite(img: img,name: name,phone: phone);
         return isSaved;
       }
       else{
         // already have avatar means update and delete previous
         // deleting old
         bool isDelete=await deleteStorageFile(avatar);
         if(isDelete){
           bool isSaved=await uploadAndWrite(img: img,name: name,phone: phone);
           return isSaved;
         }
         else{
           return false;
         }
       }
     }
     else{
       // only text update
         QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(
             "EmployeesRegistration")
             .where("email", isEqualTo: email).get();
         if (snapshot.docs.length > 0) {
           snapshot.docs[0].reference.update({
             "name": name,
             "phone": phone,
           });
         }
         return true;
     }

   }
   Future<bool> uploadAndWrite({File img,String email,String name,String phone,String address,int userType})async{
     try {
       FirebaseStorage storage = await FirebaseStorage.instance;
       Reference reference = await storage.ref().child(
           "Avatars/${basename(img.path)}${DateTime
               .now()
               .millisecondsSinceEpoch}");
       // save to db
       await reference.putFile(img).then((value) async {
         String dwnUrl = await value.ref.getDownloadURL();
         QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(
             "EmployeesRegistration")
             .where("email", isEqualTo: email).get();
         if (snapshot.docs.length > 0) {
           snapshot.docs[0].reference.update({
             "name": name,
             "phone": phone,
             "avatar":dwnUrl
           });
         }
       });
       return true;
     }
     catch(e){
       return false;
     }
   }
   // delete file
   Future<bool> deleteStorageFile(String uri)async{
     try {
       String fileUrl = uri;
       var url = Uri.decodeFull(Path.basename(fileUrl)).replaceAll(
           new RegExp(r'(\?alt).*'), '');

       var firebaseStorageRef =
       FirebaseStorage.instance.ref().child(url);
       await firebaseStorageRef.delete();
       return true;
     }catch(e){
       return false;
     }
   }
   // fetch all clips
   Future<List<SoundClip>> getAllClips()async{
     List<SoundClip> clips=new List<SoundClip>();
     SharedPref sharedPref=new SharedPref();
     Map<String,dynamic> user=await sharedPref.read("user");
     String cid=await user['cid'];
     QuerySnapshot snapshot=await FirebaseFirestore.instance.collection("CompanySounds").doc(cid).collection("All").get();
     for(int i=0;i<snapshot.docs.length;i++){
       clips.add(SoundClip.fromJson(snapshot.docs[i].data()));
     }
     return clips;
   }
}