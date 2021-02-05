import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:emergency_app/Employee/RegistrationScreen.dart';
import 'package:emergency_app/Providers/EmployeeServies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:flutter_qr_bar_scanner/qr_bar_scanner_camera.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:io';

import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:toast/toast.dart';

import '../Constants.dart';
class ScanQr extends StatefulWidget {
  @override
  _ScanQrState createState() => _ScanQrState();
}



class _ScanQrState extends State<ScanQr> {
  String _qrInfo = 'Scan a QR/Bar code';
  bool _camState = false;

  _qrCallback(String code) {
    setState(() {
      _camState = false;
      _qrInfo = code;
    });
    processingPopup(context);
  }

  _scanCode() {
    setState(() {
      _camState = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _scanCode();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: _camState
          ? Center(
        child: SizedBox(
          height: 1000,
          width: 500,
          child: QRBarScannerCamera(
            onError: (context, error) => Text(
              error.toString(),
              style: TextStyle(color: Colors.red),
            ),
            qrCodeCallback: (code) {
              _qrCallback(code);
            },
          ),
        ),
      )
          : Container(),
    );
  }
  processingPopup(BuildContext context)async{
    int k=-1;
    List<Map<String,dynamic>> mails;
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
      //Matching
      EmployeeOperations eo=new EmployeeOperations();
      List<Map<String,dynamic>> emails=await eo.getAllHashedEmails();
      mails=emails;
      for(int i=0;i<emails.length;i++){
        if(emails[i]['digest']==_qrInfo){
          k=i;
          break;
        }
      }
      Navigator.of(context, rootNavigator: true).pop();
    });
    if(k>=0){
      await FlutterBeep.beep();
      await showMessage(context,mails[k]['name'],mails[k]['cid']);
    }else{
      await FlutterBeep.beep(false);
      setState(() {
         _camState=true;
      });
      Toast.show("Invalid Qr code!", context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP);
    }
  }
  void showMessage(BuildContext context,String name,String email)async{
    await Alert(
      context: context,
      type: AlertType.info,
      title: "Is this your company name $name?",
      desc: "If yes proceed else rescan.",
      buttons: [
        DialogButton(
          child: Text(
            "Proceed",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed:()async{
            // nav to registration page
            await Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => EmployeeRegistration(cname: name,cid: email,)));
            Navigator.of(context).pop();
          },
          color: Constants.primary,
          radius: BorderRadius.circular(10.0),
        ),
        DialogButton(
          child: Text(
            "Rescan",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            setState(() {
              _camState=true;
            });
            Navigator.of(context, rootNavigator: true).pop();
          },
          color: Constants.secondary,
          radius: BorderRadius.circular(10.0),
        )
      ],
    ).show();
  }
}


