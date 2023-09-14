import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:koibanda_provider_flutter/auth/sign_in_screen.dart';
import 'package:koibanda_provider_flutter/main.dart';
import 'package:koibanda_provider_flutter/networks/rest_apis.dart';
import 'package:koibanda_provider_flutter/utils/common.dart';
import 'package:koibanda_provider_flutter/utils/configs.dart';
import 'package:koibanda_provider_flutter/utils/constant.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';

Map<String, String> buildHeaderTokens({
  Map? extraKeys,
}) {
  /// Initialize & Handle if key is not present
  if (extraKeys == null) {
    extraKeys = {};
    extraKeys.putIfAbsent('isStripePayment', () => false);
    extraKeys.putIfAbsent('isFlutterWave', () => false);
    extraKeys.putIfAbsent('isSadadPayment', () => false);
  }

  Map<String, String> header = {
    HttpHeaders.cacheControlHeader: 'no-cache',
    'Access-Control-Allow-Headers': '*',
    'Access-Control-Allow-Origin': '*',
  };

  if (appStore.isLoggedIn && extraKeys.containsKey('isStripePayment') && extraKeys['isStripePayment']) {
    header.putIfAbsent(HttpHeaders.contentTypeHeader, () => 'application/x-www-form-urlencoded');
    header.putIfAbsent(HttpHeaders.authorizationHeader, () => 'Bearer ${extraKeys!['stripeKeyPayment']}');
  } else if (appStore.isLoggedIn && extraKeys.containsKey('isFlutterWave') && extraKeys['isFlutterWave']) {
    header.putIfAbsent(HttpHeaders.authorizationHeader, () => "Bearer ${extraKeys!['flutterWaveSecretKey']}");
  } else if (appStore.isLoggedIn && extraKeys.containsKey('isSadadPayment') && extraKeys['isSadadPayment']) {
    header.putIfAbsent(HttpHeaders.contentTypeHeader, () => 'application/json');
    if (extraKeys['sadadToken'].validate().isNotEmpty) header.putIfAbsent(HttpHeaders.authorizationHeader, () => extraKeys!['sadadToken']);
  } else {
    header.putIfAbsent(HttpHeaders.contentTypeHeader, () => 'application/json; charset=utf-8');
    header.putIfAbsent(HttpHeaders.acceptHeader, () => 'application/json; charset=utf-8');

    if (appStore.isLoggedIn) header.putIfAbsent(HttpHeaders.authorizationHeader, () => 'Bearer ${appStore.token}');
  }

  // log(jsonEncode(header));
  return header;
}

Uri buildBaseUrl(String endPoint) {
  Uri url = Uri.parse(endPoint);
  if (!endPoint.startsWith('http')) url = Uri.parse('$BASE_URL$endPoint');

  // log('URL: ${url.toString()}');

  return url;
}

Future<Response> buildHttpResponse(
  String endPoint, {
  HttpMethodType method = HttpMethodType.GET,
  Map? request,
  Map? extraKeys,
}) async {
  if (await isNetworkAvailable()) {
    var headers = buildHeaderTokens(extraKeys: extraKeys);
    Uri url = buildBaseUrl(endPoint);

    Response response;

    if (method == HttpMethodType.POST) {
      // log('Request: ${jsonEncode(request)}');
      response = await http.post(url, body: jsonEncode(request), headers: headers);
    } else if (method == HttpMethodType.DELETE) {
      response = await delete(url, headers: headers);
    } else if (method == HttpMethodType.PUT) {
      response = await put(url, body: jsonEncode(request), headers: headers);
    } else {
      response = await get(url, headers: headers);
    }

    apiPrint(
        url: url.toString(),
        endPoint: endPoint,
        headers: jsonEncode(headers),
        hasRequest: method == HttpMethodType.POST || method == HttpMethodType.PUT,
        request: jsonEncode(request),
        statusCode: response.statusCode,
        responseBody: response.body,
        methodtype: method.name);
    // log('Response (${method.name}) ${response.statusCode}: ${response.body}');

    return response;
  } else {
    throw errorInternetNotAvailable;
  }
}

