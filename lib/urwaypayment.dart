library urwaypayment;

import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:core';
import 'package:apple_pay_flutter/apple_pay_flutter.dart';
import 'package:connectivity/connectivity.dart';
import 'package:convert/convert.dart';
import 'package:dart_ipify/dart_ipify.dart';
import 'package:device_info/device_info.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:flutter_ip/flutter_ip.dart';
// import 'package:get_ip/get_ip.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:progress_dialog/progress_dialog.dart';
import 'package:urwaypayment/Constantvals.dart';
import 'package:urwaypayment/Model/DeviceDetailsModel.dart';
import 'package:urwaypayment/Model/PayRefundReq.dart';
import 'package:urwaypayment/Model/PaySTC.dart';
import 'package:urwaypayment/Model/PayTokenizeReq.dart';
import 'package:urwaypayment/Model/PaymentReq.dart';
//import 'package:urwaypayment/Model/PaymentResp.dart';
//import 'package:urwaypayment/MyChromeSafariBrowser.dart';
//import 'package:urwaypayment/MyInAppBrowser.dart';
import 'package:urwaypayment/ResponseConfig.dart';
// import 'package:wifi_ip/wifi_ip.dart';




import 'Model/Post.dart';
import 'Model/TrxnRespModel.dart';
import 'TransactPage.dart';
import 'package:crypto/crypto.dart';


class Payment {


  // ProgressDialog pr;


  static Future get _localPath async {
    // Application documents directory:
    // /data/user/0/{package_name}/{app_name}
    String? dirPath;


    if (Platform.isIOS) {
      final appDirectory = await getApplicationDocumentsDirectory();
      dirPath = appDirectory.path;
      print("ios $dirPath");
    }

    else if (Platform.isAndroid) {
      // External storage directory: /storage/emulated/0
      final externalDirectory = await getExternalStorageDirectory();
      dirPath = externalDirectory!.path;
      print("android $dirPath");
    }
    print("_localPath");

    // Application temporary directory: /data/user/0/{package_name}/cache
    final tempDirectory = await getTemporaryDirectory();

    return dirPath;
  }

  static Future get _localFile async {
    final path = await _localPath;
    final folderName = "urway";
    print("TXT PATH $path");
//    final path=Directory("storage/emulated/0/$folderName").create();

    return File('$path/RespReqLog.txt');
  }

  static Future _writetoFile(String text) async {


    final file = await _localFile;


    var now1 = new DateTime.now();
    String datetime = now1.toString();
    var header = datetime + ": " + text;
    File result = await file.writeAsString(header, mode: FileMode.append);

    if (result == null)
    {
      print("Writing to file failed");
    }
    else
    {
      print('$text');
    }
  }

  /*****  WRITE FILE CODE END  *****/

