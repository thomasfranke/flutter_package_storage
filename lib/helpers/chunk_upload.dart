import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

class StorageUploadChunkFile {
  final Dio _dio;

  StorageUploadChunkFile(this._dio);

  Future<Response?> upload({
    required String filePath,
    required String path,
    Map<String, dynamic>? data,
    CancelToken? cancelToken,
    int? maxChunkSize,
    Function(double)? onUploadProgress,
    String method = 'POST',
    String fileKey = 'file',
    Map<String, dynamic> content = const {},
  }) =>
      UploadRequest(_dio,
              filePath: filePath,
              path: path,
              fileKey: fileKey,
              content: content,
              method: method,
              data: data,
              cancelToken: cancelToken,
              maxChunkSize: maxChunkSize,
              onUploadProgress: onUploadProgress)
          .upload();
}

class UploadRequest {
  final Dio dio;
  final String filePath, fileName, path, fileKey;
  final String? method;
  final Map<String, dynamic>? data;
  final Map<String, dynamic> content;
  final CancelToken? cancelToken;
  final File _file;
  final Function(double)? onUploadProgress;
  late int _maxChunkSize, _fileSize;

  UploadRequest(this.dio,
      {required this.filePath,
      required this.path,
      required this.fileKey,
      required this.content,
      this.method,
      this.data,
      this.cancelToken,
      this.onUploadProgress,
      int? maxChunkSize})
      : _file = File(filePath),
        fileName = p.basename(filePath) {
    _fileSize = _file.lengthSync();
    _maxChunkSize = math.min(_fileSize, maxChunkSize ?? _fileSize);
  }

  String generateRandomString(int len) => String.fromCharCodes(List.generate(len, (index) => math.Random().nextInt(33) + 89));

  Future<Response?> upload() async {
    Response? finalResponse;
    var tmp = generateRandomString(20);
    for (int i = 0; i < _chunksCount; i++) {
      final start = _getChunkStart(i);
      final end = _getChunkEnd(i);
      final chunkStream = _getChunkStream(start, end);
      String tmpName = tmp.toString();
      log("Start: $start | End: $end");
      final formData = FormData.fromMap(
        {
          'chunk_current': i + 1,
          'chunk_total': _chunksCount,
          'file': MultipartFile(chunkStream, end - start, filename: "$tmpName.part${i + 1}"),
          'filename': fileName,
          'filename_tmp': tmpName,
          ...content,
          if (data != null) ...data!,
        },
      );
      finalResponse = await dio.post(
        path,
        data: formData,
        cancelToken: cancelToken,
        options: Options(
          method: method,
          headers: _getHeaders(start, end),
        ),
        onSendProgress: (current, total) => _updateProgress(i, current, total),
      );
    }
    return finalResponse;
  }

  Stream<List<int>> _getChunkStream(int start, int end) => _file.openRead(start, end);

  // Updating total upload progress
  _updateProgress(int chunkIndex, int chunkCurrent, int chunkTotal) {
    int totalUploadedSize = (chunkIndex * _maxChunkSize) + chunkCurrent;
    double totalUploadProgress = (totalUploadedSize / _fileSize) * 100;
    onUploadProgress?.call(totalUploadProgress);
  }

  // Returning start byte offset of current chunk
  int _getChunkStart(int chunkIndex) => chunkIndex * _maxChunkSize;

  // Returning end byte offset of current chunk
  int _getChunkEnd(int chunkIndex) => math.min((chunkIndex + 1) * _maxChunkSize, _fileSize);

  // Returning a header map object containing Content-Range
  Map<String, dynamic> _getHeaders(int start, int end) => {'Content-Range': 'bytes $start-${end - 1}/$_fileSize'};

  // Returning chunks count based on file size and maximum chunk size
  int get _chunksCount => (_fileSize / _maxChunkSize).ceil();
}
