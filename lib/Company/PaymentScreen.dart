
import 'dart:io';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:credit_card_input_form/credit_card_input_form.dart';
import 'package:emergency_app/Constants.dart';
import 'package:emergency_app/Providers/SharedPref.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_braintree/flutter_braintree.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuts_activity_indicator/nuts_activity_indicator.dart';

import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'Main.dart';
import 'package:sizer/sizer.dart';


class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  static final String tokenizationKey = 'sandbox_mftb7h7b_8hjhpztfsgj7k888';
  String nounce;
  String userName,uid;
  bool processing=false;
  bool afterPay=false;
  double amountToCharge=1500.0;

  bool getUserProgress=true;

  void getUserData()async{
    SharedPref sharedPref=new SharedPref();
    Map<String,dynamic> user=await sharedPref.read("user");
    uid=await user['email'];
    userName=await user['name'];
  }
  void checkFirstTime()async{
     // check if user have some processing submitted if yes show check its status to let him continue
     List<String> res=await checkPaymentProcessing();
     if(res[0]=="1"){
        //settling  show msg
         setState(() {
           getUserProgress=false;
           afterPay=true;
         });
     }
     else if(res[0]=="2"){
       // settled navigate him to home screen with pushReplacement
       Navigator.of(context).pushReplacement(MaterialPageRoute(
           builder: (BuildContext context) => CompanyMain(utype: 0,)));
     }
     else{
       // doesn't exist mean app was exit before payment
       setState(() {
         getUserProgress=false;
       });
     }

  }

  Future<List<String>> checkPaymentProcessing()async{
    List<String> res=new List();
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(
          "PaymentProcessing").where("email", isEqualTo: uid).get();
      if (snapshot.docs.length > 0) {
        String tid = snapshot.docs[0].data()['tid'];
        String status = await find(tid);
        if (status != null && status == "settled") {
          // update payment status of uid to 1
          await updateToPayed();
          res.add("2");
        }
        else {
          res.add("1");
        }
      }
      else {
        res.add("0");
      }
    }catch(e){
      print("exception occured ----> "+e.toString());
    }
    return res;
  }
  Future<bool> updateToPayed()async{
    QuerySnapshot snapshot=await FirebaseFirestore.instance.collection("PaymentProcessing").where("email",isEqualTo: uid).get();
    if(snapshot.docs.length>0){
       await snapshot.docs[0].reference.delete();
       QuerySnapshot snap=await FirebaseFirestore.instance.collection("CompanyRegistrations").where("CompanyEmail",isEqualTo: uid).get();
       if(snap.docs.length>0){
         SharedPref sharedPref=new SharedPref();
         Map<String,dynamic> user=await sharedPref.read("user");
          user['isPayed']="1";
         await sharedPref.save("user",{'type':'0','name':user['name'],'email':user['email'],'phone':user['phone'],'address':user['address'],'isPayed':'1'});
           snap.docs[0].reference.update({
               "isPayed":"1"
           });
       }
       else{
         return false;
       }
    }
    return false;
  }
  void fetchAmountToCharge()async{
    DocumentSnapshot snapshot=await FirebaseFirestore.instance.collection('AccountCost').doc('CAC').get();
    amountToCharge=double.parse(snapshot.get('cost').toString());
  }
  @override
  void initState(){
    fetchAmountToCharge();
    getUserData();
    checkFirstTime();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: !getUserProgress?Constants.primary:Colors.white,
      body: !getUserProgress?!afterPay?!processing?showGuide():checkoutView():afterPaymentWaiting()
            :Center(
              child: NutsActivityIndicator(
                radius: 20,
                activeColor: Colors.indigo,
                inactiveColor: Colors.red,
                tickCount: 11,
                startRatio: 0.55,
                animationDuration: Duration(milliseconds: 123),
              ),
            )
    );
  }

  Widget checkoutView(){
    return Container(
      padding: EdgeInsets.only(left: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 10.0.h,),
          Icon(Icons.payments,size: 20.0.h,color: Colors.white,),
          SizedBox(height: 5.0.h,),
          Text("Dear $userName,",style: GoogleFonts.lato(fontSize: 28,color: Colors.white),),
          SizedBox(height: 5.0.h,),
          Flexible(
              child: Text("Your payment method is verified, proceed by clicking checkout button",
                style: GoogleFonts.lato(fontSize: 18,color: Colors.white),textAlign: TextAlign.left,)),
          SizedBox(height: 10.0.h,),
          Center(
            child:RaisedButton(
              color: Constants.secondary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
              ),
              child: SizedBox(
                width: 60.0.w,
                child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                       Icon(Icons.money_outlined,size: 20,color: Colors.white,),
                       Text("Check Out",style: GoogleFonts.lato(color: Colors.white,fontSize: 21),),
                       Text("\$ ${amountToCharge}",style: GoogleFonts.lato(color: Colors.cyan,fontSize: 21),),
                    ],
                ),
              ),
              onPressed: ()async{
                await checkout();
              },
            )
            ,
          )
        ],
      ),
    );
  }

  Widget showGuide(){
    return Container(
       padding: EdgeInsets.only(left: 20),
       child: Column(
           crossAxisAlignment: CrossAxisAlignment.stretch,
           children: [
               SizedBox(height: 10.0.h,),
               Icon(Icons.payments,size: 20.0.h,color: Colors.white,),
               SizedBox(height: 5.0.h,),
               Text("Dear $userName !",style: GoogleFonts.lato(fontSize: 28,color: Colors.white,fontWeight:FontWeight.bold),),
               SizedBox(height: 5.0.h,),
               Flexible(
                   child: Text("You are only one step away from your company registration, You have to pay one time fee to user"
                       "our services please",
                   style: GoogleFonts.lato(fontSize: 18,color: Colors.white),textAlign: TextAlign.left,)),
             SizedBox(height: 8.0.h,),
             Center(
                 child:RaisedButton(
                   color: Constants.secondary,
                   shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(10)
                   ),
                   child: Text("Pay Now",style: GoogleFonts.lato(color: Colors.white,fontSize: 21),),
                   onPressed: ()async{
                      await dropInNativeUI();
                   },
                 )
                ,
              )
           ],
       ),
    );
  }
  Widget afterPaymentWaiting(){
    return Container(
      padding: EdgeInsets.only(left: 20,right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 10.0.h,),
          Icon(Icons.payments,size: 20.0.h,color: Colors.white,),
          SizedBox(height: 5.0.h,),
          Text("Dear $userName,",style: GoogleFonts.lato(fontSize: 28,color: Colors.white,fontWeight:FontWeight.bold),),
          SizedBox(height: 8.0.h,),
          Flexible(
              child: Text("Thank you for your keen interest in our service we've received your request and processing it. It might"
                  " take a while to let you get started. Once its done we'll be back to you",
                style: GoogleFonts.lato(fontSize: 18,color: Colors.white),textAlign: TextAlign.left,)),
        ],
      ),
    );
  }
  final Map<String, String> customCaptions = {
    'PREV': 'Prev',
    'NEXT': 'Next',
    'DONE': 'Done',
    'CARD_NUMBER': 'Card Number',
    'CARDHOLDER_NAME': 'Cardholder Name',
    'VALID_THRU': 'Valid Thru',
    'SECURITY_CODE_CVC': 'Security Code (CVC)',
    'NAME_SURNAME': 'Name Surname',
    'MM_YY': 'MM/YY',
    'RESET': 'Reset',
  };
  final buttonStyle = BoxDecoration(
    borderRadius: BorderRadius.circular(30.0),
    color:Color(0xff7a6664),
  );

  final cardDecoration = BoxDecoration(
      boxShadow: <BoxShadow>[
        BoxShadow(color: Colors.black54, blurRadius: 15.0, offset: Offset(0, 8))
      ],
      color:Color(0xff7a6664),
      borderRadius: BorderRadius.all(Radius.circular(15)));

  final buttonTextStyle =
  TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18);

  Future<List<String>> showIosPayment()async{

    String cardNo=null,month=null,year=null;
      AlertDialog alert = AlertDialog(
      content:  Container(
         width: double.maxFinite,
        child: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             CreditCardInputForm(
               cardHeight: 170,
               showResetButton : true,
               onStateChange: (currentState, cardInfo) {
                 List<String> cardSplit=cardInfo.toString().split(',');
                 if(cardSplit.length>0) {
                   List<String> cardNoSplit=cardSplit[0].split('=');
                   if(cardNoSplit.length>0)
                       cardNo = cardInfo.toString().split(',')[0].split('=')[1];
                 }
                 List<String> mySplit=cardInfo.toString().split(',')[2].split('=')[1].split('/');
                 if(mySplit.length>0) {
                   month =
                   cardInfo.toString().split(',')[2].split('=')[1].split(
                       '/')[0];
                   year = cardInfo.toString().split(',')[2].split('=')[1].split(
                       '/')[1];
                 }
                 print("card no - $cardNo and month = $month and year = $year");

               },
               customCaptions: customCaptions,
               frontCardDecoration: cardDecoration,
               backCardDecoration: cardDecoration,
               prevButtonDecoration: buttonStyle,
               nextButtonDecoration: buttonStyle,
               resetButtonDecoration : buttonStyle,
               prevButtonTextStyle: buttonTextStyle,
               nextButtonTextStyle: buttonTextStyle,
               resetButtonTextStyle: buttonTextStyle,
               initialAutoFocus: true, // optional

             ),
             SizedBox(height: 10,),
             RaisedButton(
                color: Color(0xff7a6664),
                textColor: Colors.white,
                 shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(15.0)),
                 onPressed: (){
                  Navigator.of(context, rootNavigator: true).pop();
                },
                child:Text("Submit")
             )
           ],
        ),
      ),
    );
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
    List<String> res=[];
    if(cardNo!=null)
      res.add(cardNo);
    if(month!=null)
      res.add(month);
    if(year!=null)
       res.add(year);
    return res;
  }
  void dropInNativeUI()async {
    processingDialog(context);
    if (Platform.isIOS) {
      try{
      List<String> re=await showIosPayment();
      if(re.length>0) {
        final request = BraintreeCreditCardRequest(
          cardNumber: re[0],
          expirationMonth: re[1],
          expirationYear: re[2],
        );
        BraintreePaymentMethodNonce res =
        await Braintree.tokenizeCreditCard(
          tokenizationKey,
          request,
        );
        print("nounce = ${res.nonce}");
        nounce =res.nonce.toString();
        Navigator.of(context, rootNavigator: true).pop();
        setState(() {
          processing = true;
        });
      }else{
        Toast.show("Failed to add payment method try again with complete and correct details!", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      }
      }catch(e){
        Toast.show("something went wrong !", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      }
    } else{
          var request = BraintreeDropInRequest(
            tokenizationKey: tokenizationKey,
            collectDeviceData: true,
            googlePaymentRequest: BraintreeGooglePaymentRequest(
              totalPrice: amountToCharge.toString(),
              currencyCode: 'USD',
              billingAddressRequired: false,
            ),
            paypalRequest: BraintreePayPalRequest(
              amount:  amountToCharge.toString(),
              displayName: 'Emergency',
            ),
            cardEnabled: true,
          );
        BraintreeDropInResult result =
        await BraintreeDropIn.start(request);
        if (result != null) {
          nounce = result.paymentMethodNonce.nonce.toString();
          Navigator.of(context, rootNavigator: true).pop();
          setState(() {
            processing = true;
          });
        } else {
          Toast.show("Failed to add payment method try again!", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
        }
    }
  }
  Future<bool> checkout()async{
    processingDialog(context);
    String url='https://rocky-garden-28799.herokuapp.com/checkout?nounce=$nounce&amount=$amountToCharge';
    var response = await http.get(url);
    var rs=await convert.jsonDecode(response.body);
    if (response.statusCode == 200) {
      Navigator.of(context, rootNavigator: true).pop();
      Toast.show("check out success!", context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP);
      String tid=rs['res']['transaction']['id'];
      //write tid and uid to firebase for payment in processing
      await FirebaseFirestore.instance.collection("PaymentProcessing").add({
        "email":uid,
         "tid":tid,
        "amount":"$amountToCharge",
         "datetime":DateTime.now().toString()
      });
      setState(() {
        afterPay=true;
      });
    } else {
      Navigator.of(context, rootNavigator: true).pop();
      Toast.show("Failed to checkout try again!", context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP);
      return false;
    }
  }
  Future<String> find(String tid)async{
    String url='https://rocky-garden-28799.herokuapp.com/find?tid=$tid';
    var response = await http.get(url);
    var rs=await convert.jsonDecode(response.body);
    if (response.statusCode == 200) {
      print("Payment status is -----> ${rs['res']['status']}");
      return rs['res']['status'];
    } else {
       return null;
    }
  }

  processingDialog(BuildContext context)async{

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
  }
}
