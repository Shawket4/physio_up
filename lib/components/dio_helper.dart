// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';


Dio dio = Dio();

void initDio() {
  (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) => true;
    return client;
  };
}


Future<dynamic> postData(String url, dynamic data) async {
  try {
    var request = await dio.post(url, data: data);
    return request.data;
  } on DioException catch (e) {
       return e;
  }
}

Future<dynamic> getData(String url) async {
  try {
    var request = await dio.get(url);
    return request.data;
  } catch (e) {
    print(e);
      return e;
      }
}

Future<Response<dynamic>> downloadData(String url, filepath) async {
    var request = await dio.download(url, filepath);
    return request;
}

Future<dynamic> getDataAsBytes(String url) async {
  var request = await dio.get(url,  options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) { return status! < 500; }
            ),);
    return request;
}

Future<Response<dynamic>> downloadDataPost(String url, filepath, Map<String, dynamic> data) async {
   final response = await dio.post(
      url, // Replace with your API URL
      data: data,
      options: Options(responseType: ResponseType.bytes), // Ensure binary response
    );
    final file = File(filepath);

    await file.writeAsBytes(response.data);
    return response;
}
