import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'package:dio/dio.dart';

import 'exports.dart';

class UploaderApi {
  static final UploaderApi request = UploaderApi._();
  UploaderApi._();

  Future<UploaderRedturnModel> uploadChunk({
    required Function(int) onProgressUpdate,
    required Function onComplete,
    required File file,
    required String cfUrlUploadChunk,
    Map<String, dynamic> header = const {},
    Map<String, dynamic> content = const {},
  }) async {
    log('* UPLOADER: uploadChunk | Start: $file');

    Uploader chunkedUploader = Uploader(
      Dio(
        BaseOptions(
          baseUrl: cfUrlUploadChunk,
          headers: {
            'User-Agent': 'PostmanRuntime/7.31.3',
            'Content-Type': 'multipart/form-data',
            'Accept': '*/*',
            'Connection': 'keep-alive',
            'Accept-Encoding': 'gzip, deflate, br',
            ...header,
          },
        ),
      ),
    );
    Response? response = await chunkedUploader.upload(
      fileKey: "file",
      method: "POST",
      filePath: file.path,
      maxChunkSize: 5000000, // 2MB = 2000000
      path: cfUrlUploadChunk,
      content: content,
      onUploadProgress: (v) {
        log("Progress Chunk $v");
        onProgressUpdate(v.toInt());
      },
    );
    onComplete();
    log("* UPLOADER: Chunk Upload Completed! $response");
    return UploaderRedturnModel.fromJson(response?.data);
  }

  String generateRandomString(int len) {
    var r = math.Random();
    return String.fromCharCodes(List.generate(len, (index) => r.nextInt(33) + 89));
  }

  Future<UploaderRedturnModel> uploadChunkBytes({
    required Function(int) onProgressUpdate,
    required Function pauseCheck,
    required Function onComplete,
    required dynamic fileBytes,
    required String fileName,
    required String cfUrlUploadChunkBytes,
    int resumeChunk = 0,
    String resumeFileNameTmp = 'N/A',
    Map<String, dynamic> header = const {},
    Map<String, dynamic> content = const {},
  }) async {
    log('* UPLOADER: uploadChunkBytes | Start');

    if (resumeFileNameTmp == 'N/A') {
      resumeFileNameTmp = generateRandomString(20).toString();
    }

    UploaderBytes chunkedUploader = UploaderBytes(
      Dio(
        BaseOptions(
          baseUrl: cfUrlUploadChunkBytes,
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': '*/*',
            'Connection': 'keep-alive',
            'Accept-Encoding': 'gzip, deflate, br',
            ...header,
          },
        ),
      ),
    );
    Response? response = await chunkedUploader.upload(
      maxChunkSize: 5000000, // 2MB = 2000000
      url: cfUrlUploadChunkBytes,
      content: content,
      onUploadProgress: (v) {
        onProgressUpdate(v.toInt());
      },
      fileBytes: fileBytes,
      fileName: fileName,
      resumeChunk: resumeChunk,
      resumeFileNameTmp: resumeFileNameTmp,
      pauseCheck: pauseCheck,
    );
    onComplete();
    log("* UPLOADER: Chunk Bytes Upload Completed! $response");

    return UploaderRedturnModel.fromJson(response?.data);
  }
}
