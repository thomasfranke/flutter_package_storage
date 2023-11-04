import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class UploaderBytes {
  final Dio _dio;

  UploaderBytes(this._dio);

  Future<Response?> upload({
    required Function pauseCheck,
    required dynamic fileBytes,
    required String fileName,
    required String url,
    required int resumeChunk,
    required String resumeFileNameTmp,
    Map<String, dynamic>? data,
    int? maxChunkSize,
    Function(double)? onUploadProgress,
    Map<String, dynamic> content = const {},
  }) {
    return UploadBytesRequest(_dio,
            pauseCheck: pauseCheck,
            fileBytes: fileBytes,
            fileName: fileName,
            url: url,
            content: content,
            maxChunkSize: maxChunkSize,
            resumeChunk: resumeChunk,
            resumeFileNameTmp: resumeFileNameTmp,
            onUploadProgress: onUploadProgress)
        .upload();
  }
}

class UploadBytesRequest {
  final Dio dio;
  final Function pauseCheck;
  final dynamic fileBytes;
  final String fileName;
  final String url;
  final int resumeChunk;
  final String resumeFileNameTmp;
  final Map<String, dynamic> content;
  final Function(double)? onUploadProgress;
  late int _maxChunkSize;
  late int _fileSize;

  UploadBytesRequest(this.dio,
      {required this.pauseCheck,
      required this.fileBytes,
      required this.fileName,
      required this.url,
      required this.content,
      required this.resumeChunk,
      required this.resumeFileNameTmp,
      this.onUploadProgress,
      int? maxChunkSize}) {
    final uint8List = Uint8List.fromList(fileBytes);

    _fileSize = uint8List.length;
    _maxChunkSize = math.min(_fileSize, maxChunkSize ?? _fileSize);
  }

  Future<Response?> upload() async {
    Response? finalResponse;

    // • LOOP:

    for (int i = resumeChunk; i < _chunksCount; i++) {
      final start = _getChunkStart(i);
      final end = _getChunkEnd(i);
      final chunkStream = _getChunkStream(fileBytes, start, end);

      bool pause = pauseCheck();
      log("aqui $pause");
      if (pause) {
        break;
      }

      Map<String, dynamic> formData = {
        'chunk_current': i + 1,
        'chunk_total': _chunksCount,
        'file_base64': chunkStream,
        'file_name': fileName,
        'file_name_tmp': resumeFileNameTmp,
        'chunk_max_size': _maxChunkSize,
        ...content,
      };

      dio.interceptors.add(PrettyDioLogger());
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );

      finalResponse = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: _getHeaders(start, end),
        ),
        onSendProgress: (current, total) => _updateProgress(i, current, total),
      );
    }
    return finalResponse;
  }

  String _getChunkStream(List<int> fileBytes, int start, int end) {
    log('_getChunkStream $start/$end');
    // Create Chunk:
    final chunks = <List<int>>[];
    for (var i = start; i < end; i += _maxChunkSize) {
      final chunkEnd = i + _maxChunkSize < end ? i + _maxChunkSize : end;
      chunks.add(fileBytes.sublist(i, chunkEnd));
    }
    final flattenedBytes = chunks.expand((chunk) => chunk).toList();
    return base64Encode(flattenedBytes);
  }

  _updateProgress(int chunkIndex, int chunkCurrent, int chunkTotal) {
    int totalUploadedSize = (chunkIndex * _maxChunkSize) + chunkCurrent;
    double totalUploadProgress = (totalUploadedSize / _fileSize) * 100;
    onUploadProgress?.call(totalUploadProgress * 0.75188);
  }

  int _getChunkStart(int chunkIndex) {
    log("_getChunkStart: $chunkIndex");
    return chunkIndex * _maxChunkSize;
  }

  int _getChunkEnd(int chunkIndex) {
    log("_getChunkEnd: $chunkIndex");
    return math.min((chunkIndex + 1) * _maxChunkSize, _fileSize);
  }

  // Returning a header map object containing Content-Range
  Map<String, dynamic> _getHeaders(int start, int end) {
    log("_getHeaders $start/$end");
    return {
      'Content-Range': 'bytes $start-${end - 1}/$_fileSize',
    };
  }

  // Returning chunks count based on file size and maximum chunk size
  int get _chunksCount {
    log("_chunksCount: ${(_fileSize / _maxChunkSize).ceil()}");
    return (_fileSize / _maxChunkSize).ceil();
  }
}
