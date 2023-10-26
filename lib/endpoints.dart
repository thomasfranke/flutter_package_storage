import 'package:api/exports.dart';

class MUploaderEndpoints {
  static ApiModelEndpoints delete = ApiModelEndpoints(method: ApiMethods.post, url: "m/filemanager/v1/delete");
  static ApiModelEndpoints upload = ApiModelEndpoints(method: ApiMethods.post, url: "m/filemanager/v1/upload");
  static ApiModelEndpoints uploadRegularBytes = ApiModelEndpoints(method: ApiMethods.post, url: "m/filemanager/v1/upload/bytes");
  static ApiModelEndpoints uploadChunk = ApiModelEndpoints(method: ApiMethods.post, url: "m/filemanager/v1/upload/chunk");
  static ApiModelEndpoints uploadChunkBytes = ApiModelEndpoints(method: ApiMethods.post, url: "m/filemanager/v1/upload/chunk/bytes");
}
