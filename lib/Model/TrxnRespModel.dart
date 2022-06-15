

class TrxnRespModel
{  final String TranId;
  final String ResponseCode;
  final String amount;
  final String result;
  final String cardToken;
  final String cardBrand;
  final String maskedPanNo;
  final String ResponseMsg;


TrxnRespModel({required this.TranId, required this.ResponseCode, required this.amount, required this.result,
     required this.cardToken,required this.cardBrand,required this.maskedPanNo,required this.ResponseMsg});

  factory TrxnRespModel.fromJson(Map<String, dynamic> json) {
  return TrxnRespModel(
    TranId: json['TranId'],
    ResponseCode: json['ResponseCode'],
    amount: json['amount'],
    result: json['result'],

    cardToken: json['cardToken'],
    cardBrand: json['cardBrand'],
    maskedPanNo: json['maskedPanNo'],
    ResponseMsg: json['ResponseMsg'],

  );
  }

  Map toMap() {
  var map = new Map<String, dynamic>();
  map["TranId"] = TranId;
  map["ResponseCode"] =ResponseCode;
  map["amount"] =amount;
  map["result"] =result;

  map["cardToken"] =cardToken;
  map["cardBrand"] =cardBrand;
  map["maskedPanNo"] =maskedPanNo;
  map["ResponseMsg"] =ResponseMsg;
  return map;
  }
}
