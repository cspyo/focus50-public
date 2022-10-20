import 'package:http/http.dart' as http;

class FirebaseAuthRemoteDataSource {
  final String url =
      'http://127.0.0.1:5001/focus50-dev/asia-northeast3/createCustomToken';

  Future<String> createCustomToken(Map<String, dynamic> user) async {
    final customTokenResponse = await http.post(Uri.parse(url), body: user);

    return customTokenResponse.body;
  }
}