Future handleResponse(Response response, {HttpResponseType httpResponseType = HttpResponseType.JSON, bool? avoidTokenError, bool? isSadadPayment}) async {
  if (!await isNetworkAvailable()) {
    throw errorInternetNotAvailable;
  }
  if (response.statusCode == 401) {
    if (!avoidTokenError.validate()) LiveStream().emit(LIVESTREAM_TOKEN, true);
    await clearPreferences();
    await FirebaseAuth.instance.signOut();
    push(SignInScreen(isRegeneratingToken: true));
    throw '${languages.lblTokenExpired}';
  } else if (response.statusCode == 400) {
    throw '${languages.badRequest}';
  } else if (response.statusCode == 403) {
    throw '${languages.forbidden}';
  } else if (response.statusCode == 404) {
    throw '${languages.pageNotFound}';
  } else if (response.statusCode == 429) {
    throw '${languages.tooManyRequests}';
  } else if (response.statusCode == 500) {
    throw '${languages.internalServerError}';
  } else if (response.statusCode == 502) {
    throw '${languages.badGateway}';
  } else if (response.statusCode == 503) {
    throw '${languages.serviceUnavailable}';
  } else if (response.statusCode == 504) {
    throw '${languages.gatewayTimeout}';
  }

  if (response.statusCode.isSuccessful()) {
    return jsonDecode(response.body);
  } else {
    if (isSadadPayment.validate()) {
      try {
        var body = jsonDecode(response.body);
        throw parseHtmlString(body['error']['message']);
      } on Exception catch (e) {
        log(e);
        throw errorSomethingWentWrong;
      }
    } else {
      try {
        var body = jsonDecode(response.body);
        throw parseHtmlString(body['message']);
      } on Exception catch (e) {
        log(e);
        throw errorSomethingWentWrong;
      }
    }
  }
}

Future<MultipartRequest> getMultiPartRequest(String endPoint, {String? baseUrl}) async {
  String url = '${baseUrl ?? buildBaseUrl(endPoint).toString()}';
  return MultipartRequest('POST', Uri.parse(url));
}

Future<void> sendMultiPartRequest(MultipartRequest multiPartRequest, {Function(dynamic)? onSuccess, Function(dynamic)? onError}) async {
  http.Response response = await http.Response.fromStream(await multiPartRequest.send());

  apiPrint(
      url: multiPartRequest.url.toString(),
      headers: jsonEncode(multiPartRequest.headers),
      request: jsonEncode(multiPartRequest.fields),
      hasRequest: true,
      statusCode: response.statusCode,
      responseBody: response.body,
      methodtype: "MultiPart");
  // log('response : ${response.body}');

  if (response.statusCode.isSuccessful()) {
    if (response.body.isJson()) {
      onSuccess?.call(response.body);
    } else {
      onSuccess?.call(response.body);
    }
  } else {
    try {
      if (response.body.isJson()) {
        var body = jsonDecode(response.body);
        onError?.call(body['message'] ?? errorSomethingWentWrong);
      } else {
        onError?.call(errorSomethingWentWrong);
      }
    } on Exception catch (e) {
      log(e);
      onError?.call(errorSomethingWentWrong);
    }
  }
}

String parseStripeError(String response) {
  try {
    var body = jsonDecode(response);
    return parseHtmlString(body['error']['message']);
  } on Exception catch (e) {
    log(e);
    throw errorSomethingWentWrong;
  }
}

void apiPrint({
  String url = "",
  String endPoint = "",
  String headers = "",
  String request = "",
  int statusCode = 0,
  String responseBody = "",
  String methodtype = "",
  bool hasRequest = false,
}) {
  log("┌───────────────────────────────────────────────────────────────────────────────────────────────────────");
  log("\u001b[93m Url: \u001B[39m $url");
  log("\u001b[93m endPoint: \u001B[39m \u001B[1m$endPoint\u001B[22m");
  log("\u001b[93m header: \u001B[39m \u001b[96m$headers\u001B[39m");
  log("\u001b[93m Request: \u001B[39m \u001b[96m$request\u001B[39m");
  log("${statusCode.isSuccessful() ? "\u001b[32m" : "\u001b[31m"}");
  log('Response ($methodtype) $statusCode: $responseBody');
  log("\u001B[0m");
  log("└───────────────────────────────────────────────────────────────────────────────────────────────────────");
}
