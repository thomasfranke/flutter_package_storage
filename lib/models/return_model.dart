// Products:

import 'dart:convert';

List<StorageModelUpload> storageModelUploadFromJson(String str) =>
    List<StorageModelUpload>.from(json.decode(str).map((x) => StorageModelUpload.fromJson(x)));

class StorageModelUpload {
  final bool mSStatus;
  final bool mRStatus;
  final String mMsg;
  final String mIdFile;
  final String mFileName;
  final String mUrl;

  StorageModelUpload({
    required this.mSStatus,
    required this.mRStatus,
    required this.mMsg,
    required this.mIdFile,
    required this.mFileName,
    required this.mUrl,
  });

  factory StorageModelUpload.fromJson(Map<String, dynamic> json) => StorageModelUpload(
        mSStatus: json['s_status'],
        mRStatus: json['r_status'],
        mMsg: json["r_msg"].toString(),
        mIdFile: json["id_file"].toString(),
        mFileName: json["filename"],
        mUrl: json["url"],
      );
}
