import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emergency_app/Models/Employee.dart';
import 'package:emergency_app/Models/SoundClip.dart';
import 'package:emergency_app/Providers/SharedPref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path/path.dart' as Path;

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
    bool isDelete=await runAdminMiddleware(email,password);
    if(isDelete) {
       response.add("88");
       return response;
    }
    int utype=-1;
    try {
      SharedPref sharedPref=new SharedPref();
      UserCredential  userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      response.add("1");
      // lets determine user type
        // let it be admin
      QuerySnapshot snapshot=await FirebaseFirestore.instance.collection("CompanyAdmins").where("email",isEqualTo:email).get();
      if(snapshot.docs.length>0){
        Map<String, dynamic> data = snapshot.docs[0].data();
        utype=1; //// admin
        sharedPref.save("user", {'type':'1','name':'${data['name']}','email':'${data['email']}','phone':'${data['phone']}'});
      }

      //let it be company
      QuerySnapshot snap=await FirebaseFirestore.instance.collection("CompanyRegistrations").where("CompanyEmail",isEqualTo: email).get();
      if(snap.docs.length>0) {
        Map<String, dynamic> data = snap.docs[0].data();
        utype = 0; // company

        sharedPref.save("user", {
          'type': '0',
          'name': '${data['CompanyName']}',
          'email': '${data['CompanyEmail']}',
          'phone': '${data['CompanyPhone']}',
          'address': '${data['CompanyAddress']}',
          'isPayed': '${snap.docs[0].get("isPayed")}'
        });

        if (snap.docs[0].get("isPayed") == "0") {
          // navigate to payment screen
          response.add("0");
        }
        else {
          // navigate to home
          response.add("1");
        }
      }
      if(utype==-1 || utype==1) {
        response.add("a");
        response.add('$utype');
      }
      else{
        response.add('$utype');
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
  // remove a clip
  Future<bool> removeClip({String sid,String uri})async{
     bool isDelete=false;
     SharedPref sharedPref=new SharedPref();
     Map<String,dynamic> user=await sharedPref.read("user");
     String email=await user['email'];
     QuerySnapshot snapshot=await FirebaseFirestore.instance.collection("CompanySounds").doc(email).collection("All").where("sid",isEqualTo: sid).get();
     if(snapshot.docs.length>0){
         String docRef=await snapshot.docs[0].reference.id.toString();
         await deleteStorageFile(uri);
         await FirebaseFirestore.instance.collection("CompanySounds").doc(email).collection("All").
                                doc(docRef).delete();
         isDelete=true;
     }
     return isDelete;
  }
  // fetch all clips of this company
  Future<List<SoundClip>> getAllClips()async{
    List<SoundClip> clips=new List<SoundClip>();
    SharedPref sharedPref=new SharedPref();
    Map<String,dynamic> user=await sharedPref.read("user");
    QuerySnapshot snapshot;
    if(user['type']=="0"){
       snapshot=await FirebaseFirestore.instance.collection("CompanySounds").doc("${user['email']}").collection("All").get();
    }
    else{
      String cid=await getAdminCompany();
      snapshot=await FirebaseFirestore.instance.collection("CompanySounds").doc(cid).collection("All").get();
    }
    for(int i=0;i<snapshot.docs.length;i++){
      clips.add(SoundClip.fromJson(snapshot.docs[i].data()));
    }

    return clips;
  }

  Future<String> getAdminCompany()async{
    SharedPref sharedPref=new SharedPref();
    Map<String,dynamic> user=await sharedPref.read("user");
    String email=await user['email'];
    QuerySnapshot snapshot=await FirebaseFirestore.instance.collection("CompanyAdmins").where("email",isEqualTo:email).get();
    return snapshot.docs[0].get("companyId");
  }

  // fetch all administrators
  Future<List<Employee>> getAllAdministrators()async{
    List<Employee> emps=new List<Employee>();
    SharedPref sharedPref=new SharedPref();
    Map<String,dynamic> user=await sharedPref.read("user");
    String cid=await user['email'];
    QuerySnapshot snapshot=await FirebaseFirestore.instance.collection("CompanyAdmins").where("companyId",isEqualTo:cid ).get();
    for(int i=0;i<snapshot.docs.length;i++){
      emps.add(Employee.fromJson(snapshot.docs[i].data()));
    }
    return emps;
  }
  // fetch all employees
  Future<List<Employee>> getAllEmployees()async{
    List<Employee> emps=new List<Employee>();
    SharedPref sharedPref=new SharedPref();
    Map<String,dynamic> user=await sharedPref.read("user");
    String cid=await user['email'];
    QuerySnapshot snapshot=await FirebaseFirestore.instance.collection("EmployeesRegistration").where("cid",isEqualTo:cid ).get();
    for(int i=0;i<snapshot.docs.length;i++){
      emps.add(Employee.fromJson(snapshot.docs[i].data()));
    }
    return emps;
  }

  // saving an administrator
  Future<bool> saveAdmin({String email,String password,String name,String phone})async{
    try{
      UserCredential  userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
      SharedPref sharedPref=new SharedPref();
      Map<String,dynamic> user=await sharedPref.read("user");
      String cid=await user['email'];
        FirebaseFirestore.instance.collection("CompanyAdmins").add({
          "companyId":cid,
          "joinedOn":DateTime.now().toString(),
          "email":email,
          "name":name,
          "phone":phone
        });
      return true;
    }catch(e){
      return false;
    }
  }

  // removing administrator
  Future<bool>  removeAdmin(String email)async{
    try{
      SharedPref sharedPref=new SharedPref();
      Map<String,dynamic> user=await sharedPref.read("user");
      String cid=await user['email'];
      QuerySnapshot snapshot=await FirebaseFirestore.instance.collection("CompanyAdmins").where("email",isEqualTo: email).where("companyId",isEqualTo: cid).get();
      if(snapshot.docs.length>0){
        if(snapshot.docs[0].data().containsKey("avatar")) {
          String avatar = snapshot.docs[0].data()['avatar'];
          await deleteStorageFile(avatar);
        }
        String docRef=await snapshot.docs[0].reference.id.toString();
        await FirebaseFirestore.instance.collection("CompanyAdmins").doc(docRef).delete();
        await FirebaseFirestore.instance.collection("DeletedAdmins").add({
          "cid": cid,
          "uid": email
        });
      }
      else{
        return false;
      }
      return true;
    }catch(e){
      return false;
    }
  }

  // removing employee
  Future<bool>  removeEmployee(String email)async{
    try{
      SharedPref sharedPref=new SharedPref();
      Map<String,dynamic> user=await sharedPref.read("user");
      String cid=await user['email'];
      QuerySnapshot snapshot=await FirebaseFirestore.instance.collection("EmployeesRegistration").where("email",isEqualTo: email).get();
      if(snapshot.docs.length>0){
        if(snapshot.docs[0].data().containsKey("avatar")) {
          String avatar = snapshot.docs[0].data()['avatar'];
          await deleteStorageFile(avatar);
        }
        String docRef=await snapshot.docs[0].reference.id.toString();
        await FirebaseFirestore.instance.collection("EmployeesRegistration").doc(docRef).delete();
        await FirebaseFirestore.instance.collection("DeletedEmployees").add({
          "cid": cid,
          "uid": email
        });
      }
      else{
        return false;
      }
      return true;
    }catch(e){
      return false;
    }
  }
  Future<bool> runAdminMiddleware(String email,String password)async{
    try {
       // check if present in deleted
      QuerySnapshot snapshot=await FirebaseFirestore.instance.collection("DeletedAdmins").where("uid",isEqualTo: email).get();
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

  // update profile
  Future<bool>  updateCompanyProfile({String name,String phone,String address,File img,String avatar,String email,int userType})async{
    bool isUpdate=false;
    if(img!=null){
      if(avatar==null){
        // first time creation
        bool isSaved=await uploadAndWrite(img: img,name: name,phone: phone,address: address);
        return isSaved;
      }
      else{
        // already have avatar means update and delete previous
         // deleting old
        bool isDelete=await deleteStorageFile(avatar);
        if(isDelete){
          bool isSaved=await uploadAndWrite(img: img,name: name,phone: phone,address: address);
          return isSaved;
        }
        else{
          return false;
        }
      }
    }
    else{
       // only text update
      if(userType==0) { // company

        QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(
            "CompanyRegistrations")
            .where("CompanyEmail", isEqualTo: email).get();
        if (snapshot.docs.length > 0) {
          snapshot.docs[0].reference.update({
            "CompanyName": name,
            "CompanyPhone": phone,
            "CompanyAddress": address,
          });
        }
      }
      else{  // admin

        QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(
            "CompanyAdmins")
            .where("email", isEqualTo: email).get();
        if (snapshot.docs.length > 0) {
          snapshot.docs[0].reference.update({
            "name": name,
            "phone": phone,
          });
        }
      }
    }
    return isUpdate;
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
        QuerySnapshot snapshot=await FirebaseFirestore.instance.collection("CompanyRegistrations")
            .where("CompanyEmail",isEqualTo: email).get();
        if(userType==0) {
          if (snapshot.docs.length > 0) {
            snapshot.docs[0].reference.update({
              "CompanyName": name,
              "CompanyPhone": phone,
              "CompanyAddress": address,
              "avatar": dwnUrl,
            });
          }
        }
        else{
          QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(
              "CompanyAdmins")
              .where("email", isEqualTo: email).get();
          if (snapshot.docs.length > 0) {
            snapshot.docs[0].reference.update({
              "name": name,
              "phone": phone,
              "avatar": dwnUrl,
            });
          }
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

  // fetch user profile
  Future<Map<String,dynamic>>  fetchUser(String email,int userType)async{
    Map<String,dynamic> response=new Map();
    try{
      if(userType==0){
        // company
        QuerySnapshot snapshot=await FirebaseFirestore.instance.collection("CompanyRegistrations").where("CompanyEmail",isEqualTo: email).get();
        if(snapshot.docs.length>0){
           response['name']=snapshot.docs[0].data()['CompanyName'];
           response['phone']=snapshot.docs[0].data()['CompanyPhone'];
           response['address']=snapshot.docs[0].data()['CompanyAddress'];
           if(snapshot.docs[0].data().containsKey("avatar")){
               if(snapshot.docs[0].data()['avatar']!=null){
                 response['avatar']=snapshot.docs[0].data()['avatar'];
               }
           }
        }
      }
      else{
        // admin
        QuerySnapshot snapshot=await FirebaseFirestore.instance.collection("CompanyAdmins").where("email",isEqualTo: email).get();
        if(snapshot.docs.length>0){
          response['name']=snapshot.docs[0].data()['name'];
          response['phone']=snapshot.docs[0].data()['phone'];
          response['address']=email;
          if(snapshot.docs[0].data().containsKey("avatar")){
            if(snapshot.docs[0].data()['avatar']!=null){
              response['avatar']=snapshot.docs[0].data()['avatar'];
            }
          }
        }
      }
    }
    catch(e){

    }
    return response;
  }
  Future<bool> impose(SoundClip clip)async{
    // fetch all player ids to notify
    List<String> pids=[];
    SharedPref sharedPref=new SharedPref();
    Map<String,dynamic> user=await sharedPref.read("user");
    String cid=await user['email'];
    QuerySnapshot snapshot=await FirebaseFirestore.instance.collection("EmployeeDevices").where("cid",isEqualTo: cid).get();
    if(snapshot.docs.length>0) {
      for (int i = 0; i < snapshot.docs.length; i++) {
          pids.add(snapshot.docs[i].data()['playerId']);
      }
      // notify all of them
      var notification = OSCreateNotification(
        playerIds: pids,
        content: clip.description,
        heading: clip.title,
        additionalData: {
           "clipUrl":clip.clipUri
        }
      );
      var response = await OneSignal.shared.postNotification(notification);
      return true;
    }
    return false;
  }

}