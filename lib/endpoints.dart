import 'package:api/exports.dart';

class MUploaderEndpoints {
  static MApiModelEndpoints delete = MApiModelEndpoints(method: "POST", url: "m/filemanager/v1/delete");
  static MApiModelEndpoints upload = MApiModelEndpoints(method: "POST", url: "m/filemanager/v1/upload");
  static MApiModelEndpoints uploadRegularBytes = MApiModelEndpoints(method: "POST", url: "m/filemanager/v1/upload/bytes");
  static MApiModelEndpoints uploadChunk = MApiModelEndpoints(method: "POST", url: "m/filemanager/v1/upload/chunk");
  static MApiModelEndpoints uploadChunkBytes = MApiModelEndpoints(method: "POST", url: "m/filemanager/v1/upload/chunk/bytes");
}
