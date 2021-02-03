import 'package:emergency_app/Employee/RegistrationScreen.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:io';
class ScanQr extends StatefulWidget {
  @override
  _ScanQrState createState() => _ScanQrState();
}

class _ScanQrState extends State<ScanQr> {
  Barcode result;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    } else if (Platform.isIOS) {
      controller.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context)  {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _buildQrView(context),
            Positioned(
                top: 50,
                right: 20,
                child: FutureBuilder(
                    future: controller?.getFlashStatus(),
                    builder: (context, snapshot) {
                      if(snapshot.data){
                         return GestureDetector(
                             onTap: (){
                                 setState(() {
                                   controller?.toggleFlash();
                                 });
                             },
                             child: Icon(Icons.lightbulb,color: Colors.yellow,size: 40,)
                         );
                      }
                      else{
                         return GestureDetector(
                             onTap: (){
                               setState(() {
                                 controller?.toggleFlash();
                               });
                             },
                             child: Icon(Icons.lightbulb_outline,color: Colors.yellow,size: 40,));
                      }
                    },
               )
            ),


        ],
      )
    );
  }

  Widget _buildQrView(BuildContext context) {

    var scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 300.0
        : 350.0;

    return QRView(
      key: qrKey,
      cameraFacing: CameraFacing.front,
      onQRViewCreated: _onQRViewCreated,
      formatsAllowed: [BarcodeFormat.qrcode],
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
        //result = scanData;
      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => EmployeeRegistration()));
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
