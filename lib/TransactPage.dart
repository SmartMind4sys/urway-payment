
import 'dart:convert';
import 'dart:io';


import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import 'package:urwaypayment/Model/TrxnRespModel.dart';
import 'package:urwaypayment/ResponseConfig.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';


class TransactPage extends StatefulWidget {

  final String inURL,title;
  Function onBack; 
  bool ar=false;
  Widget appBar;
  
  TransactPage({Key? key,required this.inURL,required this.onBack,this.ar=false,this.title='',required this.appBar}):super(key:key);

  @override
  _TransactPageState createState() => _TransactPageState();
}

class _TransactPageState extends State<TransactPage> {

  // InAppWebViewController? webViewController;
  String url = "";
  String myUrl = "";
  double progress = 0;
  late String payId;
  late String responseHash;
  late String ResponseCode;
  late String transId;
  late String amount;
  late String cardToken;
  late String cardBrand;
  late String maskedCardNo;
  late String result;

  final Completer<WebViewController> _controller =
  Completer<WebViewController>();
  Future<bool> onBackPressed() async {
    // Your back press code here...
    // ResponseConfig.startTrxn = false;
    // Navigator.pop(context, true);
    // return Future.value(false);

    var canBack=false;

    for(var e in urls){
      if(e.contains(myUrl));
      canBack=true;
      break;
    }

    if(canBack){
      widget.onBack();

         return Future.value(true);
    }
    else{

      return Future.value(false);

    }
    
  }
 @override
 void initState() {
   // TODO: implement initState
   super.initState();
   if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView(); // <<== THIS

   //SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
 }
 var urls=['https://payments.urway-tech.com/URWAYPGService/HTMLPage.html'
 ,
   'https://payments.urway-tech.com/URWAYPGService/direct.jsp'
 ];
 var targetUrl= "https://payments-dev.urway-tech.com/URWAYPGService/direct.jsp";
 var targetUrl2= "https://payments-dev.urway-tech.com/URWAYPGService/HTMLPage.html";
  @override
  Widget build(BuildContext context) {
   // pr = new ProgressDialog(context,);
   //  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
   //    statusBarColor: Colors.blueGrey, //or set color with: Color(0xFF0000FF)
   //  ));
    // pr.style(
    //     message: 'Please wait...',
    //     borderRadius: 10.0,
    //     backgroundColor: Colors.white,
    //     progressWidget: CircularProgressIndicator(),
    //
    //     elevation: 10.0,
    //     insetAnimCurve: Curves.easeInOut,
    //     progress: 0.0,
    //     maxProgress: 100.0,
    //     progressTextStyle: TextStyle(
    //         color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
    //     messageTextStyle: TextStyle(
    //         color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600)
    // );
    return WillPopScope(onWillPop:onBackPressed ,
        child:Scaffold(
      body: SafeArea(

        child:Container(
            margin: const EdgeInsets.all(1.0),
            child:
            Column(children: [
              SizedBox(height: 20,),
              myAppBar2(title: widget.title,),
              SizedBox(height: 3,),

              Expanded(child:
              WebView(
                initialUrl: widget.inURL,
                javascriptMode: JavascriptMode.unrestricted,
                zoomEnabled: true,
                backgroundColor: Colors.white,
                onWebViewCreated: (WebViewController webViewController) async{
                  _controller.complete(webViewController);
                  myUrl=' ${await webViewController.currentUrl()}';


                },

                navigationDelegate: (NavigationRequest request) {

                  myUrl=request.url;
                  // if(request.url.contains('provider')) {
                  //
                  // //  logic.updateBack(true);
                  //   //You can do anything
                  //
                  //   //Prevent that url works
                  //   // return NavigationDecision.prevent;
                  // }
                  //Any other url works
                  return NavigationDecision.navigate;
                },

                onPageFinished: (url){
                  myUrl=url;

                  var disurl=url.toString();
                  print('Transact URl  $disurl');
                  //pr.hide();
                  if (disurl.contains("&Result")) {

//            RegExp regExp = new RegExp("Result=(.*)&Track");
//            token = regExp.firstMatch(url).group(1);
                    List<String> arr = url.toString().split('?');
                    var resData=arr[1];
                    print('RES DATA $resData');
                    String lastData=splitResponse(arr[1]);
                    print('Transact $lastData');
                    Navigator.pop(context, '$lastData');
                }},

              )




//                   InAppWebView(
//                 initialUrlRequest:
//                 URLRequest(url: Uri.parse(widget.inURL)
//
//
//                 ),
//
//
//
//                    // initialOptions: InAppWebViewWidgetOptions(
//                    //     inAppWebViewOptions: InAppWebViewOptions(
//                    //       debuggingEnabled: true,
//                    //
//                    //     ),
//                    //
//                    // ),
//                 onWebViewCreated: (InAppWebViewController controller) {
//                   webViewController = controller;
//                   //  pr.show();
//
//
//                 },
//
//                 onLoadStart: (InAppWebViewController controller, Uri? url) {
//                   setState(()
//                   {
// //            pr.show();
//                     this.url = url.toString();
//                   });
//                 },
//
//                 onLoadStop: (InAppWebViewController controller, Uri? url) async {
//                   print(this.url);
//                   // int result1 = await controller.evaluateJavascript(source: "10 + 20;");
//                   // print(result1);
//                   var disurl=url.toString();
//                   print('Transact URl  $disurl');
//                   //pr.hide();
//                   if (disurl.contains("&Result")) {
//
// //            RegExp regExp = new RegExp("Result=(.*)&Track");
// //            token = regExp.firstMatch(url).group(1);
//                     List<String> arr = url.toString().split('?');
//                     var resData=arr[1];
//                     print('RES DATA $resData');
//                     String lastData=splitResponse(arr[1]);
//                     print('Transact $lastData');
//                     Navigator.pop(context, '$lastData');
//
// //
// //            showResDialog( context);
// //                            Navigator.of(context, rootNavigator: true)
// //                                .push(MaterialPageRoute(
// //                                builder: (context) => new HomePage()));
//
//                   }
//                 },
//                 onProgressChanged: (InAppWebViewController controller, int progress) {
//                   setState(() {
//                     this.progress = progress / 100;
//                   });
//                 },
//               )

              )
            ],)
        ),
      ),
    ));
  }

