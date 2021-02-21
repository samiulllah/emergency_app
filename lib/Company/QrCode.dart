import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';
import 'package:emergency_app/Providers/SharedPref.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuts_activity_indicator/nuts_activity_indicator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';
import 'package:sizer/sizer.dart';
import 'dart:ui' as ui;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../Constants.dart';
import 'Main.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:crypto/crypto.dart';
class CompanyQr extends StatefulWidget {
  @override
  _CompanyQrState createState() => _CompanyQrState();
}

class _CompanyQrState extends State<CompanyQr> {
  GlobalKey globalKey = new GlobalKey();
  String digest;
  bool loading=true;
  ScreenshotController screenshotController = ScreenshotController();
  void generateDigest()async{
    SharedPref sharedPref=new SharedPref();
    Map<String,dynamic> user=await sharedPref.read("user");
    String cid=await user['email'];
    var bytes1 = utf8.encode(cid);
    List<int> d = md5.convert(bytes1).bytes;
    setState(() {
       digest=d.toString();
       loading=false;
    });
  }

  @override
  void initState(){
    generateDigest();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       debugShowCheckedModeBanner: false,
       home: Scaffold(
          body: Container(
              padding: EdgeInsets.all(12.0),
              child:Column(
                 crossAxisAlignment: CrossAxisAlignment.center,
                 children: [
                   SizedBox(height: 10.0.h,),
                   Center(
                     child: !loading?Screenshot(
                       controller: screenshotController,
                       child: QrImage(
                         data: digest,
                         version: QrVersions.auto,
                         size: 250.0,
                       ),
                     ):NutsActivityIndicator(
                       radius: 20,
                       activeColor: Colors.indigo,
                       inactiveColor: Colors.red,
                       tickCount: 11,
                       startRatio: 0.55,
                       animationDuration: Duration(milliseconds: 123),
                     ),
                   ),
                  SizedBox(height: 10.0.h,),
                   RaisedButton(
                     color: Constants.primary ,
                     shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.all(Radius.circular(10))
                     ),
                     child:SizedBox(
                         width: 30.0.w,
                         child: Center(child: Text("Print",style: GoogleFonts.lato(color:Colors.white,fontSize: 20),))
                     ),
                     onPressed: ()async{
                       String uri=await _captureGetPath();
                       if(uri!=null) {
                         Navigator.of(context).push(MaterialPageRoute(
                             builder: (BuildContext context) => QrPdf(uri:uri,)));
                       }
                     },
                   )
                 ],
              )
          ),
       ),
    );
  }

  Future<String> _captureGetPath() async {
    try {
      File f=await screenshotController.capture(
          delay: Duration(milliseconds: 10),
          pixelRatio: 1.5
      );
      return f.path;
    } catch(e) {
      return null;
    }
  }

}


class QrPdf extends StatefulWidget {
  String uri;
  QrPdf({this.uri});
  @override
  _QrPdfState createState() => _QrPdfState(uri: uri);
}

class _QrPdfState extends State<QrPdf> {
   String uri;
  _QrPdfState({this.uri});
   @override
   void initState(){
     super.initState();
   }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Constants.primary,
        body: Container(
          child: PdfPreview(
            build: (format) => _generatePdf(format, ""),
          ),
        ),
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format, String title) async {
    final pdf = pw.Document();
    final image = await flutterImageProvider(FileImage(File(uri)));
    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {
          return pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children:[
                  pw.Center(
                     child: pw.Image(
                         image
                     )
                  ),
                  pw.SizedBox(height: 40),
                  pw.Center(
                     child: pw.Text("Please scan this image to get registered",style: pw.TextStyle(fontSize: 24,fontWeight: pw.FontWeight.bold))
                  )

              ]
          );
        },
      ),
    );
    return pdf.save();
  }
}
