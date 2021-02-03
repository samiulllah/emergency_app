import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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

class CompanyQr extends StatefulWidget {
  @override
  _CompanyQrState createState() => _CompanyQrState();
}

class _CompanyQrState extends State<CompanyQr> {
  GlobalKey globalKey = new GlobalKey();
  ScreenshotController screenshotController = ScreenshotController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       debugShowCheckedModeBanner: false,
       home: Scaffold(
          body: Container(
              child:Column(
                 crossAxisAlignment: CrossAxisAlignment.center,
                 children: [
                   SizedBox(height: 10.0.h,),
                   Center(
                     child: Screenshot(
                       controller: screenshotController,
                       child: QrImage(
                         data: "1234567890",
                         version: QrVersions.auto,
                         size: 250.0,
                       ),
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
   void initState() {
     super.initState();

     BackButtonInterceptor.add(myInterceptor);
   }

   @override
   void dispose() {
     BackButtonInterceptor.remove(myInterceptor);
     super.dispose();
   }

   bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info)  {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
         builder: (BuildContext context) => CompanyMain()));
     return true;
   }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
                  pw.Image(
                     image
                  ),
                  pw.SizedBox(height: 40),
                  pw.Text("Please scan this image to get registered",style: pw.TextStyle(fontSize: 24,fontWeight: pw.FontWeight.bold))
              ]
          );
        },
      ),
    );
    return pdf.save();
  }
}