  String splitResponse(String resultData)
  {
    print('splitResponse $resultData');
    List<String> resultParameters=resultData.split("&");
    for (String parameter in resultParameters) {
      List parts = parameter.split("=");
      String name = parts[0];
      print("parameters[] name=" + name);
      if (name=="PaymentId") {
        print("name pay id " + name);
        payId = parts[1].toString();
        print("name pay id " + parts[1]);
      }
      if (name=="responseHash") {
        print("name response hash " + name);
        responseHash = parts[1].toString();
        print('name response hash $parts[1]');
      }
      if (name=="ResponseCode") {
        print("name pay id " + name);
        ResponseCode = parts[1].toString();
        print("name pay id " + parts[1]);
      }
      if (name == "TranId") {
        print("name pay id " + name);
        transId = parts[1].toString();
        print("name pay id " + parts[1]);
      }
      if (name=="amount") {
        print("name pay id " + name);
        amount = parts[1].toString();
        print("name pay id " + parts[1]);
      }

      if (name=="cardToken") {
        print("name pay id " + name);
        cardToken = parts[1].toString();
        print("name pay id " + parts[1]);
      }
      if (name=="cardBrand") {
        print("name pay id " + name);
        cardBrand = parts[1].toString();
        print("name pay id " + parts[1]);
      }
      if (name=="Result") {
        print("Result " + name);
        result = parts[1].toString();
        print("name pay id " + parts[1]);
      }

      if (name=="maskedPAN")
      {
        print("name pay id " + name);
        maskedCardNo = parts[1].toString();
        print("name pay id " + parts[1]);
      }
    }
    TrxnRespModel trxnRespModel=new TrxnRespModel(TranId: payId,ResponseCode: ResponseCode,amount: amount,result:result ,cardToken: cardToken,cardBrand: cardBrand,maskedPanNo: maskedCardNo,ResponseMsg: "");
    var resp= json.encode(trxnRespModel.toMap());
    print("TRANSACT RESP $resp");
    ResponseConfig.startTrxn = false;
    return resp;

  }



  Widget myAppBar2({String title='',double  h= 10,withBack=true,bool isHome=false,bool  showAll=false}) {

   
   

    return             Directionality(
      textDirection:widget.ar? TextDirection.rtl:TextDirection.ltr,
      child:Row(children: [
        SizedBox(width: 20,),

        Container(
          color: Colors.white,
          //  color: color,
          margin: EdgeInsets.only(top: h,bottom: 0),
          child:GestureDetector(
              onTap: ()async{
                var b=await onBackPressed();


              },
              child:
              widget.appBar,
        )),

        SizedBox(width: 20,),

        Expanded(
          child: Padding(
            padding:  EdgeInsets.only(top:0),
            child:
            Text(title.toUpperCase(),maxLines: 2,style: TextStyle(fontSize: 20,color: Color(0xff00B3CD),fontWeight: FontWeight.bold),),
          ),
        ),

      ]),
    )
      
    ;


  }

}
