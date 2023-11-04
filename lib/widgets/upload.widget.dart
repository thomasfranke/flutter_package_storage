import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';

import 'package:loading_indicator/loading_indicator.dart';
import 'package:path/path.dart' as path;
import '../exports.dart';

class UploadBtnWidget extends StatefulWidget {
  final int mServiceId;
  final Function appUploadCompleted;
  final Map<String, dynamic> content;
  final String text;
  final String cfUrlUploadChunkBytes;

  const UploadBtnWidget(
      {Key? key,
      this.mServiceId = 0,
      required this.appUploadCompleted,
      required this.content,
      this.text = "ENVIE SEU CONTEÚDO",
      required this.cfUrlUploadChunkBytes})
      : super(key: key);
  @override
  State<UploadBtnWidget> createState() => _UploadBtnWidget();
}

class _UploadBtnWidget extends State<UploadBtnWidget> {
  late File file;
  bool isUploading = false;
  bool uploadPause = false;
  bool isPreparingUpload = false;
  var queueI = 0;
  bool isLast = true;

  late FilePickerResult? fileList;

  Future<void> _checkQueue(fileList) async {
    if (queueI == fileList.files.length - 1) {
      isLast = true;
    } else {
      isLast = false;
    }

    if (queueI != fileList.files.length) {
      _funcIsPreparingUpload(true);
      PlatformFile platFormFile = fileList.files[queueI];
      file = File(platFormFile.path!);
      List<int> fileBytes = await file.readAsBytes();
      String fileName = path.basename(file.path);

      Map<String, dynamic> header = {};

      UploaderApi.request.uploadChunkBytes(
        header: header,
        content: widget.content,
        cfUrlUploadChunkBytes: widget.cfUrlUploadChunkBytes,
        onComplete: _uploadCompleted,
        onProgressUpdate: _uploadProgress,
        fileBytes: fileBytes,
        fileName: fileName,
        pauseCheck: pauseCheck,
      );
      queueI++;
    }
  }

  Future<void> _pickFile() async {
    _funcIsUploading(true);

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
      allowCompression: false,
    );

    if (result != null) {
      _checkQueue(fileList);
    } else {
      _funcIsUploading(false);
    }
  }

  Future<void> _pickGalleryImage() async {
    fileList = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      allowCompression: false,
    );

    if (fileList != null) {
      _checkQueue(fileList);
    } else {
      _funcIsUploading(false);
    }
  }

  Future<void> _pickGalleryVideos() async {
    fileList = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowCompression: false,
      allowMultiple: false,
    );
    if (fileList != null) {
      _checkQueue(fileList);
    } else {
      _funcIsUploading(false);
    }
  }

  int _uploadProgressInt = -1;
  bool _uploadCompletedBool = false;
  void _uploadProgress(int progress) {
    _funcIsPreparingUpload(false);
    if (_uploadProgressInt != progress) {
      setState(() {
        _uploadProgressInt = progress;
      });
    }
  }

  void _uploadCompleted() {
    if (isLast) {
      widget.appUploadCompleted();
      _uploadCompletedBool = true;
    } else {
      if (fileList != null) {
        _checkQueue(fileList);
      }
    }
  }

  bool pauseCheck() {
    if (uploadPause) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    uploadPause = true;
    super.dispose();
  }

  Widget _progressBar() {
    if (_uploadProgressInt == -1) {
      return const SizedBox();
    }
    if (_uploadCompletedBool) {
      const Padding(
        padding: EdgeInsets.all(5.0),
        child: Text(
          'Envio completado',
          textAlign: TextAlign.left,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 25),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.purple,
            width: 0.6,
          ),
        ),
        child: Column(
          children: [
            const Text("ENVIANDO ARQUIVO"),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              height: 15,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                child: LinearProgressIndicator(
                  value: _uploadProgressInt / 100,
                  color: const Color(0xff5b2982),
                  backgroundColor: Colors.purple.shade100,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                '$_uploadProgressInt%',
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(height: 5),
            const Center(
              child: SizedBox(
                width: 80,
                child: LoadingIndicator(
                  indicatorType: Indicator.ballClipRotateMultiple,
                  colors: [Colors.purple],
                  strokeWidth: 2,
                ),
              ),
            ),
            const SizedBox(height: 5),
            // UploadCancelWidget(
            //   btnText: uploadPause ? 'CANCELANDO...' : 'CANCELAR ENVIO',
            //   onTap: () {
            //     setState(() {
            //       uploadPause = true;
            //     });
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> _mobileOptions(BuildContext context) {
    _funcIsUploading(true);
    bool dismissIsUploading = true;
    return showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Documentos'),
                onTap: () {
                  dismissIsUploading = false;
                  _pickFile();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Imagens'),
                onTap: () {
                  dismissIsUploading = false;
                  _pickGalleryImage();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_call),
                title: const Text('Videos'),
                onTap: () {
                  dismissIsUploading = false;
                  _pickGalleryVideos();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    ).then((value) {
      if (dismissIsUploading) _funcIsUploading(false);
    });
  }

  void _funcIsUploading(check) {
    setState(() {
      isUploading = check;
      isPreparingUpload = false;
    });
  }

  void _funcIsPreparingUpload(check) {
    if (isPreparingUpload != check) {
      setState(() {
        isPreparingUpload = check;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Bounceable(
          onTap: () {
            if (!isUploading) {
              _mobileOptions(context);
            }
          },
          child: Container(
            width: width * 0.7,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Colors.amber,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 18.0, right: 10),
                    child: Text(
                      widget.text,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 47,
                  width: 47,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.only(left: 0.0),
                      child: Icon(
                        Icons.arrow_upward,
                        color: Colors.amber,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 25),
        // if (isPreparingUpload)
        //   const UploadCancelWidget(
        //     btnText: "Arquivo sendo preparado para envio. Isso pode levar alguns segundos.",
        //     showActivityIndicator: true,
        //   ),
        const SizedBox(height: 25),
        _progressBar(),
      ],
    );
  }
}
