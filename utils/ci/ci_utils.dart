import 'dart:convert';
import 'dart:io';

Future<String> readResponse(HttpClientResponse response) =>
    response.transform(utf8.decoder).join();