  static Future<String> makepaymentService({
    required BuildContext context, required String country, required String action, required String currency, required String amt, required String customerEmail, required String trackid, required String udf1, required String udf2, required String udf3, required String udf4, required String udf5, required String address, required String city, required String zipCode, required String state, required String cardToken, required String tokenizationType, required String tokenOperation
    ,
    required Function onBack,required String title,required bool ar,required Widget appBar
  }) async {
    assert(context != null, "context is null!!");

    String payRespData="";
    // if (ResponseConfig.startTrxn != Constantvals.appinitiateTrxn) {
    if (true) {
      ResponseConfig.startTrxn = true;

      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          var order = await _read(
              context,
              country,
              action,
              currency,
              amt,
              customerEmail,
              trackid,
              udf1,
              udf2,
              udf3,
              udf4,
              udf5,
              address,
              city,
              zipCode,
              state,
              cardToken,
              tokenizationType,
              tokenOperation,
            onBack,
            title,ar,appBar
          );
          payRespData = order;
        }
      }
      on SocketException catch (e)
      {
        ResponseConfig.startTrxn = false;
        payRespData="Please check internet connection";
      }
    }
    // else
    //   {
    //     payRespData= "Transaction already initiated";
    //   }

    return payRespData;
  }


  static getPermission() async {
    if (await Permission.contacts
        .request()
        .isGranted) {
      // Either the permission was already granted before or the user just granted it.
    } else {
      // You can request multiple permissions at once.
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
      print(statuses[Permission.location]);
    }
  }

  static Future<String> _read(BuildContext context, String country,
      String action, String currency, String amt, String customerEmail,
      String trackid, String udf1, String udf2, String udf3, String udf4,
      String udf5, String address, String city, String zipCode, String state,
      String cardToken, String tokenizationType, String tokenOperation,
      Function onBack,String title,bool ar, Widget appBar) async {
    String text;
//    InAppWebViewController webView;
    String url = "";
    String readRespData= "";
    String result;
    double progress = 0;
    String pipeSeperatedString;
   // Function? onBack;
    var body;
    var wifiIp;
    ResponseConfig resp = ResponseConfig();
    var ipAdd = "";
    PaymentReq payment;
    // ProgressDialog pr = new ProgressDialog(context);
    String compURL;
    var devicemodel ="";
    var deviceVersion ="";
    var devicePlatform ="";
    var pluginName="";
    var pluginVersion="";
    var pluginPlatform="";


//    WifiIpInfo _result;
//     pr.style(
//         message: 'Please wait1...',
//         borderRadius: 10.0,
//         backgroundColor: Colors.white,
//         progressWidget: CircularProgressIndicator(),
//         elevation: 10.0,
//         insetAnimCurve: Curves.easeInOut,
//         progress: 0.0,
//         maxProgress: 100.0,
//         progressTextStyle: TextStyle(
//             color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
//         messageTextStyle: TextStyle(
//             color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600)
//     );


    text =
    await DefaultAssetBundle.of(context).loadString('assets/appconfig.json');
    final jsonResponse = json.decode(text);
    print(jsonResponse);
    var t_id = jsonResponse["terminalId"] as String;
    var t_pass = jsonResponse["terminalPass"] as String;
    var merc = jsonResponse["merchantKey"] as String;
    var req_url = jsonResponse["requestUrl"] as String;
    Constantvals.termId = t_id;
    Constantvals.termpass = t_pass;
    Constantvals.merchantkey = merc;
    Constantvals.requrl = req_url;

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      print("Connected to Mobile Network");
      final ipv4 = await Ipify.ipv4();
      print(ipv4);
      //ipAdd = await GetIp.ipAddress;  --ios
      ipAdd = ipv4;
//      ipAdd = await GetIp.ipAddress;
//       ipAdd = await FlutterIp.externalIP;------------------------------------------

      print('merchantIP  mobile $ipAdd');

    } else if (connectivityResult == ConnectivityResult.wifi) {


      print("Connected to WiFi");

      final ipv4 = await Ipify.ipv4();
      print(ipv4);
      //ipAdd = await GetIp.ipAddress;  --ios
      ipAdd = ipv4;
      print('$wifiIp');
//      if(merchantIp == '' || merchantIp == null)
//      {
      //ipAdd = await FlutterIp.externalIP;----------------------------------------------

    }
    else {
      print("Unable to connect. Please Check Internet Connection");
    }
    //ipAdd = "1.1.1.1";
    String ipAdd1;

    if (isValidationSucess(
        context,
        amt,
        customerEmail,
        action,
        country,
        currency,
        trackid,
        tokenOperation,
        cardToken)) {
//    check validation
//    pr.show();
      pipeSeperatedString =
          trackid + "|" + Constantvals.termId + "|" + Constantvals.termpass +
              "|" +
              Constantvals.merchantkey + "|" + amt + "|" + currency;
      print('$pipeSeperatedString');
      var bytes = utf8.encode(pipeSeperatedString);
      Digest sha256Result = sha256.convert(bytes);
      final digestHex = hex.encode(sha256Result.bytes);

/*************************************************************/
    //   {
    //     "deviceInfo": {
    // {
    // "pluginName": "Flutter",
    // "pluginVersion": "1.0",
    // "pluginPlatform": "Mobile/desktop/Tablet",
    // "deviceModel": "iphone 6s",
    // "devicePlatform": "iphone",
    // "deviceOSVersion": "15.0.1"
    // }
    // }


/*************************************************************/
      try {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
         // e.g. "Moto G (4)"
ipAdd='20.74.255.13';

        if (Platform.isAndroid) {
          AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
          print('Running on ${androidInfo.model}');
          devicemodel=androidInfo.model;
          deviceVersion= androidInfo.version.sdkInt.toString();
          devicePlatform="ios";
          pluginName="Flutterios";
          pluginVersion = "1.0";
          pluginPlatform = "Mobile";
        }
        else if (Platform.isIOS) {
          IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
          print('Running on ${iosInfo.utsname.machine}');
          devicemodel=iosInfo.model;
          deviceVersion=iosInfo.systemVersion;
          devicePlatform="ios";
          pluginName="Flutterios";
          pluginVersion = "1.0";
          pluginPlatform = iosInfo.systemVersion;

        }
      } on PlatformException {
        //deviceData = "No Data found";
      }
      DeviceDetailsModel detailsModel =new DeviceDetailsModel(devicemodel: devicemodel, deviceVersion: deviceVersion, devicePlatform: devicePlatform, pluginName: pluginName, pluginVersion: pluginVersion, pluginPlatform: pluginPlatform);
      var devicebody = json.encode(detailsModel.toMap());
      print('devicebody $devicebody');

      //String hashVal=sha256Result.toString();
      print('HashVal $digestHex');
      if (action == '1' || action == '4') { //Purchase and Pre Auth
        payment = new PaymentReq(terminalId: t_id,
            password: t_pass,
            action: action,
            currency: currency,
            customerEmail: customerEmail,
            country: country,
            amount: amt,
            customerIp: ipAdd,
            merchantIp: ipAdd,

            trackid: trackid,
            udf1: udf1,
            udf2: udf2,
            udf3: udf3,
            udf4: udf4,
            udf5: udf5,

            address: address,
            city: city,
            zipCode: zipCode,
            state: state,
            cardToken: cardToken,
            tokenizationType: tokenizationType,
            requestHash: digestHex, tokenOperation: '', udf7: ''
            /*,deviceinfo: devicebody*/);
        body = json.encode(payment.toMap());
        print('action code 1');
        print('mercha $ipAdd');
      }
      else if (action == '12') //tokenization
          {
        PayTokenizeReq payTokenize = new PayTokenizeReq(terminalId: t_id,
            password: t_pass,
            action: action,
            currency: currency,
            customerEmail: customerEmail,
            country: country,
            amount: amt,
            customerIp: ipAdd,
            merchantIp: ipAdd,

            trackid: trackid,
            udf1: udf1,
            udf2: udf2,
            udf3: udf3,
            udf4: udf4,
            udf5: udf5,

            cardToken: cardToken,
            requestHash: digestHex,
            tokenOperation: tokenOperation,
            udf7: ''
          /*  deviceinfo: devicebody*/
        );
        print('action code 12');
        body = json.encode(payTokenize.toMap());
      }
      else if (action == '14') { //Standalone Refund
        PayRefundReq payRefundReq = new PayRefundReq(
            terminalId: t_id,
            password: t_pass,
            action: action,
            currency: currency,
            customerEmail: customerEmail,
            country: country,
            amount: amt,
            customerIp: ipAdd,
            merchantIp: ipAdd,

            trackid: trackid,
            udf1: udf1,
            udf2: udf2,
            udf3: udf3,
            udf4: udf4,
            udf5: udf5,
            // udf7: "ANDROID",
            cardToken: cardToken,
            requestHash: digestHex, udf7: ''/*,deviceinfo: devicebody*/);
        print('action code 14');
        body = json.encode(payRefundReq.toMap());
      }
      else if (action == "13") {
        PaySTC paySTC = new PaySTC(
            terminalId: t_id,
            password: t_pass,
            action: action,
            currency: currency,
            customerEmail: customerEmail,
            amount: amt,
            customerIp: ipAdd,
            merchantIp: ipAdd,
            trackid: trackid,
            udf2: udf2,
            country: country,
            udf3: udf3,
            udf1: udf1,
            udf5: udf5,
            udf4: udf4,
            requestHash: digestHex, udf7: '',
            
            /*deviceinfo: devicebody*/);

        body = json.encode(paySTC.toMap());
      }
      print('Payment Request $body');
      try {
//  var body = '{"transid":"2011919515049822299","amount":"1.00","address":"mahape","customerIp":"10.10.10.227","city":"navi mumbai","trackid":"12121212","terminalId":"recterm","action":"14","password":"password","merchantIp":"9.10.10.102","requestHash":"746c98bf1f13dbb708deb6d2d22b798860f543e9db292bfb475a4b1045ba5e87","country":"IN","currency":"SAR","customerEmail":"swapnil.kapse@concertosoft.com","zipCode":"410209","udf3":"","udf1":"","udf2":"","udf4":"","udf5":"","cardToken":"9114020300486869","tokenizationType":"0","cardholdername":"Akshay Jadhav","instrumentType":"DEFAULT"}';
        print('API nRequest $body');


        _writetoFile("Request " + body + "\n");
        Map<String, String> headers = {
          'Content-type': 'application/json',
          'Accept': 'application/json'
        };

//5123450309390008
        var requrl = Uri.parse(Constantvals.requrl);
        var response = await http.post(
            requrl, headers: headers, body: body);
        print("sucessful api calling");
        print(response.statusCode);
        if (response.statusCode == 200) {
          print(response.body.toString());
          var data = json.decode(response.body);
          var payId = data["payid"] ?? "";
          var tar_url = data["targetUrl"] ?? "";
          var resp_code = data["responseCode"] ?? "";
          //pr.hide();




          if (tar_url != null && !tar_url.isEmpty) {


            //Todo check for ? if already there then don put
            if (tar_url.endsWith('?')) {
              compURL = tar_url + "paymentid=" + payId;
            }

            else {
              compURL = tar_url + "?paymentid=" + payId;
            }


            result = (await Navigator.of(context).push(
                MaterialPageRoute<String>(builder: (BuildContext context) {
                  return  TransactPage(inURL: compURL,onBack:onBack,ar: ar,title: title,appBar: appBar,);
                })))!;
            print('Navigator Otput $result');
          //  _writetoFile(" Response from Hosted Page :  " + result + "\n");

            if (result == null) {
              result = '';

            }
            ResponseConfig.startTrxn = false;
            readRespData = result;
          }
          else if (tar_url == null && resp_code == '000') {


            var pay=null;
            var payId = data["tranid"] as String;
            var ResponseCode = data["ResponseCode"] as String;
            var amount = data["amount"] as String;
            var result = data["result"] as String;
            var transId = data["PaymentId"] as String;
            var cardToken = data["cardToken"] as String;
            var cardBrand = data["cardBrand"] as String;
            var maskedPanNo = data["maskedPAN"] as String;

            if(transId == null )
              {

                pay=payId;
              }
            else
              {
                pay=transId;
              }


            TrxnRespModel trxnRespModel = new TrxnRespModel(TranId: pay,
                ResponseCode: ResponseCode,
                amount: amount,
                result: result,
                cardToken: cardToken,cardBrand: cardBrand,maskedPanNo: maskedPanNo,ResponseMsg: "" );
            var resp = json.encode(trxnRespModel.toMap());
            ResponseConfig.startTrxn = false;
           // _writetoFile(" Response from Hosted Page :  " + resp + "\n");
            readRespData = resp;
          }
          else {
//          Boolean bool = str.toLowerCase().contains(test.toLowerCase());
            var ErrorMsg = "";
            var apirespCode = data["responseCode"] ;
            print("API apirespCode " + apirespCode);
            if (apirespCode == null) {
              apirespCode = data["responsecode"] as String;
              ErrorMsg = resp.respCode['$apirespCode'];
            }
            else
            {
              print("API apirespCode else " + apirespCode);
              ErrorMsg = resp.respCode['$apirespCode'] ?? " Transaction";;
              print("API Error else " + ErrorMsg);
              if( ErrorMsg == null)
                {
                  print("API apirespCode else " + ErrorMsg);

                  ErrorMsg = "Transaction with apirespCode";
                }
            }

            var apiresult = data["result"] as String;
        //    _writetoFile(
        //         " Response from Hosted Page :  " + apirespCode + " : " +
        //             ErrorMsg + "\n");
            print("API Result " + apiresult);
//            print('ResponseCode $apirespCode : $ErrorMsg');
            showalertDailog(context, '$apiresult', '$ErrorMsg');


          }
        }
        else {
//          pr.hide();
          String respCode = response.statusCode.toString();
          // _writetoFile("Response :" + body + "\n");
          showalertDailog(context, 'Error', 'Invalid Request with $respCode');
        }
      }
      on Exception {
        ResponseConfig.startTrxn = false;
        showalertDailog(context, 'Internet Connection',
            'Please check your Internet Connection ');
        print('In Exception of urway payment ');
//          pr.hide();
      }
    }
    else {
//      pr.hide();
      ResponseConfig.startTrxn = false;
    }

    return readRespData;
  }

