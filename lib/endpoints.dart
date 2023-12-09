import 'exports.dart';

class StorageEndpoints {
  static ApiModelsEndpoints delete = ApiModelsEndpoints(method: ApiMethods.post, url: "/storage/v1/delete");
  static ApiModelsEndpoints upload = ApiModelsEndpoints(method: ApiMethods.post, url: "/storage/v1/upload/full/files");
  static ApiModelsEndpoints uploadBytes = ApiModelsEndpoints(method: ApiMethods.post, url: "/storage/v1/upload/full/bytes");
  static ApiModelsEndpoints uploadChunk = ApiModelsEndpoints(method: ApiMethods.post, url: "/storage/v1/upload/chunk");
  static ApiModelsEndpoints uploadChunkBytes = ApiModelsEndpoints(method: ApiMethods.post, url: "/storage/v1/upload/chunk/bytes");
}
