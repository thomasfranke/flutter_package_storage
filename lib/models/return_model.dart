// Products:

import 'dart:convert';

List<UploaderRedturnModel> uploaderRedturnModelFromJson(String str) =>
    List<UploaderRedturnModel>.from(json.decode(str).map((x) => UploaderRedturnModel.fromJson(x)));

class UploaderRedturnModel {
  final bool mSStatus;
  final bool mRStatus;
  final String mMsg;
  final String mIdFile;
  final String mFileName;
  final String mUrl;

  UploaderRedturnModel({
    required this.mSStatus,
    required this.mRStatus,
    required this.mMsg,
    required this.mIdFile,
    required this.mFileName,
    required this.mUrl,
  });

  factory UploaderRedturnModel.fromJson(Map<String, dynamic> json) => UploaderRedturnModel(
        mSStatus: json['s_status'],
        mRStatus: json['r_status'],
        mMsg: json["r_msg"].toString(),
        mIdFile: json["id_file"].toString(),
        mFileName: json["filename"],
        mUrl: json["url"],
      );
}