//Todo  failed api response   responseconfig=flase |
  //Capture Proper Response and work

  static bool isValidationSucess(BuildContext context, String amount,
      String email, String Action, String CountryCode, String Currency,
      String track, String cardOperation, String cardToken) {
    bool d = false;


    final bool isValidEmail = EmailValidator.validate(email);
    bool isValidE = isValidEmailchk(email);
    print('$cardOperation : $isValidE');
    if (amount.isEmpty) {
      showalertDailog(context, 'Error', 'Amount should not be empty');
      ResponseConfig.startTrxn = false;
    }
    else if (email.isEmpty) {
      showalertDailog(context, 'Error', 'Email should not be empty');
      ResponseConfig.startTrxn = false;
    }
    else if (Action.isEmpty || Action.length == 0) {
      showalertDailog(context, 'Error', 'Action Code should not be empty');
      ResponseConfig.startTrxn = false;
    }

    else if (Currency.isEmpty || Currency.length == 0) {
      showalertDailog(context, 'Error', 'Currency should not be empty');
      ResponseConfig.startTrxn = false;
    }
    else if (CountryCode.isEmpty || CountryCode.length == 0) {
      showalertDailog(context, 'Error', 'Country Code should not be empty');
      ResponseConfig.startTrxn = false;
    }
    else if (track.isEmpty || track.length == 0) {
      showalertDailog(context, 'Error', 'Track ID should not be empty');
      ResponseConfig.startTrxn = false;
    }
    else if (Currency.length > 3) {
      showalertDailog(context, 'Error', 'Currency should be proper');
      ResponseConfig.startTrxn = false;
    }

    else if (Action.length > 3) {
      showalertDailog(context, 'Error', 'Action Code should be proper ');
      ResponseConfig.startTrxn = false;
    }
    else if (CountryCode.length > 2) {
      showalertDailog(context, 'Error', 'CountryCode should be proper');
      ResponseConfig.startTrxn = false;
    }
    else if (email.isEmpty) {
      showalertDailog(context, 'Error', 'Email should not be empt');
      ResponseConfig.startTrxn = false;
    }
    else if (!email.isEmpty && (isValidEmail == false)) {
      showalertDailog(context, 'Error', 'Email should be proper');
      ResponseConfig.startTrxn = false;
    }
    else
    if (((Action == '12') && (cardOperation == 'U')) && (cardToken.isEmpty)) {
      showalertDailog(context, 'Error', 'Card Token should not be empty');
      ResponseConfig.startTrxn = false;
    }
    else if ((Action == '12') && (cardOperation == 'D') && cardToken.isEmpty) {
      showalertDailog(context, 'Error', 'Card Token should not be empty');
      ResponseConfig.startTrxn = false;
    }

    else if ((Action == "14") && (cardToken.isEmpty)) {
//      alert.showAlertDialog(context, "Invalid Refund", "Card Token Should not be empty ", false);
      showalertDailog(
          context, 'Invalid Refund', 'Card Token should not be empty ');
      ResponseConfig.startTrxn = false;
    }
    else {
      d = true;
    }
    return d;
  }

  static void showalertDailog(BuildContext context, String title,
      String description) {

    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[

          Container(

            margin: EdgeInsets.only(top: Constantvals.marginTop),

            child: Column(
              mainAxisSize: MainAxisSize.min, // To make the card compact
              children: <Widget>[

                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w700,
                      color:Color(0xff00B3CD)

                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                    color:Color(0xff00B3CD)
                  ),
                ),
                SizedBox(height: 24.0),
                Align(
                  alignment: Alignment.center,

                  child:                       InkWell(
                    onTap: (){

                      Navigator.of(context)
                          .pop(); // To close the dialog//todo close plugin
                      ResponseConfig.startTrxn = false;
                    },

                    child: Container(
                      color: Color(0xff00B3CD),
                      child: Text('OK',style:TextStyle(color:Colors.white)),
                    ),
                  ),

                ),
              ],
            ),
          ),
        ],
      ),
      elevation: 10,
    );
    showDialog(
      context: context,

      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static bool isValidEmailchk(String emailCheck) {

    Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@[a-z]+\.+[a-z]$';
    RegExp regExp = new RegExp(pattern.toString());
    bool chk = regExp.hasMatch(emailCheck);
    print('$chk');
    return chk;
  }


  /********** Apple Pay Transactions **/
  static Future<String> makeapplepaypaymentService({
    required BuildContext context, required String country, required String action, required String currency, required String amt, required String customerEmail, required String trackid, required String udf1, required  String udf2, required String udf3, required String udf4, required String udf5, required String tokenizationType, required String merchantIdentifier, required String shippingCharge, required String companyName
  }) async {
    assert(context != null, "context is null!!");
    dynamic applePaymentData;
    String appleRespdata="";

  //  _writetoFile("Runali Apple :" );
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {

        //perform Apple Pay Token
        try {
//            print("Cnt $country : $currency");
          if (companyName.isEmpty) {
            showalertDailog(context, 'Error','Company Name should not be empty');
            ResponseConfig.startTrxn = false;
          }
          else if (shippingCharge.isEmpty) {
            showalertDailog(context, 'Error','Shipping Charges should not be empty');
            ResponseConfig.startTrxn = false;
          }
          else {

            var dblamt = double.parse(amt);
            var dblshippingcharge = double.parse(shippingCharge);
            // var dbltotalamt=dblamt+dblshippingcharge;
            List<PaymentItem> paymentItems1 = [
              PaymentItem(label: 'Label', amount: dblamt,shippingcharge: dblshippingcharge)
            ];

            // initiate payment
            applePaymentData = await ApplePayFlutter.makePayment(
              countryCode: country,
              currencyCode: currency,
              paymentNetworks: [
                PaymentNetwork.visa,
                PaymentNetwork.mastercard,
                PaymentNetwork.amex,
                PaymentNetwork.mada
              ],
              merchantIdentifier: merchantIdentifier,
              paymentItems: paymentItems1,
              customerEmail: customerEmail,
              customerName: "Demo User",
              companyName: companyName,

            );
            //showalertDailog(context, 'Apple Data',applePaymentData.toString());
            print(applePaymentData.toString());
            _writetoFile("Runali Apple token :" + applePaymentData.toString());
          }
        }
          on PlatformException {
            print('Failed payment');
         //   ResponseConfig.startTrxn = false;
          }
        var totalcharge= double.parse(amt)+double.parse(shippingCharge);
        String strtlchr=totalcharge.toString();
        //

        // String data = json.decode(applePaymentData);

      if(applePaymentData.toString().contains("code"))
        {
           return "";
        }
      else {
            var order = await applepayapi(
            context,
            country,
            action,
            currency,
            strtlchr,
            customerEmail,
            trackid,
            udf1,
            udf2,
            udf3,
            udf4,
            udf5,
            tokenizationType,
            applePaymentData);
            print("APPLE RESP $order");
            appleRespdata = order;
         }
        }
      }
      on SocketException catch (e) {
      ResponseConfig.startTrxn = false;
      appleRespdata = "Please check internet connection";
    }
    print("APPLE RESP appleRespdata $appleRespdata");
    return appleRespdata;
  }
  
  

  static Future<String> applepayapi(BuildContext context, String country,
      String action, String currency, String amt, String customerEmail,
      String trackid, String udf1, String udf2, String udf3, String udf4,
      String udf5, String tokenizationType, dynamic appleToken) async {
    String text;
    String RespData ="";
//    InAppWebViewController webView;
    String url = "";
    String result;
    double progress = 0;
    String pipeSeperatedString;
    var body;
    var wifiIp;
    ResponseConfig resp = ResponseConfig();
    var ipAdd;
    PaymentReq payment;
    // ProgressDialog pr = new ProgressDialog(context);
    String compURL;
    var paymentData = "";
    dynamic paymentTokk;
    text =
    await DefaultAssetBundle.of(context).loadString('assets/appconfig.json');
    final jsonResponse = json.decode(text);
    print(jsonResponse);
    var t_id = jsonResponse["terminalId"] as String;
    var t_pass = jsonResponse["terminalPass"] as String;
    var merc = jsonResponse["merchantKey"] as String;
    var req_url = jsonResponse["requestUrl"] as String;
    Constantvals.termId = t_id;
    Constantvals.termpass = t_pass;
    Constantvals.merchantkey = merc;
    Constantvals.requrl = req_url;

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      print("Connected to Mobile Network");
      final ipv4 = await Ipify.ipv4();
      print(ipv4);

      ipAdd = ipv4;

      print('merchantIP  mobile $ipAdd');
    } else if (connectivityResult == ConnectivityResult.wifi) {
     // WifiIpInfo info;
      try {

        final ipv4 = await Ipify.ipv4();
        print(ipv4);
        ipAdd = ipv4;

      } on PlatformException {
        print('Failed to get broadcast IP.');
      }
//      print("Connected to WiFi apple");
//      print('$ipAdd');

      //ipAdd = await GetIp.ipAddress;
    }
    else {
      print("Unable to connect. Please Check Internet Connection");
    }


    if (isValidationSucess(
        context,
        amt,
        customerEmail,
        action,
        country,
        currency,
        trackid,
        "",
        "")) {

      print("PAYMENT in Runali $appleToken");

      if(["", null].contains(appleToken['paymentData']) )
        {
          print("R********ER  Empty");

        }
      else
        {
          paymentTokk = jsonDecode(appleToken['paymentData']) ?? "empty" ;
          print("R********ER $paymentTokk");
        }

      // final  runaData= jsonDecode(appleToken);

      // var temp = (runaData['paymentData']);
      // Map<dynamic, dynamic> res = jsonDecode(appleToken);
      //


      //print("$paymentTokk  helloo1");

      // if(paymentTokk.isNotEmpty) {
      //
      //  // String strpaymentTokk = paymentTokk['paymentData'] ;
      //   print('apple Token is not empty');
      //   print("$paymentData  hello ");
      // }
      // else
      //   {
      //     print('apple Token is Empty');
      //   }
   //   String paymentData = appleToken['transactionIdentifier'];
     // print("PAYMENT $paymentData");
      pipeSeperatedString =
          trackid + "|" + Constantvals.termId + "|" + Constantvals.termpass +
              "|" +
              Constantvals.merchantkey + "|" + amt + "|" + currency;
      print('$pipeSeperatedString');
      var bytes = utf8.encode(pipeSeperatedString);
      Digest sha256Result = sha256.convert(bytes);
      final digestHex = hex.encode(sha256Result.bytes);

      //String hashVal=sha256Result.toString();
      print('HashVal $digestHex');
      try {
        var jsonBody = jsonEncode({

          'instrumentType': 'DEFAULT',
          'customerEmail': customerEmail,
          'customerName': "",
          'trackid': trackid,
          'action': 1,
          'merchantIp': ipAdd,

          'terminalId': Constantvals.termId,
          'password': Constantvals.termpass,
          'amount': amt,
          'country': country,
          'currency': currency,
         'customerIp': ipAdd,
          // "udf1": "",
          // "udf3": "en",
          "udf4": "ApplePay",
          "udf5": jsonEncode({
            "paymentData": paymentTokk,
            "transactionIdentifier": appleToken['transactionIdentifier'],
            "paymentMethod": appleToken['paymentMethod']
          }).replaceAll('\\', ''),
          'applePayId': 'applepay',
          'requestHash': sha256.convert(utf8.encode(pipeSeperatedString))
              .toString()
        });
        var requrl = Uri.parse(Constantvals.requrl);
        final response = await http.post(
          requrl,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonBody,
        );
        print(jsonBody);
        _writetoFile("Request apple pay :" + jsonBody + "\n");
        print("sucessful api calling: $response ");
        print(response.statusCode);
        if (response.statusCode == 200) {
          _writetoFile("Response apple pay  1:" + response.body.toString() + "\n");
          print(response.body.toString());
          var data = json.decode(response.body);
          var payId = data["tranid"] as String;
       // var tar_url = data["targetUrl"] as String;
          var resp_code = data["responseCode"] as String;
         // pr.hide();
          print("DATTAT $data");
          if (resp_code == '000') {
            var jsonBody = jsonEncode({
              'transid': payId,
              'trackid': trackid,
              'instrumentType': 'DEFAULT',
              'customerEmail': customerEmail,
              'customerName': "",
              'action': 10,
             'merchantIp': ipAdd,
              'terminalId': Constantvals.termId,
              'password': Constantvals.termpass,
              'amount': amt,
              'country': country,
              'currency': currency,
              'customerIp': ipAdd,
              "udf1": "",
              "udf3": "",
              "udf4": "",
              "udf5": "",
              "udf2": "",
              'requestHash': sha256.convert(utf8.encode(pipeSeperatedString)).toString()
            });
            var requrl = Uri.parse(Constantvals.requrl);
            final response = await http.post(
              requrl,
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonBody,
            );
            print("Transaction Enquiry Resp $jsonBody");

            print(response.statusCode);
            if (response.statusCode == 200) {
              print(response.body.toString());
              _writetoFile("Response apple pay :" + response.body.toString() + "\n");
              var data = json.decode(response.body);


              var payId = data["udf2"] as String;
              var ResponseCode = data["responseCode"] as String;
              var amount = data["amount"] as String;
              var result = data["result"] as String;

              var cardToken = data["cardToken"] as String;
              var cardBrand = data["cardBrand"] as String;
              var maskedPanNo = data["maskedPAN"] as String;
             var ResponseMsg = resp.respCode['$ResponseCode'] ?? "";

              TrxnRespModel trxnRespModel = new TrxnRespModel(TranId: payId,
                  ResponseCode: ResponseCode,
                  amount: amount,
                  result: result,

                  cardToken: cardToken,cardBrand: cardBrand,maskedPanNo: maskedPanNo,ResponseMsg:ResponseMsg);
              var resp1 = json.encode(trxnRespModel.toMap());
              print('Urway $resp1');
              ResponseConfig.startTrxn = false;
              _writetoFile(" Response from Hosted Page :  " + resp1 + "\n");
              return resp1;
              RespData=resp1;
            }
            else {

              var ErrorMsg;
              var apirespCode = data["responseCode"] as String;
              if (apirespCode == null) {
                apirespCode = data["responsecode"] as String;
                ErrorMsg = resp.respCode['$apirespCode'];
              }
              else {
                ErrorMsg = resp.respCode['$apirespCode'];
              }

              var apiresult = data["result"] as String;
              _writetoFile(
                  " Response from Hosted Page :  " + apirespCode + " : " +
                      ErrorMsg + "\n");
              print("API Result " + apiresult);
              print('ResponseCode $apirespCode : $ErrorMsg');
              showalertDailog(context, '$apiresult', '$ErrorMsg');
            }
          }

          else {
            var data = json.decode(response.body);
//          var payId = data["tranid"] as String;
//          var tar_url = data["targetUrl"] as String;
            var resp_code = data["responseCode"] as String;
//          String respCode = response.body.toString();
            _writetoFile("Response :" + resp_code + "\n");
            showalertDailog(context, 'Error', 'Invalid Request with $resp_code');
          }
        }
      }
      on Exception {
        ResponseConfig.startTrxn = false;
        showalertDailog(context, 'Internet Connection',
            'Please check your Internet Connection ');
        print('In Exception of urway payment ');

      }
    }
    else {

      ResponseConfig.startTrxn = false;
    }

return RespData;
  }
}

