import 'package:http/http.dart' as http;

class FirebaseAuthRemoteDataSource {
  final String createCustomTokenUrl =
      'http://127.0.0.1:5001/focus50-dev/asia-northeast3/createCustomToken';

  final String saveNetworkImageToStorageUrl =
      'http://127.0.0.1:5001/focus50-dev/asia-northeast3/saveNetworkImageToStorage';

  Future<String> createCustomToken(Map<String, dynamic> user) async {
    final customTokenResponse =
        await http.post(Uri.parse(createCustomTokenUrl), body: user);

    return customTokenResponse.body;
  }

  Future<String> saveNetworkImageToStorage(
      String networkPhotoUrl, String uid) async {
    final photoUrlResponse =
        await http.post(Uri.parse(saveNetworkImageToStorageUrl), body: {
      "networkPhotoUrl": networkPhotoUrl,
      "uid": uid,
    });

    return photoUrlResponse.body;
  }
}
