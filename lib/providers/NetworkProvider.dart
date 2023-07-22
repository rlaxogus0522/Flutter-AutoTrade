import 'dart:convert';

import 'package:auto_bitcoin/data/OldCandleData.dart';
import 'package:auto_bitcoin/models/res_account.dart';
import 'package:auto_bitcoin/models/res_martket_code.dart';
import 'package:auto_bitcoin/models/res_order.dart';
import 'package:crypto/crypto.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class NetworkProvider {
  String accessKey = "GHMVxzbaFTXJ0z89fBjmmG0xt4zjWjOcwGxzKQ1n";
  String secretKey = "bu4HxuarrtGn2Osw8v6zYi2v66D3BH5xMAYm7b2p";

  Future<List<ResAccount>?> getAccountInfo() async {
    Uri uri = Uri.parse('https://api.upbit.com/v1/accounts');

    final jwt = JWT(
      // Payload
      {'access_key': accessKey, 'nonce': const Uuid().v4()},
    );

    var jwtToken = jwt.sign(SecretKey(secretKey));

    final String authorizationToken = 'Bearer $jwtToken';

    print(authorizationToken);

    final response = await http.get(uri, headers: {
      "accept": "application/json",
      "Authorization": authorizationToken
    });

    ResAccount data;

    if (response.statusCode == 200) {
      // Map<String, dynamic> data = jsonDecode(response.body);
      // return ResAccount.fromJson(data);
      return (jsonDecode(response.body) as List)
          .map((e) => ResAccount.fromJson(e))
          .toList();
    } else {
      print(response.body);
      null;
    }
    return null;
  }

  Future<ResOrder?> order(String type, String marketCode, String data) async {
    Uri uri = Uri.parse('https://api.upbit.com/v1/orders');

    Map<String, String> queryParams = {
      'market': marketCode,
      'side': type,
      if (type == 'bid') 'price': data else 'volume': data,
      if (type == 'bid') 'ord_type': 'price' else 'ord_type': 'market',
    };

    var queryString = Uri(queryParameters: queryParams).query;

    var queryHash = sha256.convert(utf8.encode(queryString)).toString();

    final jwt = JWT(
      // Payload
      {
        'access_key': accessKey,
        'nonce': const Uuid().v4(),
        'query_hash': queryHash,
        'query_hash_alg': 'SHA256',
      },
    );

    var jwtToken = jwt.sign(SecretKey(secretKey));

    final String authorizationToken = 'Bearer $jwtToken';

    final response = await http.post(uri,
        headers: {
          "accept": "application/json",
          "Authorization": authorizationToken
        },
        body: queryParams);

    if (response.statusCode == 200) {
      // Map<String, dynamic> data = jsonDecode(response.body);
      // return ResAccount.fromJson(data);
      return ResOrder.fromJson(jsonDecode(response.body));
    } else {
      print(response.body);
      null;
    }
    return null;
  }

  Future<List<OldCandleData>?> getMinuteCandle(String market) async {
    Uri uri = Uri.parse(
        'https://api.upbit.com/v1/candles/minutes/1?market=$market&count=60');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((e) => OldCandleData.fromJson(e))
          .toList();
    } else {
      print(response.body);
      null;
    }
    return null;
  }

  Future<List<ItemMarketCode>?> getMarketCode() async {
    Uri uri = Uri.parse('https://api.upbit.com/v1/market/all?isDetails=false');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((e) => ItemMarketCode.fromJson(e))
          .toList();
    } else {
      print(response.body);
      null;
    }
    return null;
  }
}
