import 'package:focus42/consts/firebase_functions_url.dart';
import 'package:http/http.dart' as http;

class FirebaseAuthRemoteDataSource {
  final String createCustomTokenUrl = FirebaseFunctionsUrl.createCustomTokenUrl;

  final String saveNetworkImageToStorageUrl =
      FirebaseFunctionsUrl.saveNetworkImageToStorageUrl;

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
