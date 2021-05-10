/// ================================
/// Reference:
/// `git@github.com:bookmebus/bookmebus-flutter/lib/services/translator_service.dart`
/// ================================
import 'dart:io';
import 'package:csv/csv.dart';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:storypad/constants/api_constant.dart';

/// Before generate new lacalize json file, please make sure that:
/// - "Stories App Translation" - langs is published in Google Spreadsheets
/// - there is no space or empty row and it is sorted
///
/// To get end point, please go to docs in Google Sheets
/// and publish it as csv file.
///
/// Our concept is download csv file then convert them to json file.
/// To generate json file,
///
/// Run following command in terminal:
/// ```
/// dart run darts/langs.dart
/// ```
void main() async {
  Dio dio = Dio();
  Response<dynamic> response;
  String endpoint = ApiConstant.langsSheetsEndPoint;
  response = await dio.get(endpoint);

  var translations = CsvToListConverter().convert(response.toString());

  final kmFileName = 'assets/translations/km.json';
  final enFileName = 'assets/translations/en.json';

  var en = {};
  var km = {};

  translations.forEach((row) {
    en[row[0]] = row[1];
    km[row[0]] = row[2];
  });

  _writeToFile(kmFileName, km);
  _writeToFile(enFileName, en);
}

_writeToFile(String filePath, Map data) {
  File(filePath).writeAsString(_prettifyJson(data)).then((File file) {
    print('$filePath created');
  });
}

_prettifyJson(Map<dynamic, dynamic> json) {
  JsonEncoder encoder = new JsonEncoder.withIndent("  ");
  String prettyJson = encoder.convert(json);
  return prettyJson;
}
