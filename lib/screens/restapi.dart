library my_restapi;

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:spmconnectapp/API_Keys/api.dart';
import 'package:spmconnectapp/models/token.dart';
import 'package:spmconnectapp/models/token_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Myrestapi {

  Token _token;
  TokenStorage _tokenStorage;

  factory Myrestapi() {
    if (Myrestapi._instance == null)
      Myrestapi._instance = new Myrestapi._internal();
    return _instance;
  }

  static Myrestapi _instance;

  Myrestapi._internal() {
    _tokenStorage = _tokenStorage ?? new TokenStorage();
  }

  Future getListData(String accesstoken) async {
    try {
      http.Response response = await http.get(
        Uri.encodeFull(Apikeys.sharepointListUrl),
        headers: {
          "Authorization": "Bearer " + accesstoken,
          "Accept": "application/json"
        },
      );
      var data = json.decode(response.body);
      List rest = data["value"] as List;
      for (var items in rest) {
        print(items['Customer']);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<Token> getSharepointToken() async {
    Token token;
    try {
      http.Response response = await http.post(
        Uri.encodeFull(Apikeys.sharepointTokenurl),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "grant_type": "client_credentials",
          "client_id": Apikeys.sharepointClientId,
          "client_secret": Apikeys.sharepointClientSecret,
          "resource": Apikeys.sharepointResource,
        },
      );

      var data = json.decode(response.body);
      print('Token Type : ' + data["token_type"]);
      print('Expires In : ' + data["expires_in"]);
      print('Not Before : ' + data["not_before"]);
      print('Expires On : ' + data["expires_on"]);
      print('Resource : ' + data["resource"]);
      print('Access Token : ' + data["access_token"]);
      Map<String, dynamic> tokenJson = json.decode(response.body);
       token = new Token.fromJson(tokenJson);
      
    } catch (e) {
      print(e);
    }

    return token;
  }

  Future<void> login() async {
    await _removeOldTokenOnFirstLogin();
    if (!Token.tokenIsValid(_token)) await _performAuthorization();
  }

  Future<String> getAccessToken() async {
    if (!Token.tokenIsValid(_token))
      await _performAuthorization();
      else print('token exits');
   return  _token.accessToken;
  }


  bool tokenIsValid() {
    return Token.tokenIsValid(_token);
  }

  Future<void> _performAuthorization() async {
    // load token from cache
    _token = await _tokenStorage.loadTokenToCache();

    //still have refreh token / try to get new access token with refresh token
    if (_token == null) {
      try {
        await _performFullAuthFlow();
      } catch (e) {
        rethrow;
      }
    } else {} //save token to cache
    await _tokenStorage.saveTokenToCache(_token);
  }

  Future<void> _performFullAuthFlow() async {
    try {
      _token = await getSharepointToken();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _removeOldTokenOnFirstLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final _keyFreshInstall = "freshInstall";
    if (!prefs.getKeys().contains(_keyFreshInstall)) {
      logout();
      await prefs.setBool(_keyFreshInstall, false);
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clear();
    _token = null;
    Myrestapi();
  }
}
